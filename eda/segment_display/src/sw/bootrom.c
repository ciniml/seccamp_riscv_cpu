#include <stdint.h>
#include <stdbool.h>

extern void __attribute__((naked)) __attribute__((section(".isr_vector"))) isr_vector(void)
{
    asm volatile ("j start");              // Reset
    asm volatile ("j start");              // S-mode software interrupt
    asm volatile ("j start");              // VS-mode software interrupt
    asm volatile ("j start");              // M-mode software interrupt
    asm volatile ("j start");              // Reserved
    asm volatile ("j start");              // S-mode timer interrupt
    asm volatile ("j start");              // VS-mode timer interrupt
    asm volatile ("j start");              // M-mode timer interrupt
    asm volatile ("j start");              // Reserved
    asm volatile ("j start");              // S-mode external interrupt
    asm volatile ("j start");              // VS-mode external interrupt
    asm volatile ("j isr_extint_handler"); // M-mode external interrupt
}

static void enable_interrupt(void)
{
    asm volatile ("addi  a0, x0, 1");       // Set mtvec = 0x00000001 (vectored interrupt mode, vector base = 0x00000000)
    asm volatile ("csrw  mtvec, a0");       // /
    asm volatile ("csrsi mstatus, 0x8");    // Set mie in mstatus (bit 3)
    asm volatile ("addi  a0, x0, 0x400");   // Set meie in mie CSR (bit 11)
    asm volatile ("slli  a0, a0, 1");       //
    asm volatile ("csrs  mie, a0");         // /
}

void __attribute__((noreturn)) main(void);
extern uint32_t _bss_start;
extern uint32_t _bss_end;
// extern uint32_t _data_start;
// extern uint32_t _data_end;
// extern uint32_t _data_rom_start;
void init(void)
{
    uint32_t* bss_end = &_bss_end; 
    for(volatile uint32_t* bss = &_bss_start; bss < bss_end; bss++) {
        *bss = 0;
    }
    // uint32_t* data_end = &_data_end; 
    // volatile uint32_t* data_rom = &_data_rom_start; 
    // for(volatile uint32_t* data = &_data_start; data < data_end; data++, data_rom++) {
    //     *data = *data_rom;
    // }
}

extern void __attribute__((naked)) start(void)
{
    asm volatile ("la sp, ramend");
    asm volatile ("addi sp, sp, -4");
    init();
    main();
}


static volatile uint32_t* const REG_GPIO_LED_L =    (volatile uint32_t*)0xA0000000;
static volatile uint32_t* const REG_GPIO_LED_H =    (volatile uint32_t*)0xA0000010;
static volatile uint32_t* const REG_GPIO_MATRIX_L = (volatile uint32_t*)0xA0000020;
static volatile uint32_t* const REG_GPIO_MATRIX_H = (volatile uint32_t*)0xA0000030;
static volatile uint32_t* const REG_GPIO_LED =      (volatile uint32_t*)0xA0000040;
static volatile uint32_t* const REG_GPIO_SW_IN =    (volatile uint32_t*)0xA0000054;
static volatile uint32_t* const REG_UART_DATA =     (volatile uint32_t*)0xA0001000;
static volatile uint32_t* const REG_UART_STATUS =   (volatile uint32_t*)0xA0001004;

static const uint8_t hex_digit_pattern[16] = {
    0b00111111,
    0b00000110,
    0b01011011,
    0b01001111,
    0b01100110,
    0b01101101,
    0b01111101,
    0b00000111,
    0b01111111,
    0b01101111,
    0b01110111,
    0b01111100,
    0b00111001,
    0b01011110,
    0b01111001,
    0b01110001,
};

static void put_led_hex(uint32_t value)
{
    *REG_GPIO_LED_L = (hex_digit_pattern[(value >> 20)  & 0xf] << 0)
                    | (hex_digit_pattern[(value >> 16)  & 0xf] << 8)
                    | (hex_digit_pattern[(value >> 12)  & 0xf] << 16)
                    | (hex_digit_pattern[(value >> 8) & 0xf] << 24);
    *REG_GPIO_LED_H = (hex_digit_pattern[(value >> 4) & 0xf] << 0)
                    | (hex_digit_pattern[(value >> 0) & 0xf] << 8);
}

static bool uart_tx_ready(void) 
{
    return (*REG_UART_STATUS & 0x1) != 0;
}
static void uart_tx_byte(uint8_t byte)
{
    while( !uart_tx_ready() );
    *REG_UART_DATA = byte;
}
static uint8_t uart_rx_ready(void)
{
    return (*REG_UART_STATUS & 0x2) != 0;
}
static uint8_t uart_rx_byte(void)
{
    while(true) {
        uint32_t value = *REG_UART_DATA;
        if( value & 0x10000 ) {
            return value & 0xff;
        }
    }
}
static void uart_tx_string(const char* str)
{
    while(*str) {
        uart_tx_byte(*str++);
    }
}


static uint32_t uart_rx_data = 0;
void __attribute__((interrupt)) isr_extint_handler(void)
{
    uart_rx_data = *REG_UART_DATA;
}

void __attribute__((noreturn)) main(void)
{
    uint32_t counter = 0;
    uint64_t matrix_output = 1;
    uint32_t led_out = 1;
    const LED_BITS = 6;

    enable_interrupt();

    uart_tx_string("Hello, world!\n");
    for(;;) {
        put_led_hex(counter++);
        if( (counter & 0xffff) == 0xffff ) {
            // Update LEDs
            led_out = (led_out << 1) | (led_out >> (LED_BITS - 1));
            matrix_output = (matrix_output << 1) | (matrix_output >> 63);
        }
        
        const uint32_t switch_input = ~*REG_GPIO_SW_IN & 0xff;
        if( switch_input == 0 ) {
            *REG_GPIO_LED = led_out;
        } else if( switch_input & 0x40 ) {
            *REG_GPIO_LED = 0x55555555;
        } else if( switch_input & 0x80 ) {
            *REG_GPIO_LED = 0xAAAAAAAA;
        } else {
            *REG_GPIO_LED = switch_input;
        }
        *REG_GPIO_MATRIX_L = matrix_output & 0xffffffff;
        *REG_GPIO_MATRIX_H = matrix_output >> 32;

        if( uart_rx_data & 0x10000 ) {
            // Transmit received data.
            if( uart_tx_ready() ) {
                uart_tx_byte(uart_rx_data & 0xff);
                uart_rx_data = 0;
            }
        }
    }
}
