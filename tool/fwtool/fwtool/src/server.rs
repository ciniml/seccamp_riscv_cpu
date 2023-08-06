use no_std_io::io::{Read, Write};

use crate::{receiver::Receiver, frame::{RawFrame, Frame, QueryVersionResponseFrame, ErrorResponseFrame, ReadMemoryResponseFrame, WriteMemoryResponseFrame, RunResponseFrame, FrameHeader, FRAME_MARKER}};


#[derive(Debug, Clone, Copy)]
struct PendingTransfer {
    offset: usize,
    remaining_bytes: usize,
}

pub struct Server<Handler: ServerHandler, const MAX_FRAME_SIZE: usize> {
    handler: Handler,
    pending_transfer: Option<PendingTransfer>,
    frame_buffer: [u8; MAX_FRAME_SIZE],
    receiver: Receiver<MAX_FRAME_SIZE>,
}

#[repr(u32)]
#[derive(Debug)]
pub enum ServerError {
    InvalidParameter = 0x01,
    InvalidAddress = 0x02,
    LengthTooLong = 0x03,
    InvalidRequest = 0x04,
    Unknown = 0x80,
}

pub trait ServerHandler {
    fn on_query_version(&mut self) -> Result<u32, ServerError>;
    fn on_read_memory(&mut self, address: u32, buffer: &mut [u8]) -> Result<(), ServerError>;
    fn on_write_memory(&mut self, address: u32, buffer: &[u8]) -> Result<(), ServerError>;
    fn on_run(&mut self, address: u32) -> Result<(), ServerError>;
}

fn make_error_response<'a>(frame_number: u16, error: ServerError, buffer: &'a mut [u8]) -> Frame<'a> {
    let frame = ErrorResponseFrame::new(frame_number, buffer, error as u32).unwrap();
    Frame::ErrorResponse(frame)
}

impl<Handler: ServerHandler, const MAX_FRAME_SIZE: usize> Server<Handler, MAX_FRAME_SIZE> {
    pub fn new(handler: Handler) -> Self {
        Self {
            handler,
            pending_transfer: None,
            frame_buffer: [0; MAX_FRAME_SIZE],
            receiver: Receiver::new(),
        }
    }

    pub fn process<R, W>(&mut self, reader: &mut R, writer: &mut W)
    where
        R: Read,
        W: Write,
    {
        // Process pending transfer.
        self.pending_transfer = if let Some(pending_transfer) = &self.pending_transfer {
            if let Ok(bytes_written) = writer.write(&self.frame_buffer[pending_transfer.offset..pending_transfer.offset + pending_transfer.remaining_bytes]) {
                let remaining_bytes = pending_transfer.remaining_bytes - bytes_written;
                let offset = pending_transfer.offset + bytes_written;
                if remaining_bytes == 0 {
                    None
                } else {
                    Some(PendingTransfer { offset, remaining_bytes })
                }
            } else {
                Some(*pending_transfer)
            }
        } else {
            None
        };
        if self.pending_transfer.is_some() {
            // If there is a pending transfer, we don't process any new requests.
            return;
        }

        if let Ok(Some(frame)) = self.receiver.receive(reader) {
            if let Ok(frame) = Frame::try_from(frame) {
                let response = {
                    let (_header_buffer, mut payload_with_crc_buffer) = self.frame_buffer.split_at_mut(FrameHeader::SIZE);
                    let header = frame.frame_header().clone();
                    let response_frame: Option<Frame<'_>> = match frame {
                        Frame::QueryVersionRequest(_frame) => {
                            match self.handler.on_query_version() {
                                Ok(version) => { Some(Frame::QueryVersionResponse(QueryVersionResponseFrame::new(header.frame_number, &mut payload_with_crc_buffer, version, (MAX_FRAME_SIZE - FrameHeader::SIZE - 2) as u16).unwrap())) },
                                Err(error) => { Some(make_error_response(header.frame_number, error, &mut payload_with_crc_buffer)) },
                            }
                        },
                        Frame::ReadMemoryRequest(frame) => {
                            let length = frame.length() as usize;
                            if length > MAX_FRAME_SIZE - 2 {
                                Some(make_error_response(header.frame_number, ServerError::LengthTooLong, &mut payload_with_crc_buffer))
                            } else {
                                let mut buffer = &mut payload_with_crc_buffer[..length];
                                match self.handler.on_read_memory(frame.address(), &mut buffer) {
                                    Ok(()) => { Some(Frame::ReadMemoryResponse(ReadMemoryResponseFrame::new(header.frame_number, buffer).unwrap())) },
                                    Err(error) => { Some(make_error_response(header.frame_number, error, &mut payload_with_crc_buffer)) },
                                }
                            }
                        },
                        Frame::WriteMemoryRequest(frame) => {
                            match self.handler.on_write_memory(frame.address(), frame.data()) {
                                Ok(()) => { Some(Frame::WriteMemoryResponse(WriteMemoryResponseFrame::new(header.frame_number).unwrap())) },
                                Err(error) => { Some(make_error_response(header.frame_number, error, &mut payload_with_crc_buffer)) },
                            }
                        },
                        Frame::RunRequest(frame) => {
                            match self.handler.on_run(frame.address()) {
                                Ok(()) => Some(Frame::RunResponse(RunResponseFrame::new(header.frame_number).unwrap())),
                                Err(error) => Some(make_error_response(header.frame_number, error, &mut payload_with_crc_buffer)),
                            }
                        }
                        _ => Some(make_error_response(header.frame_number, ServerError::InvalidRequest, &mut payload_with_crc_buffer)),
                    };

                    if let Some(frame) = response_frame {
                        let raw_frame: RawFrame<'_> = frame.into();
                        let crc = raw_frame.calculate_crc();
                        Some((raw_frame.header, crc))
                    } else {
                        None
                    }
                };

                if let Some((header, crc)) = response {
                    // Update header and CRC in the frame buffer.
                    let payload_length = header.payload_length as usize;
                    let header_bytes: [u8; 5] = header.into();
                    self.frame_buffer[0] = FRAME_MARKER;
                    self.frame_buffer[1..6].copy_from_slice(&header_bytes);
                    self.frame_buffer[6 + payload_length..6 + payload_length + 2].copy_from_slice(&crc.to_be_bytes());
                    self.pending_transfer = Some( PendingTransfer { offset: 0, remaining_bytes: 6 + payload_length + 2 });
                }
            }
        }
    }
}

