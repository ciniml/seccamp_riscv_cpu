.PHONY: all clean

CC = riscv64-unknown-elf-gcc
OBJDUMP = riscv64-unknown-elf-objdump
OBJCOPY = riscv64-unknown-elf-objcopy
CFLAGS = -mabi=ilp32 -march=rv32i -Os -g
LDFLAGS = -Wl,-Tlink.ld -nostartfiles 

OBJS := bootrom.o

BOOTROM_TARGETS := bootrom.hex bootrom_0.hex bootrom_1.hex bootrom_2.hex bootrom_3.hex

all: bootrom.bin $(BOOTROM_TARGETS) bootrom.dump

bootrom.elf: $(OBJS) link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $<

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.hex: %.bin
	od -An -tx4 -w4 -v $< > $@
%.dump: %.elf
	$(OBJDUMP) -dSC $< > $@

%_0.hex: %.hex
	awk '{print substr($$1,7,2)}' $< > $@
%_1.hex: %.hex
	awk '{print substr($$1,5,2)}' $< > $@
%_2.hex: %.hex
	awk '{print substr($$1,3,2)}' $< > $@
%_3.hex: %.hex
	awk '{print substr($$1,1,2)}' $< > $@


clean:
	-@$(RM) *.o *.elf *.bin *.hex