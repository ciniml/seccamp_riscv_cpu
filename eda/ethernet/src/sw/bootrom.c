#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <string.h>

static const uint32_t FREQ_HZ = 27000000;

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

typedef struct {
    uint32_t data;
    uint32_t status;
} uart_regs_t;

static volatile uint32_t* const REG_GPIO_LED_L =      (volatile uint32_t*)0xA0000000;
static volatile uint32_t* const REG_GPIO_LED_H =      (volatile uint32_t*)0xA0000010;
static volatile uint32_t* const REG_GPIO_MATRIX_L =   (volatile uint32_t*)0xA0000020;
static volatile uint32_t* const REG_GPIO_MATRIX_H =   (volatile uint32_t*)0xA0000030;
static volatile uint32_t* const REG_GPIO_LED =        (volatile uint32_t*)0xA0000040;
static volatile uint32_t* const REG_GPIO_SW_IN =      (volatile uint32_t*)0xA0000054;
static volatile uart_regs_t* const REG_UART =         (volatile uart_regs_t*)0xA0001000;
static volatile uint32_t* const REG_UART_STATUS =     (volatile uint32_t*)0xA0001004;
static volatile uint32_t* const REG_ETHERNET_DATA =   (volatile uint32_t*)0xA0002000;
static volatile uint32_t* const REG_ETHERNET_STATUS = (volatile uint32_t*)0xA0002004;
static volatile uart_regs_t* const REG_MSMP =         (volatile uart_regs_t*)0xA0003000;
static volatile uint32_t* const REG_COUNTER =         (volatile uint32_t*)0xA0004000;

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

volatile uint32_t a = 0;
volatile uint32_t b = 0;
volatile uint32_t c = 0;

static void put_led_hex(uint32_t value)
{
    *REG_GPIO_LED_L = (hex_digit_pattern[(value >> 20)  & 0xf] << 0)
                    | (hex_digit_pattern[(value >> 16)  & 0xf] << 8)
                    | (hex_digit_pattern[(value >> 12)  & 0xf] << 16)
                    | (hex_digit_pattern[(value >> 8) & 0xf] << 24);
    *REG_GPIO_LED_H = (hex_digit_pattern[(value >> 4) & 0xf] << 0)
                    | (hex_digit_pattern[(value >> 0) & 0xf] << 8);
}

static bool uart_tx_ready(volatile uart_regs_t* regs) 
{
    return (regs->status & 0x1) != 0;
}
static void uart_tx_byte(volatile uart_regs_t* regs, uint8_t byte)
{
    while( !uart_tx_ready(regs) );
    regs->data = byte;
}
static uint8_t uart_rx_ready(volatile uart_regs_t* regs)
{
    return (regs->status & 0x2) != 0;
}
static uint8_t uart_rx_byte(volatile uart_regs_t* regs)
{
    while(true) {
        uint32_t value = regs->data;
        if( value & 0x10000 ) {
            return value & 0xff;
        }
    }
}
static void uart_tx_string(volatile uart_regs_t* regs, const char* str)
{
    while(*str) {
        uart_tx_byte(regs, *str++);
    }
}

static void uart_tx_hex_4(volatile uart_regs_t* regs, uint8_t value)
{
    uart_tx_byte(regs, value < 10 ? '0' + value : 'A' + value - 10);
}
static void uart_tx_hex_8(volatile uart_regs_t* regs, uint8_t value)
{
    uart_tx_hex_4(regs, value >> 4);
    uart_tx_hex_4(regs, value & 0xf);
}
static void uart_tx_hex_16(volatile uart_regs_t* regs, uint16_t value)
{
    uart_tx_hex_8(regs, value >> 8);
    uart_tx_hex_8(regs, value & 0xff);
}
static void uart_tx_hex_32(volatile uart_regs_t* regs, uint32_t value)
{
    uart_tx_hex_16(regs, value >> 16);
    uart_tx_hex_16(regs, value & 0xffff);
}
static void uart_tx_hex_string(volatile uart_regs_t* regs, const uint8_t* data, size_t size)
{
    for(size_t i = 0; i < size; i++) {
        uart_tx_hex_8(regs, data[i]);
    }
}

