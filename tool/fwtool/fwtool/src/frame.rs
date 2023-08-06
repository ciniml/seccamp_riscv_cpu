use crc;

pub const FRAME_MARKER: u8 = 0x5a;

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum FrameError {
    NoFrameMarker,
    InvalidFrameType,
    InsufficientLength,
    InvalidLength,
    CrcMismatch {
        expected: u16,
        actual: u16,
        header: FrameHeader,
    },
}

#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum FrameType {
    QueryVersion = 0x00,
    ReadMemory = 0x01,
    WriteMemory = 0x02,
    Run = 0x03,
    ErrorResponse = 0x80,
}

impl TryFrom<u8> for FrameType {
    type Error = FrameError;

    fn try_from(byte: u8) -> Result<Self, Self::Error> {
        match byte {
            0x00 => Ok(Self::QueryVersion),
            0x01 => Ok(Self::ReadMemory),
            0x02 => Ok(Self::WriteMemory),
            0x03 => Ok(Self::Run),
            0x80 => Ok(Self::ErrorResponse),
            _ => Err(FrameError::InvalidFrameType),
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum FrameTypeAndDirection {
    Request(FrameType),
    Response(FrameType),
} 

impl TryFrom<u8> for FrameTypeAndDirection {
    type Error = FrameError;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value & 0x80 {
            0x00 => Ok(Self::Request(FrameType::try_from(value & !0x80)?)),
            0x80 => Ok(Self::Response(FrameType::try_from(value & !0x80)?)),
            _ => Err(FrameError::InvalidFrameType),
        }
    }
}
impl Into<u8> for FrameTypeAndDirection {
    fn into(self) -> u8 {
        match self {
            Self::Request(frame_type) => frame_type as u8 ,
            Self::Response(frame_type) => frame_type as u8 | 0x80,
        }
    }
}


#[derive(Clone, Copy, Debug, PartialEq)]
pub struct FrameHeader {
    pub frame_type: FrameTypeAndDirection,
    pub frame_number: u16,
    pub payload_length: u16,
}

impl FrameHeader {
    pub const SIZE: usize = 1 + 5;

    pub fn read_header(bytes: &[u8]) -> Result<(FrameHeader, usize), (FrameError, usize)> {
        // Detect frame marker
        let offset = bytes.iter().enumerate().find_map(|(i, &v)| if v == FRAME_MARKER { Some(i) } else { None }).ok_or((FrameError::NoFrameMarker, bytes.len()))?;
        if bytes.len() < offset + 1 {
            return Err((FrameError::InsufficientLength, offset));
        }
        let header: FrameHeader = FrameHeader::try_from(&bytes[offset + 1..])
            .map_err(|e| (e, offset))?;

        Ok((header, offset + FrameHeader::SIZE))
    }
}

impl TryFrom<&[u8]> for FrameHeader {
    type Error = FrameError;

    fn try_from(bytes: &[u8]) -> Result<Self, Self::Error> {
        if bytes.len() < 5 {
            return Err(FrameError::InsufficientLength);
        }

        let frame_type = FrameTypeAndDirection::try_from(bytes[0])?;
        let frame_number = u16::from_be_bytes([bytes[1], bytes[2]]);
        let payload_length = u16::from_be_bytes([bytes[3], bytes[4]]);

        Ok(Self {
            frame_type,
            frame_number,
            payload_length,
        })
    }
}

impl Into<[u8; 5]> for FrameHeader {
    fn into(self) -> [u8; 5] {
        let mut bytes = [0; 5];
        bytes[0] = self.frame_type.into();
        bytes[1..3].copy_from_slice(&self.frame_number.to_be_bytes());
        bytes[3..5].copy_from_slice(&self.payload_length.to_be_bytes());
        bytes
    }
}

#[derive(Debug, PartialEq)]
pub struct RawFrame<'a> {
    pub header: FrameHeader,
    pub payload: &'a [u8],
}

const CRC: crc::Crc<u16> = crc::Crc::<u16>::new(&crc::CRC_16_USB);

pub trait Writer {
    type Error;
    fn write(&mut self, bytes: &[u8]) -> Result<(), Self::Error>;
}

#[cfg(any(features = "std", test))]
impl<'a> Writer for std::io::Cursor<&mut [u8]> {
    type Error = std::io::Error;
    fn write(&mut self, bytes: &[u8]) -> Result<(), Self::Error> {
        std::io::Write::write(self, bytes).map(|_| ())
    }
}