#[cfg(test)]
pub(crate) mod test {
    use crate::frame::QueryVersionRequestFrame;

    use super::*;

    pub(crate) struct TestServerHandler {
        pub(crate) version: u32,
        pub(crate) read_memory: Option<(u32, Vec<u8>)>,
        pub(crate) write_memory: Option<(u32, Vec<u8>)>,
        pub(crate) run: Option<u32>,
    }

    impl TestServerHandler {
        pub(crate) fn new() -> Self {
            Self {
                version: 0,
                read_memory: None,
                write_memory: None,
                run: None,
            }
        }
    }

    impl ServerHandler for TestServerHandler {
        fn on_query_version(&mut self) -> Result<u32, ServerError> {
            Ok(self.version)
        }

        fn on_read_memory(&mut self, address: u32, buffer: &mut [u8]) -> Result<(), ServerError> {
            if let Some((expected_address, expected_buffer)) = &self.read_memory {
                if address != *expected_address {
                    return Err(ServerError::InvalidAddress);
                }
                if buffer.len() != expected_buffer.len() {
                    return Err(ServerError::LengthTooLong);
                }
                buffer.copy_from_slice(&expected_buffer[..]);
                Ok(())
            } else {
                Err(ServerError::Unknown)
            }
        }

        fn on_write_memory(&mut self, address: u32, buffer: &[u8]) -> Result<(), ServerError> {
            if let Some((expected_address, expected_buffer)) = &self.write_memory {
                if address != *expected_address {
                    return Err(ServerError::InvalidAddress);
                }
                if buffer.len() != expected_buffer.len() {
                    return Err(ServerError::LengthTooLong);
                }
                Ok(())
            } else {
                Err(ServerError::Unknown)
            }
        }

        fn on_run(&mut self, address: u32) -> Result<(), ServerError> {
            if let Some(expected_address) = &self.run {
                if address != *expected_address {
                    return Err(ServerError::InvalidAddress);
                }
                Ok(())
            } else {
                Err(ServerError::Unknown)
            }
        }
    }

