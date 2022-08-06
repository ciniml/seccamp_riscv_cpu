.PHONY: all clean test view

SIM_SRCS := tb.sv ./iobuf_sim.sv ./top.sv ./riscv.v

all: test

clean:
	-@$(RM) *.vcd testbench

test: testbench
	./testbench

testbench: $(SIM_SRCS)
	@echo Compiling testbench
	iverilog -g2012 $(SIM_SRCS) -o $@

output.vcd: testbench
	./testbench > /dev/null 2>&1 

view: output.vcd
	gtkwave output.vcd&