#[cfg(not(any(features = "std", test)))]
impl<'a> Writer for no_std_io::io::Cursor<&mut [u8]> {
    type Error = no_std_io::io::Error;
    fn write(&mut self, bytes: &[u8]) -> Result<(), Self::Error> {
        no_std_io::io::Write::write(self, bytes).map(|_| ())
    }
}


impl<'a> RawFrame<'a> {
    pub fn read_frame(bytes: &'a [u8]) -> Result<(RawFrame<'a>, usize), FrameError> {
        // Detect frame marker
        let (header, payload_offset) = FrameHeader::read_header(bytes).map_err(|(e, _)| e)?;
        let payload_length = header.payload_length as usize;
        let frame_length = FrameHeader::SIZE + payload_length + 2;  // marker + header + payload + crc
        if bytes.len() < payload_offset + payload_length + 2 {
            return Err(FrameError::InsufficientLength);
        }

        let payload = &bytes[payload_offset..payload_offset + payload_length];
        let actual_crc = u16::from_be_bytes(bytes[payload_offset + payload_length..payload_offset + payload_length + 2].try_into().unwrap());
        let mut digest = CRC.digest();
        let header_bytes: [u8; 5] = header.into();
        digest.update(&[FRAME_MARKER]);
        digest.update(&header_bytes);
        digest.update(payload);
        let expected_crc = !digest.finalize();
        if actual_crc != expected_crc {
            return Err(FrameError::CrcMismatch {
                expected: expected_crc,
                actual: actual_crc,
                header,
            });
        }

        Ok((RawFrame {
            header,
            payload,
        }, payload_offset + frame_length))
    }

    pub fn read_frame_payload(header: FrameHeader, bytes: &'a [u8]) -> Result<(RawFrame<'a>, usize), FrameError> {
        let payload_length = header.payload_length as usize;
        if bytes.len() < payload_length + 2 {
            return Err(FrameError::InsufficientLength);
        }
        let payload = &bytes[..payload_length];
        let actual_crc = u16::from_be_bytes(bytes[payload_length..payload_length + 2].try_into().unwrap());
        let mut digest = CRC.digest();
        let header_bytes: [u8; 5] = header.into();
        digest.update(&[FRAME_MARKER]);
        digest.update(&header_bytes);
        digest.update(payload);
        let expected_crc = !digest.finalize();
        if actual_crc != expected_crc {
            return Err(FrameError::CrcMismatch {
                expected: expected_crc,
                actual: actual_crc,
                header,
            });
        }

        Ok((RawFrame {
            header,
            payload,
        }, payload_length + 2))
    }

    pub fn write_frame<W: Writer>(&self, writer: &mut W) -> Result<(), W::Error> {
        let mut bytes = [0; 1 + 5];
        bytes[0] = FRAME_MARKER;
        let header_bytes: [u8; 5] = self.header.into();
        bytes[1..6].copy_from_slice(&header_bytes);
        writer.write(&bytes)?;
        writer.write(self.payload)?;
        let mut digest = CRC.digest();
        digest.update(&bytes);
        digest.update(&self.payload[..self.header.payload_length as usize]);
        let crc = !digest.finalize();
        writer.write(&crc.to_be_bytes())?;
        Ok(())
    }
    pub fn calculate_crc(&self) -> u16 {
        let header_bytes: [u8; 5] = self.header.into();
        let mut digest = CRC.digest();
        digest.update(&[FRAME_MARKER]);
        digest.update(&header_bytes);
        digest.update(&self.payload[..self.header.payload_length as usize]);
        !digest.finalize()
    }
}

