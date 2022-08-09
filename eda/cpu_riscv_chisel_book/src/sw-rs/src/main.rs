#![no_std]
#![no_main]

use core::{arch::{global_asm, asm}, panic::PanicInfo, sync::atomic::{compiler_fence, Ordering}};
use core::fmt::Write;
use hal::serial::nb::Read;
use bootrom_pac;
use embedded_hal as hal;

global_asm!(r#"
.section .isr_vector,"ax",@progbits
    j _start
.section .text,"ax",@progbits
_start:
    la sp, ramend
    addi sp, sp, -4
    csrw mstatus, zero
    csrw mip, zero
    csrw mie, zero
    la t0, trap_handler
    csrw mtvec, zero
    j start_rust
"#);

extern "C" {
    static mut _bss_start: u32;
    static mut _bss_end: u32;
    static mut _data_start: u32;
    static mut _data_end: u32;
    static _data_rom_start: u32;
}

#[no_mangle]
pub unsafe extern "C" fn trap_handler() {
    loop{};
}

#[no_mangle]
pub unsafe extern "C" fn init() {
    let mut bss: *mut u32 = &mut _bss_start;
    let bss_end: *mut u32 = &mut _bss_end;
    while bss < bss_end {
        core::ptr::write_volatile(bss, 0);
        bss = bss.offset(1);
    }
    let mut data: *mut u32 = &mut _data_start;
    let data_end: *mut u32 = &mut _data_end;
    let mut data_rom: *const u32 = &_data_rom_start;
    while data < data_end {
        core::ptr::write_volatile(data, core::ptr::read_volatile(data_rom));
        data_rom = data_rom.offset(1);
        data = data.offset(1);
    }
    compiler_fence(Ordering::SeqCst);
}

#[no_mangle]
pub unsafe extern "C" fn start_rust() {
    //init();
    main();
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

struct Uart<UART> {
    uart: UART,
}
impl Uart<bootrom_pac::UART> {
    pub fn init(uart: bootrom_pac::UART) -> Self {
        Self {
            uart,
        }
    }
}
impl hal::serial::ErrorType for Uart<bootrom_pac::UART> {
    type Error = hal::serial::ErrorKind;
}
impl hal::serial::nb::Write<u8> for Uart<bootrom_pac::UART> {
    fn write(&mut self, word: u8) -> hal::nb::Result<(), Self::Error> {
        if self.uart.status.read().txready().bit_is_clear() { // THR is not empty
            Err(hal::nb::Error::WouldBlock)
        } else {
            self.uart.txd().write(|w| w.data().bits(word));
            Ok(())
        }
    }
    fn flush(&mut self) -> hal::nb::Result<(), Self::Error> {
        if self.uart.status.read().txready().bit_is_set() {
            Ok(())
        } else {
            Err(hal::nb::Error::WouldBlock)
        }
    }
}
impl hal::serial::nb::Read<u8> for Uart<bootrom_pac::UART> {
    fn read(&mut self) -> hal::nb::Result<u8, Self::Error> {
        if self.uart.status.read().rxready().bit_is_set() {
            Ok(self.uart.rxd().read().rxd().bits())
        } else {
            Err(hal::nb::Error::WouldBlock)
        }
    }
}
impl core::fmt::Write for Uart<bootrom_pac::UART> {
    fn write_str(&mut self, s: &str) -> core::fmt::Result {
        use hal::serial::nb::Write;
        for byte in s.as_bytes().into_iter() {
            hal::nb::block!(self.write(*byte)).map_err(|_| core::fmt::Error)?
        }
        Ok(())
    }
}

fn read_line<const N: usize>(uart: &mut Uart<bootrom_pac::UART>, line: &mut heapless::String<N>) {
    loop {
        let c = hal::nb::block!(uart.read()).unwrap();
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
                use hal::serial::nb::Write;
                if !valid {
                    hal::nb::block!(uart.write(0x0b)).unwrap();
                } else {
                    hal::nb::block!(uart.write(c)).unwrap();
                }
            }
        }
    }
}

#[no_mangle]
pub extern "C" fn main() -> ! {
    let peripherals = bootrom_pac::Peripherals::take().unwrap();
    let mut uart = Uart::<bootrom_pac::UART>::init(peripherals.UART);
    
    writeln!(&mut uart, "Hello, RISC-V from Rust").unwrap();

    loop {
        writeln!(&mut uart, "Hello, RISC-V from Rust").unwrap();
    }
}