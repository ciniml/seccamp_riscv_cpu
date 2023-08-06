use crate::frame::{Frame, RawFrame, FrameHeader};
use tokio::io::{AsyncReadExt, AsyncWriteExt};

#[derive(Debug)]
pub struct Client {
    next_frame_number: u16,
}

impl Client {
    pub fn new() -> Self {
        Self {
            next_frame_number: 1,
        }
    }

    fn next_frame_number(&mut self) -> u16 {
        let frame_number = self.next_frame_number;
        self.next_frame_number = self.next_frame_number.wrapping_add(1);
        frame_number
    }

    async fn send_frame_raw(&mut self, frame: RawFrame<'_>, writer: &mut (impl tokio::io::AsyncWrite + Unpin)) -> Result<(), std::io::Error> {
        let mut frame_buffer = vec![0; FrameHeader::SIZE + frame.header.payload_length as usize + 2];
        let mut cursor = std::io::Cursor::new(&mut frame_buffer[..]);
        frame.write_frame(&mut cursor)?;
        
        writer.write_all(&frame_buffer).await?;
        Ok(())
    }

    async fn receive_frame_raw(&mut self, reader: &mut (impl tokio::io::AsyncRead + Unpin)) -> Result<Vec<u8>, std::io::Error> {
        let mut header_buffer = [0; FrameHeader::SIZE];
        reader.read_exact(&mut header_buffer).await?;
        let header = FrameHeader::try_from(&header_buffer[1..])
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        let mut frame_buffer = vec![0; FrameHeader::SIZE + header.payload_length as usize + 2];
        reader.read_exact(&mut frame_buffer[FrameHeader::SIZE..]).await?;
        frame_buffer[..FrameHeader::SIZE].copy_from_slice(&header_buffer[..]);
        {
            // Just check the frame integrity.
            let _ = RawFrame::read_frame(&frame_buffer[..])
                .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        }

        Ok(frame_buffer)
    }

    pub async fn query_version(&mut self, reader: &mut (impl tokio::io::AsyncRead + Unpin), writer: &mut (impl tokio::io::AsyncWrite + Unpin)) -> Result<(u32, u16), std::io::Error> {
        let frame_number = self.next_frame_number();
        let frame = crate::frame::QueryVersionRequestFrame::new(frame_number);
        self.send_frame_raw(frame.into(), writer).await?;
        let raw_frame = self.receive_frame_raw(reader).await?;
        let (raw_frame, _) = RawFrame::read_frame(&raw_frame[..])
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        let frame = Frame::try_from(raw_frame)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        if frame.frame_header().frame_number != frame_number {
            return Err(std::io::Error::from(std::io::ErrorKind::Other));
        }
        let frame = match frame {
            Frame::QueryVersionResponse(frame) => frame,
            _ => return Err(std::io::Error::from(std::io::ErrorKind::Other)),
        };
        Ok((frame.version(), frame.max_payload_size()))
    }

    pub async fn read_memory(&mut self, address: u32, length: u16, reader: &mut (impl tokio::io::AsyncRead + Unpin), writer: &mut (impl tokio::io::AsyncWrite + Unpin)) -> Result<Vec<u8>, std::io::Error> {
        let frame_number = self.next_frame_number();
        let mut frame_buffer = [0; FrameHeader::SIZE + 6 + 2];
        let frame = crate::frame::ReadMemoryRequestFrame::new(frame_number, &mut frame_buffer, address, length)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        self.send_frame_raw(frame.into(), writer).await?;
        let raw_frame = self.receive_frame_raw(reader).await?;
        let (raw_frame, _) = RawFrame::read_frame(&raw_frame[..])
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        let frame = Frame::try_from(raw_frame)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        if frame.frame_header().frame_number != frame_number {
            return Err(std::io::Error::from(std::io::ErrorKind::Other));
        }
        let frame = match frame {
            Frame::ReadMemoryResponse(frame) => frame,
            _ => return Err(std::io::Error::from(std::io::ErrorKind::Other)),
        };
        Ok(frame.data().to_vec())
    }

    pub async fn write_memory(&mut self, address: u32, data: &[u8], reader: &mut (impl tokio::io::AsyncRead + Unpin), writer: &mut (impl tokio::io::AsyncWrite + Unpin)) -> Result<(), std::io::Error> {
        let frame_number = self.next_frame_number();
        let mut frame_buffer = vec![0; FrameHeader::SIZE + 6 + 2 + data.len()];
        let frame = crate::frame::WriteMemoryRequestFrame::new(frame_number, &mut frame_buffer, address, data)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        self.send_frame_raw(frame.into(), writer).await?;
        let raw_frame = self.receive_frame_raw(reader).await?;
        let (raw_frame, _) = RawFrame::read_frame(&raw_frame[..])
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        let frame = Frame::try_from(raw_frame)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        if frame.frame_header().frame_number != frame_number {
            return Err(std::io::Error::from(std::io::ErrorKind::Other));
        }
        let _frame = match frame {
            Frame::WriteMemoryResponse(frame) => frame,
            _ => return Err(std::io::Error::from(std::io::ErrorKind::Other)),
        };
        
        Ok(())
    }

