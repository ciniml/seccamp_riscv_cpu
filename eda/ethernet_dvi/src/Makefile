.PHONY: all clean test view

TARGET ?= tangnano9k_pmod
VERILATOR ?= verilator
RTL_DIR ?= ../../../external/fpga_samples/rtl
SIM_SRCS := tb.sv ./top.sv ./$(TARGET)/chisel_output/TopWithEthernet.sv \
	$(RTL_DIR)/ethernet/util/simple_fifo.v \
	$(RTL_DIR)/ethernet/mii_axis/axis_to_rmii.sv \
	$(RTL_DIR)/ethernet/mii_axis/rmii_to_axis.sv \
	$(RTL_DIR)/ethernet/mii_axis/prepend_preamble.sv \
	$(RTL_DIR)/ethernet/mii_mac/append_crc.sv \
	$(RTL_DIR)/ethernet/mii_mac/remove_crc.sv \
	$(RTL_DIR)/ethernet/mii_mac/axis_mux.sv \
	$(RTL_DIR)/ethernet/mii_mac/crc_mac.sv \
	$(RTL_DIR)/ethernet/mii_mac/mii_mac_rx.sv \
	$(RTL_DIR)/ethernet/mii_mac/mii_mac_tx.sv \
	$(RTL_DIR)/ethernet/rmii_mac/rmii_mac.sv \

VERILATOR_OPTS := -Wno-COMBDLY -Wno-UNOPTFLAT -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-TIMESCALEMOD -Wno-PINMISSING

all: test

clean:
	-@$(RM) -r *.vcd obj_dir

test: obj_dir/testbench
	./obj_dir/testbench

obj_dir/testbench: $(SIM_SRCS) ../sw/bootrom.hex
	@echo Compiling testbench
	$(VERILATOR) --binary --top-module tb --assert --trace-fst --trace-params --trace-structs --trace-underscore $(filter %.sv,$^) $(filter %.v,$^) -o testbench $(VERILATOR_OPTS)

output.vcd: obj_dir/testbench
	./obj_dir/testbench > /dev/null 2>&1 

../sw/bootrom.hex:
	cd ./sw && make

view: output.vcd
	gtkwave output.vcd&
