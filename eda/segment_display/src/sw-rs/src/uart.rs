use bootrom_pac;
use embedded_hal_nb::serial::*;

pub struct Uart<UART> {
    uart: UART,
}
impl Uart<bootrom_pac::UART> {
    pub fn init(uart: bootrom_pac::UART) -> Self {
        Self {
            uart,
        }
    }
}
impl embedded_hal::serial::ErrorType for Uart<bootrom_pac::UART> {
    type Error = embedded_hal::serial::ErrorKind;
}
impl embedded_hal_nb::serial::Write<u8> for Uart<bootrom_pac::UART> {
    fn write(&mut self, word: u8) -> embedded_hal_nb::nb::Result<(), Self::Error> {
        if self.uart.status.read().txready().bit_is_clear() { // THR is not empty
            Err(embedded_hal_nb::nb::Error::WouldBlock)
        } else {
            self.uart.txd().write(|w| w.data().bits(word));
            Ok(())
        }
    }
    fn flush(&mut self) -> embedded_hal_nb::nb::Result<(), Self::Error> {
        if self.uart.status.read().txready().bit_is_set() {
            Ok(())
        } else {
            Err(embedded_hal_nb::nb::Error::WouldBlock)
        }
    }
}
impl embedded_hal_nb::serial::Read<u8> for Uart<bootrom_pac::UART> {
    fn read(&mut self) -> embedded_hal_nb::nb::Result<u8, Self::Error> {
        if self.uart.status.read().rxready().bit_is_set() {
            Ok(self.uart.rxd().read().rxd().bits())
        } else {
            Err(embedded_hal_nb::nb::Error::WouldBlock)
        }
    }
}
impl core::fmt::Write for Uart<bootrom_pac::UART> {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        for byte in s.as_bytes().into_iter() {
            embedded_hal_nb::nb::block!(self.write(*byte)).map_err(|_| core::fmt::Error)?
        }
        Ok(())
    }
}

fn read_line<const N: usize>(uart: &mut Uart<bootrom_pac::UART>, line: &mut heapless::String<N>) {
    loop {
        let c = embedded_hal_nb::nb::block!(uart.read()).unwrap();
        match c {
            0x08 => {
                if line.len() > 0 {
                    line.pop();
                }
            },
            0x0d => {}, // Ignore CR
            0x0a => {
                return;
            },
            c => {
                let valid = match char::from_u32(c as u32) {
                    Some(c) => line.push(c).is_ok(),
                    None => false,
                };
                if !valid {
                    embedded_hal_nb::nb::block!(uart.write(0x0b)).unwrap();
                } else {
                    embedded_hal_nb::nb::block!(uart.write(c)).unwrap();
                }
            }
        }
    }
}