#[derive(Debug)]
pub enum Frame<'a> {
    QueryVersionRequest(QueryVersionRequestFrame),
    QueryVersionResponse(QueryVersionResponseFrame<'a>),
    ReadMemoryRequest(ReadMemoryRequestFrame<'a>),
    ReadMemoryResponse(ReadMemoryResponseFrame<'a>),
    WriteMemoryRequest(WriteMemoryRequestFrame<'a>),
    WriteMemoryResponse(WriteMemoryResponseFrame<'a>),
    RunRequest(RunRequestFrame<'a>),
    RunResponse(RunResponseFrame<'a>),
    ErrorResponse(ErrorResponseFrame<'a>),
}

impl<'a> TryFrom<RawFrame<'a>> for Frame<'a> {
    type Error = FrameError;
    fn try_from(raw_frame: RawFrame<'a>) -> Result<Self, Self::Error> {
        match raw_frame.header.frame_type {
            FrameTypeAndDirection::Request(FrameType::QueryVersion) => {
                Ok(Self::QueryVersionRequest(QueryVersionRequestFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Response(FrameType::QueryVersion) => {
                Ok(Self::QueryVersionResponse(QueryVersionResponseFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Request(FrameType::ReadMemory) => {
                Ok(Self::ReadMemoryRequest(ReadMemoryRequestFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Response(FrameType::ReadMemory) => {
                Ok(Self::ReadMemoryResponse(ReadMemoryResponseFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Request(FrameType::WriteMemory) => {
                Ok(Self::WriteMemoryRequest(WriteMemoryRequestFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Response(FrameType::WriteMemory) => {
                Ok(Self::WriteMemoryResponse(WriteMemoryResponseFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Request(FrameType::Run) => {
                Ok(Self::RunRequest(RunRequestFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Response(FrameType::Run) => {
                Ok(Self::RunResponse(RunResponseFrame::try_from(raw_frame)?))
            },
            FrameTypeAndDirection::Request(FrameType::ErrorResponse) => {
                Err(Self::Error::InvalidFrameType)
            },
            FrameTypeAndDirection::Response(FrameType::ErrorResponse) => {
                Ok(Self::ErrorResponse(ErrorResponseFrame::try_from(raw_frame)?))
            },
        }
    }
}

impl<'a> Frame<'a> {
    pub fn frame_header(&self) -> &FrameHeader {
        match self {
            Self::QueryVersionRequest(frame) => &frame.header,
            Self::QueryVersionResponse(frame) => &frame.raw.header,
            Self::ReadMemoryRequest(frame) => &frame.raw.header,
            Self::ReadMemoryResponse(frame) => &frame.raw.header,
            Self::WriteMemoryRequest(frame) => &frame.raw.header,
            Self::WriteMemoryResponse(frame) => &frame.raw.header,
            Self::RunRequest(frame) => &frame.raw.header,
            Self::RunResponse(frame) => &frame.raw.header,
            Self::ErrorResponse(frame) => &frame.raw.header,
        }
    }
}

impl<'a> Into<RawFrame<'a>> for Frame<'a> {
    fn into(self) -> RawFrame<'a> {
        match self {
            Self::QueryVersionRequest(frame) => frame.into(),
            Self::QueryVersionResponse(frame) => frame.into(),
            Self::ReadMemoryRequest(frame) => frame.into(),
            Self::ReadMemoryResponse(frame) => frame.into(),
            Self::WriteMemoryRequest(frame) => frame.into(),
            Self::WriteMemoryResponse(frame) => frame.into(),
            Self::RunRequest(frame) => frame.into(),
            Self::RunResponse(frame) => frame.into(),
            Self::ErrorResponse(frame) => frame.into(),
        }
    }
}

#[derive(Debug, PartialEq)]
pub struct QueryVersionRequestFrame {
    header: FrameHeader,
}

impl QueryVersionRequestFrame {
    pub fn new(frame_number: u16) -> Self {
        Self {
            header: FrameHeader {
                frame_type: FrameTypeAndDirection::Request(FrameType::QueryVersion),
                frame_number,
                payload_length: 0,
            },
        }
    }
}

impl<'a> Into<RawFrame<'a>> for QueryVersionRequestFrame {
    fn into(self) -> RawFrame<'a> {
        RawFrame {
            header: self.header,
            payload: &[],
        }
    }
}
impl<'a> TryFrom<RawFrame<'a>> for QueryVersionRequestFrame {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length != 0 || raw.payload.len() != 0 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            header: raw.header,
        })
    }
}

#[derive(Debug, PartialEq)]
pub struct QueryVersionResponseFrame<'a> {
    raw: RawFrame<'a>,
}

impl<'a> QueryVersionResponseFrame<'a> {
    pub fn new(frame_number: u16, buffer: &'a mut [u8], version: u32, max_payload_size: u16) -> Result<Self, FrameError> {
        if buffer.len() < 6 {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&version.to_be_bytes());
        buffer[4..6].copy_from_slice(&max_payload_size.to_be_bytes());
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Response(FrameType::QueryVersion),
                    frame_number,
                    payload_length: 6,
                },
                payload: buffer,
            },
        })
    }

    pub fn version(&self) -> u32 {
        u32::from_be_bytes(self.raw.payload[..4].try_into().unwrap())
    }
    pub fn max_payload_size(&self) -> u16 {
        u16::from_be_bytes(self.raw.payload[4..6].try_into().unwrap())
    }
}

impl<'a> Into<RawFrame<'a>> for QueryVersionResponseFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for QueryVersionResponseFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length != 6 || raw.payload.len() != 6 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw,
        })
    }
}


#[derive(Debug)]
pub struct ReadMemoryRequestFrame<'a> {
    pub raw: RawFrame<'a>,
}

impl<'a> ReadMemoryRequestFrame<'a> {
    pub fn new(frame_number: u16, buffer: &'a mut [u8], address: u32, length: u16) -> Result<Self, FrameError> {
        if buffer.len() < 6 {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&address.to_be_bytes());
        buffer[4..6].copy_from_slice(&length.to_be_bytes());
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Request(FrameType::ReadMemory),
                    frame_number,
                    payload_length: 6,
                },
                payload: buffer,
            },
        })
    }

    pub fn address(&self) -> u32 {
        u32::from_be_bytes(self.raw.payload[..4].try_into().unwrap())
    }
    pub fn length(&self) -> u16 {
        u16::from_be_bytes(self.raw.payload[4..6].try_into().unwrap())
    }
}
impl<'a> Into<RawFrame<'a>> for ReadMemoryRequestFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for ReadMemoryRequestFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length != 6 || raw.payload.len() != 6 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw,
        })
    }
}

#[derive(Debug)]
pub struct ReadMemoryResponseFrame<'a> {
    raw: RawFrame<'a>,
}

impl<'a> ReadMemoryResponseFrame<'a> {
    pub fn new(frame_number: u16, data: &'a [u8]) -> Result<Self, FrameError> {
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Response(FrameType::ReadMemory),
                    frame_number,
                    payload_length: data.len() as u16,
                },
                payload: data,
            },
        })
    }
    pub fn data(&self) -> &'a [u8] {
        self.raw.payload
    }
}
impl<'a> Into<RawFrame<'a>> for ReadMemoryResponseFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for ReadMemoryResponseFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        Ok(Self {
            raw,
        })
    }
}

