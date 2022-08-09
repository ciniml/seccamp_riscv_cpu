.PHONY: all clean

TARGET := bootrom-rs

all: $(TARGET).bin $(TARGET).lst

$(TARGET).bin:
	cargo objcopy --bin $(TARGET) -- -O binary $@

$(TARGET).lst:
	cargo objdump --bin $(TARGET) -- -dSC > $@

clean:
	-@$(RM) $(TARGET).bin $(TARGET).lst