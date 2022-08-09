.PHONY: all clean

TARGET := bootrom-rs

all: $(TARGET).bin $(TARGET).dump $(TARGET).hex  $(TARGET)_0.hex $(TARGET)_1.hex $(TARGET)_2.hex $(TARGET)_3.hex

$(TARGET).bin:
	cargo objcopy --bin $(TARGET) --release  -- -O binary $@

$(TARGET).dump:
	cargo objdump --bin $(TARGET) --release -- -dSC > $@


%.hex: %.bin
	od -An -tx4 -w4 -v $< > $@

%_0.hex: %.hex
	awk '{print substr($$1,7,2)}' $< > $@
%_1.hex: %.hex
	awk '{print substr($$1,5,2)}' $< > $@
%_2.hex: %.hex
	awk '{print substr($$1,3,2)}' $< > $@
%_3.hex: %.hex
	awk '{print substr($$1,1,2)}' $< > $@

clean:
	-@$(RM) $(TARGET).bin $(TARGET).lst $(TARGET)*.hex