    pub(crate) fn make_frame_buffer<F: FnOnce(&mut [u8]) -> Frame>(payload_size: usize, f: F) -> Vec<u8> {
        let mut frame_buffer = vec![0; FrameHeader::SIZE + payload_size + 2];
        {
            let frame_buffer = &mut frame_buffer[..];
            let (header_buffer, payload_with_crc_buffer) = frame_buffer.split_at_mut(FrameHeader::SIZE);
            let frame = f(&mut payload_with_crc_buffer[..payload_size]);
            let raw_frame: RawFrame<'_> = frame.into();
            let crc = raw_frame.calculate_crc();
            let header = raw_frame.header.clone();
            let payload_length = header.payload_length as usize;
            let header_bytes: [u8; 5] = header.into();
            header_buffer[0] = FRAME_MARKER;
            header_buffer[1..].copy_from_slice(&header_bytes);
            payload_with_crc_buffer[payload_length..payload_length + 2].copy_from_slice(&crc.to_be_bytes());
        }
        frame_buffer
    }

    #[test]
    fn test_query_version() {
        let mut handler = TestServerHandler::new();
        handler.version = 0x12345678;
        const MAX_FRAME_SIZE: usize = 128;
        let expected_max_payload_size = MAX_FRAME_SIZE - FrameHeader::SIZE - 2;
        let mut server = Server::<_, MAX_FRAME_SIZE>::new(handler);
        let mut reader = std::io::Cursor::new(make_frame_buffer(6, |_payload| Frame::QueryVersionRequest(QueryVersionRequestFrame::new(1)))) ;
        let mut write_buffer = [0u8; FrameHeader::SIZE + 6 + 2];
        let mut writer = std::io::Cursor::new(&mut write_buffer[..]);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        let expected = make_frame_buffer(6, |payload: &mut [u8]| Frame::QueryVersionResponse(QueryVersionResponseFrame::new(1, payload, 0x12345678, expected_max_payload_size as u16).unwrap()));
        assert_eq!(&write_buffer[..], &expected);
    }

    #[test]
    fn test_read_memory() {
        let mut handler = TestServerHandler::new();
        handler.read_memory = Some((0x12345678, vec![0x11, 0x22, 0x33, 0x44]));
        const MAX_FRAME_SIZE: usize = 128;
        let mut server = Server::<_, MAX_FRAME_SIZE>::new(handler);
        let mut reader = std::io::Cursor::new(make_frame_buffer(6, |payload| Frame::ReadMemoryRequest(crate::frame::ReadMemoryRequestFrame::new(1, payload, 0x12345678, 4).unwrap())));
        let mut write_buffer = [0u8; FrameHeader::SIZE + 4 + 2];
        let mut writer = std::io::Cursor::new(&mut write_buffer[..]);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        let expected = make_frame_buffer(4, |payload| {
            payload.copy_from_slice(&[0x11, 0x22, 0x33, 0x44]);
            Frame::ReadMemoryResponse(ReadMemoryResponseFrame::new(1, payload).unwrap())
        });
        assert_eq!(&write_buffer[..], &expected);
    }
    #[test]
    fn test_write_memory() {
        let mut handler = TestServerHandler::new();
        handler.write_memory = Some((0x12345678, vec![0x11, 0x22, 0x33, 0x44]));
        const MAX_FRAME_SIZE: usize = 128;
        let mut server = Server::<_, MAX_FRAME_SIZE>::new(handler);
        let mut reader = std::io::Cursor::new(make_frame_buffer(6 + 4, |payload| Frame::WriteMemoryRequest(crate::frame::WriteMemoryRequestFrame::new(1, payload, 0x12345678, &[0x11, 0x22, 0x33, 0x44]).unwrap())));
        let mut write_buffer = [0u8; FrameHeader::SIZE + 2];
        let mut writer = std::io::Cursor::new(&mut write_buffer[..]);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        let expected = make_frame_buffer(0, |_payload| Frame::WriteMemoryResponse(WriteMemoryResponseFrame::new(1).unwrap()));
        assert_eq!(&write_buffer[..], &expected);
    }
    #[test]
    fn test_run() {
        let mut handler = TestServerHandler::new();
        handler.run = Some(0x12345678);
        const MAX_FRAME_SIZE: usize = 128;
        let mut server = Server::<_, MAX_FRAME_SIZE>::new(handler);
        let mut reader = std::io::Cursor::new(make_frame_buffer(6, |payload| Frame::RunRequest(crate::frame::RunRequestFrame::new(1, payload, 0x12345678).unwrap())));
        let mut write_buffer = [0u8; FrameHeader::SIZE + 2];
        let mut writer = std::io::Cursor::new(&mut write_buffer[..]);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        server.process(&mut reader, &mut writer);
        let expected = make_frame_buffer(0, |_payload| Frame::RunResponse(RunResponseFrame::new(1).unwrap()));
        assert_eq!(&write_buffer[..], &expected);
    }
}