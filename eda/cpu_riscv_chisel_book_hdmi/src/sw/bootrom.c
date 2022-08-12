#include <stdint.h>
#include <stddef.h>

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
static volatile uint32_t* const REG_VRAM = (volatile uint32_t*)0xB0000000;  // VRAMの先頭アドレス
static volatile uint32_t* const REG_VIDEO_CONTROLLER = (volatile uint32_t*)0xB0020000L; // ビデオ・コントローラのレジスタ
// 画面の幅
#define VIDEO_WIDTH (1280/16)
// 画面の高さ
#define VIDEO_HEIGHT (720/16)

// 箱の幅
#define BOX_WIDTH (8)
// 箱の高さ
#define BOX_HEIGHT (8)

void* __attribute__((inline)) memset(void* dest, int ch, size_t count)
{
    uint8_t* dest_ = (uint8_t*)dest;
    while(count--) {
        *(dest_++) = ch;
    }
    return dest;
}

static void copy_from_vram(uint8_t* buffer, const uint32_t* vram, uint32_t xs, uint32_t ys, uint32_t xe, uint32_t ye)
{
    for(uint32_t y = ys; y < ye; y++) {
        const uint32_t* p = vram + y*VIDEO_WIDTH + xs;
        for(uint32_t x = xs; x < xe; x++) {
            *(buffer++) = *(p++);
        }
    }
}
static void copy_to_vram(uint32_t* vram, const uint8_t* buffer,  uint32_t xs, uint32_t ys, uint32_t xe, uint32_t ye)
{
    for(uint32_t y = ys; y < ye; y++) {
        uint32_t* p = vram + y*VIDEO_WIDTH + xs;
        for(uint32_t x = xs; x < xe; x++) {
            *(p++) = *(buffer++);
        }
    }
}
static void fill_vram(uint32_t* vram, uint8_t value, uint32_t xs, uint32_t ys, uint32_t xe, uint32_t ye)
{
    for(uint32_t y = ys; y < ye; y++) {
        uint32_t* p = vram + y*VIDEO_WIDTH + xs;
        for(uint32_t x = xs; x < xe; x++) {
            *(p++) = value;
        }
    }
}

void __attribute__((noreturn)) main(void)
{
    // 箱を描く矩形範囲の元の画像を保存しておくバッファ
    static uint8_t box_buffer[BOX_WIDTH*BOX_HEIGHT];
    uint32_t led_out = 1;

    // 背景を描画：白～紫の7本の帯を描画
    volatile uint32_t* vram_p = REG_VRAM;
    for(uint32_t y = 0; y < VIDEO_HEIGHT; y++) {
        for(uint32_t x = 0; x < VIDEO_WIDTH; x++, vram_p++) {
            if( x < VIDEO_WIDTH * 1 / 7) {
                *(vram_p) = 0b11111111;   // B+G+R
            }
            else if( x < VIDEO_WIDTH * 2 / 7) {
                *(vram_p) = 0b11000000;   // B
            }
            else if( x < VIDEO_WIDTH * 3 / 7) {
                *(vram_p) = 0b11111000;   // B+G
            }
            else if( x < VIDEO_WIDTH * 4 / 7) {
                *(vram_p) = 0b00111000;   // G
            }
            else if( x < VIDEO_WIDTH * 5 / 7) {
                *(vram_p) = 0b00111111;   // G+R
            }
            else if( x < VIDEO_WIDTH * 6 / 7) {
                *(vram_p) = 0b00000111;   // R
            }
            else {
                *(vram_p) = 0b11000111;   // B+R
            }
            // if((y & 3) == 0 || (x & 3) == 0) {
            //     *(vram_p) = 0;
            // }
        }
    }

    uint32_t bx = 0, by = 0;    // 箱の左上座標
    int32_t dx = 1, dy = 1;     // 箱の移動方向
    // 箱の描画位置の元画像のバッファを(0, 0)の位置の内容で初期化
    copy_from_vram(box_buffer, REG_VRAM, 0, 0, BOX_WIDTH, BOX_HEIGHT );

    uint32_t one_second_counter = 0;    // 1秒間分のカウンタ
    while(1) {
        // 垂直同期周波数が60[Hz]になっているので、
        // VSYNC待ちにより、ループは1/60[s]ごとに動作する
        while(!(*REG_VIDEO_CONTROLLER & 4));   // VSYNC待ち (VSYNCが1になるのを待つ)

        if( one_second_counter == 0 ) { // 1秒に1回処理をする
            *REG_GPIO_OUT = led_out;
            write_gpio_csr(led_out);
            led_out = (led_out << 1) | ((led_out >> 5) & 1);
        }
        if( one_second_counter == 59) { // 1秒経ったので0に戻す
            one_second_counter = 0;
        } else {
            one_second_counter++;
        }

        // 前に箱を描いた位置に、元画像バッファからコピーして、背景画像を復元
        copy_to_vram(REG_VRAM, box_buffer, bx, by, bx+BOX_WIDTH, by+BOX_HEIGHT);
        // 箱の座標を更新
        bx += dx;
        by += dy;
        // 端に到達したら移動方向を反転
        if( bx == 0 || bx + BOX_WIDTH == VIDEO_WIDTH ) {
            dx = -dx;
        }
        if( by == 0 || by + BOX_HEIGHT == VIDEO_HEIGHT ) {
            dy = -dy;
        }
        // 元画像バッファに箱の描画位置の元画像を保存
        copy_from_vram(box_buffer, REG_VRAM, bx, by, bx+BOX_WIDTH, by+BOX_HEIGHT);
        // 箱を描画 (黒で塗りつぶし)
        fill_vram(REG_VRAM, 0, bx, by, bx+BOX_WIDTH, by+BOX_HEIGHT);

        //for(volatile uint32_t delay = 0; delay < 100000; delay++);
    }
}
