use crate::frame::{FrameHeader, FrameError, RawFrame};
use no_std_io::io::{Read, Write};

pub struct Receiver<const MAX_PAYLOAD_WITH_CRC_SIZE: usize> {
    state: State,
    receive_buffer: [u8; MAX_PAYLOAD_WITH_CRC_SIZE],
}

#[derive(Debug)]
enum State {
    Header(usize),
    Payload((usize, FrameHeader)),
    Discard((usize, FrameHeader)),
}

#[derive(Debug)]
pub enum ReceiveError {
    #[cfg(feature = "alloc")]
    IoError(Box<dyn no_std_io::error::Error>),
    #[cfg(not(feature = "alloc"))]
    IoError,
    FrameError(FrameError),
}

impl<E: no_std_io::error::Error + 'static> From<E> for ReceiveError {
    #[allow(unused)]
    fn from(error: E) -> Self {
        #[cfg(feature = "alloc")]
        { Self::IoError(Box::new(error)) }
        #[cfg(not(feature = "alloc"))]
        Self::IoError
    }
}

impl From<FrameError> for ReceiveError {
    fn from(error: FrameError) -> Self {
        Self::FrameError(error)
    }
}

impl<const MAX_PAYLOAD_WITH_CRC_SIZE: usize> Receiver<MAX_PAYLOAD_WITH_CRC_SIZE> {
    pub fn new() -> Self {
        Self {
            state: State::Header(0),
            receive_buffer: [0; MAX_PAYLOAD_WITH_CRC_SIZE],
        }
    }

    pub fn receive<R>(&mut self, reader: &mut R) -> Result<Option<RawFrame>, ReceiveError>
    where
        R: Read,
    {
        let (offset, bytes_to_read) = match &self.state {
            State::Header(bytes_read) => (*bytes_read, FrameHeader::SIZE - bytes_read),
            State::Payload((bytes_read, header)) => (*bytes_read, header.payload_length as usize + 2 - bytes_read),
            State::Discard((bytes_read, header)) => (0, usize::min(header.payload_length as usize + 2 - bytes_read, MAX_PAYLOAD_WITH_CRC_SIZE)),
        };
        let bytes_read = reader.read(&mut self.receive_buffer[offset..offset + bytes_to_read])?;
        if bytes_to_read > 0 && bytes_read == 0 {
            return Ok(None);
        }
        let total_bytes_read = offset + bytes_read;
        let (result, next_state) = match &self.state {
            State::Header(_) => {
                let next_state = if total_bytes_read == FrameHeader::SIZE {
                    match FrameHeader::read_header(&self.receive_buffer[..total_bytes_read]) {
                        Ok((header, _offset)) => {
                            if header.payload_length > (MAX_PAYLOAD_WITH_CRC_SIZE - 2) as u16 {
                                // Cannot receive the frame due to insufficient buffer size. discard all data of the frame and retry.
                                State::Discard((0, header))
                            } else {
                                State::Payload((0, header))
                            }
                        },
                        Err((FrameError::NoFrameMarker, _)) => {
                            // No frame marker in the buffer. discard all data and retry.
                            State::Header(0)
                        },
                        Err((FrameError::InsufficientLength, marker_offset)) => {
                            // A frame marker was found, but the header is incomplete. discard data prior to the frame marker and retry.
                            let remaining_length = total_bytes_read - marker_offset;
                            self.receive_buffer.copy_within(marker_offset..total_bytes_read, 0);
                            State::Header(remaining_length)
                        },
                        Err((_, _)) => {
                            // Other error has occured. discard all data and retry.
                            State::Header(0)
                        },
                    }
                } else {
                    // Partially received header. retry.
                    State::Header(total_bytes_read)
                };
                (Ok(None), next_state)
            },
            State::Payload((_, header)) => {
                if total_bytes_read == header.payload_length as usize + 2 {
                    let result: Result<_, ReceiveError> = RawFrame::read_frame_payload(header.clone(), &self.receive_buffer[..total_bytes_read])
                        .map_err(|error| error.into())
                        .map(|(frame, _)| Some(frame));
                    (result, State::Header(0))
                } else {
                    (Ok(None), State::Payload((total_bytes_read, *header)))
                }
            },
            State::Discard((_, header)) => {
                if total_bytes_read == header.payload_length as usize + 2 {
                    (Ok(None), State::Header(0))
                } else {
                    (Ok(None), State::Discard((total_bytes_read, *header)))
                }
            },
        };
        self.state = next_state;
        result
    }
}

#[cfg(test)]
mod test {
    use crate::frame::{FRAME_MARKER, QueryVersionResponseFrame, FrameTypeAndDirection, FrameType};

    use super::*;

    fn is_crc_error<'a>(result: Result<Option<RawFrame<'a>>, ReceiveError>) -> bool {
        match result {
            Ok(_) => false,
            Err(ReceiveError::FrameError(FrameError::CrcMismatch { expected, actual, header })) => true,
            _ => false,
        }
    }

    #[test]
    fn test_receiver() {
        let mut receiver = Receiver::<34>::new();
        
        // No frame marker
        let mut input = no_std_io::io::Cursor::new([0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        assert_eq!(receiver.receive(&mut input).unwrap(), None);

        // Frame marker has detected, but CRC error has occured.
        // The receiver just discards the frame.
        let mut input = no_std_io::io::Cursor::new([FRAME_MARKER, 0x00, 0x00, 0x00, 0x00, 0x00]);
        assert_eq!(receiver.receive(&mut input).unwrap(), None);
        let mut input = no_std_io::io::Cursor::new([0x00, 0x00]);
        assert!(is_crc_error(receiver.receive(&mut input)));

        // Incomplete header
        let mut input = no_std_io::io::Cursor::new([FRAME_MARKER, 0x00, 0x00, 0x00, 0x00, 0x00]);
        assert_eq!(receiver.receive(&mut input).unwrap(), None);
        // And then the header and payload are received, but CRC error has occured.
        let mut input = no_std_io::io::Cursor::new([0x00]);
        assert_eq!(receiver.receive(&mut input).unwrap(), None);
        let mut input = no_std_io::io::Cursor::new([0x00]);
        assert!(is_crc_error(receiver.receive(&mut input)));

        let mut buffer = [0u8; 32];
        let mut payload = [0u8; 6];
        let frame = QueryVersionResponseFrame::new(0x0001, &mut payload, 0x12345678, 32).unwrap();
        let raw_frame: RawFrame = frame.into();
        let mut input = no_std_io::io::Cursor::new(&mut buffer[..]);
        raw_frame.write_frame(&mut input).unwrap();
        let mut input = no_std_io::io::Cursor::new(&buffer);
        assert_eq!(receiver.receive(&mut input).unwrap(), None);
        let frame_header = receiver.receive(&mut input).unwrap()
            .map(|frame| frame.header);
        assert_eq!(frame_header, Some(FrameHeader {
            frame_number: 0x0001,
            payload_length: 6,
            frame_type: FrameTypeAndDirection::Response(FrameType::QueryVersion),
        }));
        
    }
}