static bool ethernet_tx_ready(void)
{
    return (*REG_ETHERNET_STATUS & 0x1) != 0;
}
static void ethernet_tx_byte(uint32_t byte_and_last)
{
    while( !ethernet_tx_ready() );
    *REG_ETHERNET_DATA = byte_and_last;
}
static uint32_t ethernet_rx_byte(void)
{
    return *REG_ETHERNET_DATA;
}


static uint32_t uart_rx_data = 0;
static uint32_t msmp_rx_data = 0;
void __attribute__((interrupt)) isr_extint_handler(void)
{
    if( uart_rx_ready(REG_UART)) uart_rx_data = REG_UART->data;
    if( uart_rx_ready(REG_MSMP)) msmp_rx_data = REG_MSMP->data;
}

//#define ETHERNET_LOOPBACK
#ifdef ETHERNET_LOOPBACK
#define MAX_PACKET_SIZE 256
static uint8_t s_packet_buffer[MAX_PACKET_SIZE];
static size_t s_packet_length = 0;
void __attribute__((noreturn)) main(void)
{
    size_t packet_counter = 0;
    bool is_transmitting = false;

    for(;;)
    {
        *REG_GPIO_LED = is_transmitting ? 1 : 0;
        if( !is_transmitting ) {    // receiving
            uint32_t rx_data = ethernet_rx_byte();
            if( rx_data & 0x200 ) { // RX data is valid
                s_packet_buffer[s_packet_length++] = rx_data & 0xff;
                if( (rx_data & 0x100) != 0 || s_packet_length >= MAX_PACKET_SIZE ) {    // RX data is the last byte or buffer is full
                    // Loopback
                    if( s_packet_length >= 12 ) {   // Source MAC address and destination MAC address exists
                        // Swap the addresses.
                        for(size_t i = 0; i < 6; i++) {
                            uint8_t tmp = s_packet_buffer[i];
                            s_packet_buffer[i] = s_packet_buffer[i + 6];
                            s_packet_buffer[i + 6] = tmp;
                        }
                    }
                    is_transmitting = true;
                }
            }
        }
        if( is_transmitting && ethernet_tx_ready() ) {     // transmitting
            if( packet_counter < s_packet_length ) {
                ethernet_tx_byte(s_packet_buffer[packet_counter] | (packet_counter == s_packet_length - 1 ? 0x100 : 0x000));
                packet_counter++;
                if( packet_counter >= s_packet_length ) {
                    is_transmitting = false;
                    s_packet_length = 0;
                    packet_counter = 0;
                }
            }
        }
    }
}
#else

void* memcpy(void* dst, const void* src, unsigned int size)
{
    uint8_t* d = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    for(size_t i = 0; i < size; i++) {
        d[i] = s[i];
    }
    return dst;
}
int memcmp(const void* a, const void* b, unsigned int size)
{
    const uint8_t* x = (const uint8_t*)a;
    const uint8_t* y = (const uint8_t*)b;
    for(size_t i = 0; i < size; i++) {
        if( x[i] != y[i] ) return x[i] - y[i];
    }
    return 0;
}
void* memset(void* dst, int value, unsigned int size)
{
    uint8_t* d = (uint8_t*)dst;
    for(size_t i = 0; i < size; i++) {
        d[i] = value;
    }
    return dst;
}

