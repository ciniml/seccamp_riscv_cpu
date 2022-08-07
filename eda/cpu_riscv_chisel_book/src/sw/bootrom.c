#include <stdint.h>

extern void __attribute__((naked)) __attribute__((section(".isr_vector"))) isr_vector(void)
{
    asm volatile ("j _start");
    asm volatile ("j _start");
}

void __attribute__((noreturn)) main(void);

extern void __attribute__((naked)) _start(void)
{
    asm volatile ("la sp, stack_top");
    main();
}

static uint64_t write_gpio_csr(uint32_t value)
{
    asm volatile ("csrw 0x7c0, %0" :: "r" (value));
} 

static volatile uint32_t* const REG_GPIO_OUT = (volatile uint32_t*)0xA0000000;

void __attribute__((noreturn)) main(void)
{
    uint32_t led_out = 1;
    while(1) {
        *REG_GPIO_OUT = led_out;
        write_gpio_csr(led_out);
        led_out = (led_out << 1) | ((led_out >> 5) & 1);
        for(volatile uint32_t delay = 0; delay < 100000; delay++);
    }
}
