OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    mem(rx)  : ORIGIN = 0x00000000, LENGTH = 8192
}

SECTIONS
{
  .isr_vector : {
      . = ALIGN(4);
      KEEP(*(.isr_vector))
      . = ALIGN(4);
  } >mem
  .text : { 
      . = ALIGN(4);
      *(.text) 
      . = ALIGN(4);
  } >mem
  .rodata : { 
      . = ALIGN(4);
      *(.rodata) 
      . = ALIGN(4);
  } >mem
  .data : {
      PROVIDE(_data_start = .);
      PROVIDE(_data_rom_start = LOADADDR(.data));
      . = ALIGN(4);
      *(.sdata .sdata.* .data .data.*)
      . = ALIGN(4);
      PROVIDE(_data_end = .);
  } >mem
  .bss : { 
      PROVIDE(_bss_start = .);
      *(.sbss .sbss.* .bss .bss.*) 
      . = ALIGN(4);
      PROVIDE(_bss_end = .);
  } >mem
  PROVIDE(stack_bottom = .);
  PROVIDE(_end = .);
  PROVIDE(end = .);
  PROVIDE(stack_top = ORIGIN(mem) + LENGTH(mem) - 4);
}