static uint16_t calculate_internet_checksum(const uint8_t* data, size_t size)
{
    uint32_t sum = 0;
    for(size_t i = 0; i < size; i += 2) {
        sum += data[i] << 8 | data[i + 1];
    }
    while( sum >> 16 ) {
        sum = (sum & 0xffff) + (sum >> 16);
    }
    return ~sum;
}
static bool process_ethernet(const uint8_t* tx_data, size_t tx_data_len)
{
    #define MAX_PACKET_SIZE 256
    static uint8_t s_packet_buffer[MAX_PACKET_SIZE];
    static size_t s_packet_length = 0;
    static size_t s_packet_counter = 0;
    static enum { STATE_IDLE, STATE_RX, STATE_TX } state = STATE_IDLE;
    static const uint8_t BROADCAST_MAC_ADDRESS[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
    static const uint8_t TARGET_MAC_ADDRESS[6]    = { 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 };
    static const uint8_t MY_IP_ADDRESS[4]    = { 192, 168, 10, 2 };
    static uint8_t s_msmp_tx_mac[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };   // Default MSMP TX IP address
    static uint8_t s_msmp_tx_ip[4] = { 192, 168, 10, 1 };                       // Default MSMP TX IP address
    bool tx_data_accepted = false;

    if( state == STATE_IDLE || state == STATE_RX ) {
        s_packet_counter = 0;
        uint32_t rx_data = ethernet_rx_byte();
        if( rx_data & 0x200 ) { // RX data is valid
            state = STATE_RX;
            s_packet_buffer[s_packet_length++] = rx_data & 0xff;
            if( (rx_data & 0x100) != 0 || s_packet_length >= MAX_PACKET_SIZE ) {    // RX data is the last byte or buffer is full
                uart_tx_string(REG_UART, "FRAME! ");
                uart_tx_hex_8(REG_UART, s_packet_length & 0xff);
                uart_tx_string(REG_UART, " ");
                uart_tx_hex_string(REG_UART, s_packet_buffer, 14);
                if( memcmp(s_packet_buffer, BROADCAST_MAC_ADDRESS, 6) == 0 || memcmp(s_packet_buffer, TARGET_MAC_ADDRESS, 6) == 0 ) {
                    uart_tx_string(REG_UART, " MY FRAME! ");
                    if( s_packet_buffer[12] == 0x08 && s_packet_buffer[13] == 0x06 && s_packet_length >= 6 + 6 + 2 + 28  ) { // ARP packet
                        uart_tx_string(REG_UART, "ARP! ");
                        memcpy(s_packet_buffer, s_packet_buffer + 6, 6);    // Destination address <- Source address
                        memcpy(s_packet_buffer + 6, TARGET_MAC_ADDRESS, 6); // Source address <- Target address
                        s_packet_buffer[14 + 6 + 0] = 0x00;    // OPER = ARP reply (0x0002)
                        s_packet_buffer[14 + 6 + 1] = 0x02;    // /
                        memcpy(s_packet_buffer + 14 + 18, s_packet_buffer + 14 + 8, 10);    // Target address
                        memcpy(s_packet_buffer + 14 + 8,  TARGET_MAC_ADDRESS, 6);           // Source address
                        memcpy(s_packet_buffer + 14 + 14, MY_IP_ADDRESS, 4);                // My IP Address
                        state = STATE_TX;
                    }
                    if( s_packet_buffer[12] == 0x08 && s_packet_buffer[13] == 0x00 && s_packet_length >= 20  ) { // IP packet
                        uint8_t* const ip = s_packet_buffer + 14;
                        uart_tx_string(REG_UART, "IP! ");
                        if( ip[16] == 192 && ip[17] == 168 && ip[18] == 10 && ip[19] == 2) {
                            uart_tx_string(REG_UART, "MY IP! ");
                            memcpy(s_msmp_tx_ip, ip + 12, 4);   // Update MSMP TX IP address by the source IP address
                            memcpy(s_msmp_tx_mac, s_packet_buffer + 6, 6); // Update MSMP TX MAC address by the source MAC address
                            if( ip[9] == 0x11 ) {   // UDP
                                uart_tx_string(REG_UART, "UDP! ");
                                uint8_t* const udp = ip + 20;
                                uint16_t destination_port = udp[2] << 8 | udp[3];
                                if( destination_port == 10000 ) {
                                    uart_tx_string(REG_UART, "MSMP TX! ");
                                    uint16_t length = udp[4] << 8 | udp[5];
                                    uint8_t* payload = udp + 8;
                                    uint32_t last_counter = *REG_COUNTER;
                                    if( length >= 8 ) { // Subtract UDP header length
                                        length -= 8;
                                    }
                                    while(length--) {
                                        while((*REG_COUNTER - last_counter) < FREQ_HZ / 1000 * 50);
                                        last_counter = *REG_COUNTER;
                                        if( uart_tx_ready(REG_MSMP) ) {
                                            uart_tx_byte(REG_MSMP, *payload++);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if( state == STATE_RX ) {   // This packet is not processed. Discard it.
                    s_packet_length = 0;
                    state = STATE_IDLE;
                }
                uart_tx_string(REG_UART, "\n");
            }
        }
    }
    if( state == STATE_IDLE && tx_data != NULL && tx_data_len > 0 ) { // Transmit data if requested.
        uart_tx_string(REG_UART, "UDP TX! ");
        uart_tx_hex_8(REG_UART, tx_data_len & 0xff);
        uart_tx_string(REG_UART, " ");
        
        memcpy(s_packet_buffer + 0, s_msmp_tx_mac, 6);      // Destination MAC address
        memcpy(s_packet_buffer + 6, TARGET_MAC_ADDRESS, 6); // Source MAC address
        s_packet_buffer[12] = 0x08; // EtherType (IPv4)
        s_packet_buffer[13] = 0x00; // /
        uint8_t* const ip = s_packet_buffer + 14;
        ip[0] = 0x45; // Version and IHL
        ip[1] = 0x00; // ToS
        const uint16_t ip_total_length = 20 + 8 + tx_data_len;
        ip[2] = ip_total_length >> 8; // Total length
        ip[3] = ip_total_length & 0xff; // /
        ip[4] = 0x00; // Identification
        ip[5] = 0x00; // /
        ip[6] = 0x00; // Flags and Fragment Offset
        ip[7] = 0x00; // /
        ip[8] = 0x40; // TTL
        ip[9] = 0x11; // Protocol (UDP)
        ip[10] = 0x00; // Header checksum
        ip[11] = 0x00; // /
        memcpy(ip + 12, MY_IP_ADDRESS, 4); // Source IP address
        memcpy(ip + 16, s_msmp_tx_ip, 4); // Source IP address
        uint16_t header_checksum = calculate_internet_checksum(ip, 20);
        ip[10] = header_checksum >> 8;   // Update header checksum
        ip[11] = header_checksum & 0xff; // /
        uint8_t* const udp = ip + 20;
        udp[0] = 10000 >> 8;    // Source port
        udp[1] = 10000 & 0xff;  // /
        udp[2] = 10000 >> 8;    // Destination port
        udp[3] = 10000 & 0xff;  // /
        const uint16_t udp_length = 8 + tx_data_len;
        udp[4] = udp_length >> 8;   // Length
        udp[5] = udp_length & 0xff; // /
        udp[6] = 0x00;  // Checksum
        udp[7] = 0x00;  // /
        memcpy(udp + 8, tx_data, tx_data_len); // Payload
        s_packet_length = 14 + 20 + 8 + tx_data_len;
        if( s_packet_length < 64 ) {
            for(size_t i = s_packet_length; i < 64; i++) {
                s_packet_buffer[i] = 0;
            }
            s_packet_length = 64;
        }
        uart_tx_hex_string(REG_UART, s_packet_buffer, s_packet_length);
        s_packet_counter = 0;
        state = STATE_TX;
        tx_data_accepted = true;
        uart_tx_string(REG_UART, "\n");

    }
    if(state == STATE_TX ) {
        if( ethernet_tx_ready() ) {     // transmitting
            // uart_tx_hex_8(REG_UART, s_packet_counter & 0xff);
            // uart_tx_string(REG_UART, " ");
            // uart_tx_hex_8(REG_UART, s_packet_length & 0xff);
            // uart_tx_string(REG_UART, "\n");
            ethernet_tx_byte(s_packet_buffer[s_packet_counter] | (s_packet_counter == s_packet_length - 1 ? 0x100 : 0x000));
            s_packet_counter++;
            if( s_packet_counter >= s_packet_length ) {
                state = STATE_IDLE;
                s_packet_length = 0;
                s_packet_counter = 0;
            }
        }
    }

    return tx_data_accepted;
}
void __attribute__((noreturn)) main(void)
{
    uint32_t counter = 0;
    uint64_t matrix_output = 1;
    uint32_t led_out = 1;
    const uint32_t LED_BITS = 6;

    static const uint8_t MSMP_MY_ADDRESS = 0x06;
    static uint8_t msmp_rx_buffer[64 + 2];
    size_t msmp_bytes_received = 0;
    size_t msmp_bytes_forwarded = 0;
    enum { MSMP_RX_STATE_RX, MSMP_RX_STATE_PENDING_UDP, MSMP_RX_STATE_FORWARDING } msmp_rx_state = MSMP_RX_STATE_RX;
    
    uint32_t msmp_tx_last_counter = 0;

    enable_interrupt();

    uart_tx_string(REG_UART, "Hello, world!\n");
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
            if( uart_tx_ready(REG_UART) ) {
                uart_tx_byte(REG_UART, uart_rx_data & 0xff);
                uart_rx_data = 0;
            }
        }
        if( msmp_rx_state == MSMP_RX_STATE_RX ) {
            if( msmp_rx_data & 0x10000 ) {
                const uint8_t data = msmp_rx_data & 0xff;
                msmp_rx_data = 0;
                msmp_rx_buffer[msmp_bytes_received++] = data;
                // if( msmp_bytes_received == 2 ) {
                //     uart_tx_string(REG_UART, "MSMP RX: ");
                //     uart_tx_hex_8(REG_UART, msmp_rx_buffer[0]);
                //     uart_tx_hex_8(REG_UART, msmp_rx_buffer[1]);
                // }
                if( msmp_bytes_received > 2 ) {
                    const uint8_t length = msmp_rx_buffer[1] & 0x3f;
                    if( msmp_bytes_received == length + 2 ) {
                        if( (msmp_rx_buffer[0] >> 4) == MSMP_MY_ADDRESS ) {
                            uart_tx_string(REG_UART, "UDP ");
                            msmp_rx_state = MSMP_RX_STATE_PENDING_UDP;
                        } else {
                            uart_tx_string(REG_UART, "FWD ");
                            msmp_rx_state = MSMP_RX_STATE_FORWARDING;
                            msmp_bytes_forwarded = 0;
                        }
                    }
                }
                if( data == 0x00 ) {
                    uart_tx_string(REG_UART, "RESYNC ");
                    msmp_rx_state = MSMP_RX_STATE_RX;
                    msmp_bytes_received = 0;    // resync.
                }
                if( msmp_bytes_received >= sizeof(msmp_rx_buffer) && msmp_rx_state == MSMP_RX_STATE_RX ) {  // Buffer overflow. discard the packet.
                    uart_tx_string(REG_UART, "OVF ");
                    msmp_rx_state = MSMP_RX_STATE_RX;
                    msmp_bytes_received = 0;
                }
                uart_tx_string(REG_UART, "\n");
            }
        }
        if( msmp_rx_state == MSMP_RX_STATE_FORWARDING ) {
            // Transmit received data (MSMP)
            if( uart_tx_ready(REG_MSMP) && (*REG_COUNTER - msmp_tx_last_counter) >= FREQ_HZ / 1000 * 50 ) {
                msmp_tx_last_counter = *REG_COUNTER;
                uart_tx_byte(REG_MSMP, msmp_rx_buffer[msmp_bytes_forwarded++]);
                if( msmp_bytes_forwarded >= msmp_bytes_received ) {
                    msmp_rx_state = MSMP_RX_STATE_RX;
                    msmp_bytes_received = 0;
                }
            }
        }
        if( msmp_rx_state == MSMP_RX_STATE_PENDING_UDP ) {
            const uint8_t length = msmp_rx_buffer[1] & 0x3f;
            if( process_ethernet(msmp_rx_buffer, length + 2) ) {
                msmp_rx_state = MSMP_RX_STATE_RX;
                msmp_bytes_received = 0;
            }
        } else {
            process_ethernet(NULL, 0);
        }
    }
}
#endif // ETHERNET_LOOPBACK