#[derive(Debug)]
pub struct WriteMemoryRequestFrame<'a> {
    raw: RawFrame<'a>,
}

impl<'a> WriteMemoryRequestFrame<'a> {
    pub fn new(frame_number: u16, buffer: &'a mut [u8], address: u32, data: &[u8]) -> Result<Self, FrameError> {
        if buffer.len() < 4 + data.len() {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&address.to_be_bytes());
        buffer[4..4 + data.len()].copy_from_slice(data);
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Request(FrameType::WriteMemory),
                    frame_number,
                    payload_length: 4 + data.len() as u16,
                },
                payload: buffer,
            },
        })
    }
    pub fn new_inplace(frame_number: u16, buffer: &'a mut [u8], address: u32) -> Result<Self, FrameError> {
        if buffer.len() < 4 {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&address.to_be_bytes());
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Request(FrameType::WriteMemory),
                    frame_number,
                    payload_length: buffer.len() as u16,
                },
                payload: buffer,
            },
        })
    }

    pub fn address(&self) -> u32 {
        u32::from_be_bytes(self.raw.payload[..4].try_into().unwrap())
    }
    pub fn data(&self) -> &'a [u8] {
        &self.raw.payload[4..]
    }
}
impl<'a> Into<RawFrame<'a>> for WriteMemoryRequestFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for WriteMemoryRequestFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length < 4 || raw.payload.len() < 4 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw,
        })
    }
}

#[derive(Debug)]
pub struct WriteMemoryResponseFrame<'a> {
    #[allow(unused)]
    raw: RawFrame<'a>,
}

impl<'a> WriteMemoryResponseFrame<'a> {
    pub fn new(frame_number: u16) -> Result<Self, FrameError> {
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Response(FrameType::WriteMemory),
                    frame_number,
                    payload_length: 0,
                },
                payload: &[],
            },
        })
    }
}

impl<'a> Into<RawFrame<'a>> for WriteMemoryResponseFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for WriteMemoryResponseFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length != 0 || raw.payload.len() != 0 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw,
        })
    }
}

#[derive(Debug)]
pub struct RunRequestFrame<'a> {
    raw: RawFrame<'a>,
}