    pub async fn run(&mut self, address: u32, reader: &mut (impl tokio::io::AsyncRead + Unpin), writer: &mut (impl tokio::io::AsyncWrite + Unpin)) -> Result<(), std::io::Error> {
        let frame_number = self.next_frame_number();
        let mut frame_buffer = [0; FrameHeader::SIZE + 4 + 2];
        let frame = crate::frame::RunRequestFrame::new(frame_number, &mut frame_buffer, address)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        self.send_frame_raw(frame.into(), writer).await?;
        let raw_frame = self.receive_frame_raw(reader).await?;
        let (raw_frame, _) = RawFrame::read_frame(&raw_frame[..])
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        let frame = Frame::try_from(raw_frame)
            .map_err(|err| std::io::Error::from(std::io::ErrorKind::Other))?;
        if frame.frame_header().frame_number != frame_number {
            return Err(std::io::Error::from(std::io::ErrorKind::Other));
        }
        let _frame = match frame {
            Frame::RunResponse(frame) => frame,
            _ => return Err(std::io::Error::from(std::io::ErrorKind::Other)),
        };
        
        Ok(())
    }
}

#[cfg(test)]
mod test {

    use core::task::Poll;

    use std::collections::VecDeque;
    use tokio::io::{ReadBuf, AsyncRead};
    use tokio::select;
    use tokio_util::io::StreamReader;

    use super::*;
    use crate::frame::QueryVersionRequestFrame;
    use crate::server::*;
    use crate::server::test::*;

    #[test]
    fn test_next_frame_number() {
        let mut client = Client::new();
        assert_eq!(client.next_frame_number(), 1);
        assert_eq!(client.next_frame_number(), 2);
        assert_eq!(client.next_frame_number(), 3);
    }

    struct SenderWriter(tokio::sync::mpsc::UnboundedSender<u8>);
    impl tokio::io::AsyncWrite for SenderWriter {
        fn poll_write(self: std::pin::Pin<&mut Self>, cx: &mut std::task::Context<'_>, buf: &[u8]) -> std::task::Poll<Result<usize, std::io::Error>> {
            for item in buf {
                self.0.send(*item).unwrap();
            }
            std::task::Poll::Ready(Ok(buf.len()))
        }
        fn poll_flush(self: core::pin::Pin<&mut Self>, cx: &mut core::task::Context<'_>) -> core::task::Poll<std::io::Result<()>> {
            std::task::Poll::Ready(Ok(()))
        }
        fn poll_shutdown(self: core::pin::Pin<&mut Self>, cx: &mut core::task::Context<'_>) -> core::task::Poll<std::io::Result<()>> {
            std::task::Poll::Ready(Ok(()))
        }
    }

    struct ReceiverReader(tokio::sync::mpsc::UnboundedReceiver<u8>);
    impl tokio::io::AsyncRead for ReceiverReader {
        fn poll_read(
                    self: core::pin::Pin<&mut Self>,
                    cx: &mut core::task::Context<'_>,
                    buf: &mut ReadBuf,
                ) -> core::task::Poll<std::io::Result<()>> {
            if buf.remaining() == 0 {
                std::task::Poll::Ready(Ok(()))
            } else {
                match unsafe{ &mut self.get_unchecked_mut().0 } .poll_recv(cx) {
                    Poll::Ready(Some(a)) => {
                        buf.put_slice(&[a]);
                        Poll::Ready(Ok(()))
                    },
                    Poll::Ready(None) => Poll::Ready(Ok(())),
                    Poll::Pending => {
                        cx.waker().clone().wake();
                        Poll::Pending
                    },
                }
            }
        }
    }

    #[tokio::test(flavor = "multi_thread")]
    async fn test_query_version() {
        const MAX_FRAME_SIZE: usize = 128;
        let (mut client_tx, mut server_rx) = tokio::sync::mpsc::unbounded_channel::<u8>();
        let (mut server_tx, mut client_rx) = tokio::sync::mpsc::unbounded_channel::<u8>();
        let (mut shutdown_req, mut shutdown_recv) = tokio::sync::mpsc::unbounded_channel::<bool>();
        let server_task = async move {
            println!("starting server task");

            let mut handler = TestServerHandler::new();
            handler.version = 0x12345678;
            let mut server = Server::<_, MAX_FRAME_SIZE>::new(handler);
            
            loop {
                select! {
                    _ = shutdown_recv.recv() => {
                        println!("shutdown received.");
                        break;
                    },
                    a = server_rx.recv() => {
                        if let Some(a) = a {
                            let mut reader = std::io::Cursor::new([a]);
                            let mut writer = std::io::Cursor::new(&mut [][..]);
                            server.process(&mut reader, &mut writer);
                        }
                    },
                    _ = async {} => {
                        let mut reader = std::io::Cursor::new(&[]);
                        let mut writer = std::io::Cursor::new([0u8; 1]);
                        server.process(&mut reader, &mut writer);
                        let position = writer.position();
                        if position > 0 {
                            let a = writer.into_inner()[0];
                            server_tx.send(a).ok();
                        }
                    },
                }
            }
            println!("finished server task");
        };
        
        let client_task = async move {
            println!("starting client task");
            let mut client = Client::new();
            let mut reader = ReceiverReader(client_rx);
            let mut writer = SenderWriter(client_tx);
            println!("query version started.");
            let result = client.query_version(&mut reader, &mut writer).await;
            println!("query version finished.");
            let (version, max_payload_size) = result.unwrap();
            assert_eq!(version, 0x12345678);
            let expected_max_payload_size = MAX_FRAME_SIZE - FrameHeader::SIZE - 2;
            assert_eq!(max_payload_size, expected_max_payload_size as u16);
            println!("finished client task");
        };

        tokio::spawn(server_task);
        let result = tokio::spawn(client_task).await;
        shutdown_req.send(true).ok();
        result.unwrap();
    }
}