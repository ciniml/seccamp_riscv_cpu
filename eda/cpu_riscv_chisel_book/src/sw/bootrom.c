#include <stdint.h>
#include <stdbool.h>

extern void __attribute__((naked)) __attribute__((section(".isr_vector"))) isr_vector(void)
{
    asm volatile ("j _start");
}

extern void __attribute__((naked)) __attribute__((noreturn)) trap_handler(void)
{
    while(true);
}

extern void __attribute__((naked)) _start(void)
{
    asm volatile (
                  "la t0, trap_handler; " /* トラップベクタ初期化 */ \
                  "csrw mtvec, t0;      " /*                    */ \
                  "li a0, 0;            " /* success判定        */ \
                  "ecall                " /* トラップ           */ \
    );
}