impl<'a> RunRequestFrame<'a> {
    pub fn new(frame_number: u16, buffer: &'a mut [u8], address: u32) -> Result<Self, FrameError> {
        if buffer.len() < 4 {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&address.to_be_bytes());
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Request(FrameType::Run),
                    frame_number,
                    payload_length: 4,
                },
                payload: buffer,
            },
        })
    }

    pub fn address(&self) -> u32 {
        u32::from_be_bytes(self.raw.payload[..4].try_into().unwrap())
    }
}
impl<'a> Into<RawFrame<'a>> for RunRequestFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for RunRequestFrame<'a> {
    type Error = FrameError;
    fn try_from(raw: RawFrame<'a>) -> Result<Self, Self::Error> {
        if raw.header.payload_length != 4 || raw.payload.len() != 4 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw,
        })
    }
}

#[derive(Debug)]
pub struct RunResponseFrame<'a> {
    raw: RawFrame<'a>,
}
impl<'a> RunResponseFrame<'a> {
    pub fn new(frame_number: u16) -> Result<Self, FrameError> {
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Response(FrameType::Run),
                    frame_number,
                    payload_length: 0,
                },
                payload: &[],
            },
        })
    }
}
impl<'a> Into<RawFrame<'a>> for RunResponseFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for RunResponseFrame<'a> {
    type Error = FrameError;
    fn try_from(value: RawFrame<'a>) -> Result<Self, Self::Error> {
        if value.header.payload_length != 0 || value.payload.len() != 0 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw: value,
        })
    }
}

