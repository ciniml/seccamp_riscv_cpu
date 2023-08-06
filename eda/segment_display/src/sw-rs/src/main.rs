#![no_std]
#![no_main]

use core::{arch::{global_asm, asm}, panic::PanicInfo, sync::atomic::{compiler_fence, Ordering}};
use bootrom_pac;

mod uart;
use uart::Uart;
use core::fmt::Write;

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


#[no_mangle]
pub extern "C" fn main() -> ! {
    let peripherals = bootrom_pac::Peripherals::take().unwrap();
    let mut uart = Uart::<bootrom_pac::UART>::init(peripherals.UART);
    
    writeln!(&mut uart, "Hello, RISC-V from Rust").unwrap();

    let mut led_out = 1;
    loop {
        peripherals.GPIO.led_out.write(|w| w.bits(led_out));
        led_out = ((led_out << 1) & 0x3f) | (led_out >> 5);
        //writeln!(&mut uart, "Hello, RISC-V from Rust").unwrap();
        for _ in 0..100000 { unsafe { asm!("nop"); } }
    }
}