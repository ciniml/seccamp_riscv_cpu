PROJECT_NAME := cpu_riscv_chisel_book

TARGET ?= tangnano9k_pmod
CHISEL_TEMPLATE_DIR ?= ../../external/riscv-chisel-book/chisel-template
ROOT_DIR ?= $(abspath ../..)
RTL_DIR ?= $(ROOT_DIR)/rtl
CHISEL_DESIGN_DIR ?= $(ROOT_DIR)/src/main/scala
CHISEL_DESIGN_SRCS := $(shell find $(CHISEL_DESIGN_DIR) -name "*.scala")

BOOTROM_HEX ?= src/sw/bootrom.hex
#BOOTROM_HEX ?= src/sw-rs/bootrom.hex

RISCV_ELABORATE := fpga.Elaborate_TangNanoPmod_SegmentLed 
RISCV_TEST := cpu.TopWithSegmentLedTest
RISCV_ELABORATE_OUTPUT_DIR := $(RTL_DIR)/tangnano_pmod_segment_led

RISCV_CORE_SRC := src/$(TARGET)/riscv.v
PROJECT_ADDITIONAL_ARGS := $(abspath $(RISCV_CORE_SRC))
PROJECT_ADDITIONAL_CLEAN := $(RISCV_CORE_SRC)

SRCS := $(wildcard src/$(TARGET)/*.cst) $(wildcard src/$(TARGET)/*.sdc) $(wildcard src/$(TARGET)/*.sv) $(RISCV_CORE_SRC) project.tcl $(BOOTROM_HEX)

PMOD_PORT_OFFSET ?= 0
PMOD_TARGETS := tangnano9k_pmod

PMOD_MODULES := pmod_matrix_led pmod_7segx6_single

# Check if the target contains PMOD ports
ifneq (,$(filter $(TARGET),$(PMOD_TARGETS)))
USE_PMOD := 1
SRCS += src/$(TARGET)/pins.cst
PROJECT_ADDITIONAL_CLEAN += src/$(TARGET)/pins.cst
endif

include ../build_gowin.mk

ifeq ($(USE_PMOD),1)
# Generate CST file from template.
PMOD_MODULES_DEFS := $(addprefix $(MOD_DIR)/,$(addsuffix /pmod_pins.csv,$(PMOD_MODULES)))
PMOD_MODULES_ARGS := $(addprefix --pmod ,$(PMOD_MODULES_DEFS))

src/$(TARGET)/pins.cst: src/$(TARGET)/pins.cst.template $(PMOD_MODULES_DEFS) $(MAPPMOD)
	echo Generating pin definition from Pmod pin map.
	echo // This file is automatically generated by build script. DO NOT EDIT THIS FILE. > $@
	cat src/$(TARGET)/pins.cst.template >> $@
	$(MAPPMOD) --pmod-port-def $(TARGET_DEF_DIR)/pmod_ports.csv $(PMOD_MODULES_ARGS) --port-offset $(PMOD_PORT_OFFSET) --direction right-to-left >> $@
else
src/$(TARGET)/pins.cst:
	echo Use pre-generated pin definition.
endif

$(RISCV_CORE_SRC): $(CHISEL_DESIGN_SRCS)
	cd $(ROOT_DIR) && sbt "project root; runMain $(RISCV_ELABORATE)"
	cp $(RISCV_ELABORATE_OUTPUT_DIR)/riscv.v $@

.PHONY: test
test: $(CHISEL_DESIGN_SRCS) src/sw/bootrom.hex
	cd $(ROOT_DIR) && sbt "project root; testOnly $(RISCV_TEST)"

.PHONY: show
show:
	gtkwave ../../test_run_dir/must_runs_TopWithSegmentLed/TopWithSegmentLedTestSystem.fst&

src/sw/bootrom.hex: src/sw/bootrom.c src/sw/link.ld src/sw/Makefile
	cd src/sw; make

src/sw-rs/bootrom.hex: $(wildcard src/sw-rs/src/*.rs) src/sw-rs/pac/build.rs src/sw-rs/pac/cpu_riscv_chisel_book.svd
	cd src/sw-rs; make