#[derive(Debug)]
pub struct ErrorResponseFrame<'a> {
    raw: RawFrame<'a>,
}
impl<'a> ErrorResponseFrame<'a> {
    pub fn new(frame_number: u16, buffer: &'a mut [u8], error_code: u32) -> Result<Self, FrameError> {
        if buffer.len() < 4 {
            return Err(FrameError::InsufficientLength);
        }
        buffer[..4].copy_from_slice(&error_code.to_be_bytes());
        Ok(Self {
            raw: RawFrame {
                header: FrameHeader {
                    frame_type: FrameTypeAndDirection::Response(FrameType::Run),
                    frame_number,
                    payload_length: 4,
                },
                payload: buffer,
            },
        })
    }
    pub fn error_code(&self) -> u32 {
        u32::from_be_bytes(self.raw.payload[..4].try_into().unwrap())
    }
}
impl<'a> Into<RawFrame<'a>> for ErrorResponseFrame<'a> {
    fn into(self) -> RawFrame<'a> {
        self.raw
    }
}
impl<'a> TryFrom<RawFrame<'a>> for ErrorResponseFrame<'a> {
    type Error = FrameError;
    fn try_from(value: RawFrame<'a>) -> Result<Self, Self::Error> {
        if value.header.payload_length != 4 || value.payload.len() != 4 {
            return Err(FrameError::InvalidLength);
        }
        Ok(Self {
            raw: value,
        })
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_read_no_marker() {
        let bytes = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        assert_eq!(result, FrameError::NoFrameMarker);
    }

    #[test]
    fn test_read_marker_beginning() {
        let bytes = [FRAME_MARKER, 0x00, 0xaa, 0x55, 0x00, 0x00, 0x03, 0x04];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        match result {
            #[allow(unused_variables)]
            FrameError::CrcMismatch { expected, actual, header } => {
                assert_eq!(header, FrameHeader { frame_type: FrameTypeAndDirection::Request(FrameType::QueryVersion), frame_number: 0xaa55, payload_length: 0x0000 });
            },
            _ => panic!("Unexpected error: {:?}", result),
        }
    }

    #[test]
    fn test_read_marker_skip_2() {
        let bytes = [0xa5, 0xff, FRAME_MARKER, 0x00, 0xaa, 0x55, 0x00, 0x00, 0x03, 0x04];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        match result {
            #[allow(unused_variables)]
            FrameError::CrcMismatch { expected, actual, header } => {
                assert_eq!(header, FrameHeader { frame_type: FrameTypeAndDirection::Request(FrameType::QueryVersion), frame_number: 0xaa55, payload_length: 0x0000 });
            },
            _ => panic!("Unexpected error: {:?}", result),
        }
    }

    #[test]
    fn test_read_marker_skip_2_premature_header_0() {
        let bytes = [0xa5, 0xff, FRAME_MARKER];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        assert_eq!(result, FrameError::InsufficientLength);
    }
    #[test]
    fn test_read_marker_skip_2_premature_header_1() {
        let bytes = [0xa5, 0xff, FRAME_MARKER, 0x00, 0xaa, 0x55, 0x00, 0x00, 0x03];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        assert_eq!(result, FrameError::InsufficientLength);
    }
    #[test]
    fn test_read_marker_skip_2_payload_length() {
        let bytes = [0xa5, 0xff, FRAME_MARKER, 0x00, 0xaa, 0x55, 0x00, 0x01, 0x03, 0x04];
        let result = RawFrame::read_frame(&bytes).unwrap_err();
        assert_eq!(result, FrameError::InsufficientLength);
    }

    #[test]
    fn test_frame_write_read() {
        let mut buffer = [0; 6];
        let mut write_buffer = [0u8; 14];
        let frame = QueryVersionResponseFrame::new(0xaa55, &mut buffer, 0x12345678, 0xff00).unwrap();
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let mut cursor = std::io::Cursor::new(&mut write_buffer[..]);
        raw_frame.write_frame(&mut cursor).unwrap();
        println!("{:?}", &write_buffer);
        let (raw_frame, _) = RawFrame::read_frame(&write_buffer[..]).unwrap();
        let decoded = QueryVersionResponseFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.version(), 0x12345678);
        assert_eq!(decoded.max_payload_size(), 0xff00);
    }

    #[test]
    fn test_query_version_request() {
        let frame = QueryVersionRequestFrame::new(0xaa55);
        let header = frame.header.clone();
        let raw_frame: RawFrame<'static> = frame.into();
        let decoded = QueryVersionRequestFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.header);
    }

    #[test]
    fn test_query_version_response() {
        let mut buffer = [0; 6];
        let frame = QueryVersionResponseFrame::new(0xaa55, &mut buffer, 0x12345678, 0xff00).unwrap();
        assert_eq!(frame.version(), 0x12345678);
        assert_eq!(frame.max_payload_size(), 0xff00);
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = QueryVersionResponseFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.version(), 0x12345678);
        assert_eq!(decoded.max_payload_size(), 0xff00);
    }

    #[test]
    fn test_read_memory_request() {
        let mut buffer = [0; 6];
        let frame = ReadMemoryRequestFrame::new(0xaa55, &mut buffer, 0x12345678, 0x0004).unwrap();
        assert_eq!(frame.address(), 0x12345678);
        assert_eq!(frame.length(), 0x0004);
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = ReadMemoryRequestFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.address(), 0x12345678);
        assert_eq!(decoded.length(), 0x0004);
    }

    #[test]
    fn test_read_memory_response() {
        let frame: ReadMemoryResponseFrame<'_> = ReadMemoryResponseFrame::new(0xaa55, &[0x12, 0x34, 0x56, 0x78]).unwrap();
        assert_eq!(frame.data(), &[0x12, 0x34, 0x56, 0x78]);
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = ReadMemoryResponseFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.data(), &[0x12, 0x34, 0x56, 0x78]);
    }

    #[test]
    fn test_write_memory_request() {
        let mut buffer = [0; 8];
        let frame = WriteMemoryRequestFrame::new(0xaa55, &mut buffer, 0x12345678, &[0x12, 0x34, 0x56, 0x78]).unwrap();
        assert_eq!(frame.address(), 0x12345678);
        assert_eq!(frame.data(), &[0x12, 0x34, 0x56, 0x78]);
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = WriteMemoryRequestFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.address(), 0x12345678);
        assert_eq!(decoded.data(), &[0x12, 0x34, 0x56, 0x78]);
    }

    #[test]
    fn test_write_memory_response() {
        let frame: WriteMemoryResponseFrame<'_> = WriteMemoryResponseFrame::new(0xaa55).unwrap();
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = WriteMemoryResponseFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
    }

    #[test]
    fn test_run_request() {
        let mut buffer = [0; 4];
        let frame = RunRequestFrame::new(0xaa55, &mut buffer, 0x12345678).unwrap();
        assert_eq!(frame.address(), 0x12345678);
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = RunRequestFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
        assert_eq!(decoded.address(), 0x12345678);
    }

    #[test]
    fn test_run_response() {
        let frame = RunResponseFrame::new(0xaa55).unwrap();
        let header = frame.raw.header.clone();
        let raw_frame: RawFrame = frame.into();
        let decoded = RunResponseFrame::try_from(raw_frame).unwrap();
        assert_eq!(&header, &decoded.raw.header);
    }
}