#![no_std]
#![no_main]

use core::{arch::{global_asm, asm}, panic::PanicInfo, sync::atomic::{compiler_fence, Ordering}, cell::RefCell};
use bootrom_pac;

mod uart;
use uart::{Uart, UartReader, UartWriter};
use core::fmt::Write;
use fwtool::server::{Server, ServerHandler};


#[allow(unused_imports)]
use riscv::asm;

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

static mut APPIMAGE_BUFFER: [u8; 8192] = [0; 8192];

#[derive(Debug)]
struct Handler {}

impl ServerHandler for Handler {
    fn on_query_version(&mut self) -> Result<u32, fwtool::server::ServerError> {
        Ok(1)
    }
    fn on_read_memory(&mut self, address: u32, buffer: &mut [u8]) -> Result<(), fwtool::server::ServerError> {
        let address = address as usize;
        if address + buffer.len()  > unsafe { APPIMAGE_BUFFER.len() } {
            Err(fwtool::server::ServerError::InvalidAddress)
        } else {
            unsafe {
                buffer.copy_from_slice(&APPIMAGE_BUFFER[address..address + buffer.len()]);
            }
            Ok(())
        }
    }
    fn on_write_memory(&mut self, address: u32, buffer: &[u8]) -> Result<(), fwtool::server::ServerError> {
        let address = address as usize;
        if address + buffer.len()  > unsafe { APPIMAGE_BUFFER.len() } {
            Err(fwtool::server::ServerError::InvalidAddress)
        } else {
            unsafe {
                APPIMAGE_BUFFER[address..address + buffer.len()].copy_from_slice(buffer);
            }
            Ok(())
        }
    }
    fn on_run(&mut self, address: u32) -> Result<(), fwtool::server::ServerError> {
        Ok(())
    }
    
}

#[no_mangle]
pub extern "C" fn main() -> ! {
    let peripherals = bootrom_pac::Peripherals::take().unwrap();
    let uart = RefCell::new(Uart::<bootrom_pac::UART>::init(peripherals.UART));

    let handler = Handler{};
    let mut server = Server::<_, 128>::new(handler);

    let mut led_out = 1;
    let mut reader = UartReader::new(&uart);
    let mut writer = UartWriter::new(&uart);
    loop {
        peripherals.GPIO.led_out.write(|w| w.bits(led_out));
        led_out = ((led_out << 1) & 0x3f) | (led_out >> 5);
        server.process(&mut reader, &mut writer);
    }
}