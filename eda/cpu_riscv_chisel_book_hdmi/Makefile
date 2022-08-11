PROJECT_NAME := cpu_riscv_chisel_book_hdmi

TARGET ?= comprocboard_9k
CHISEL_TEMPLATE_DIR ?= ../../external/riscv-chisel-book/chisel-template
ROOT_DIR ?= $(abspath ../..)
RTL_DIR ?= $(ROOT_DIR)/rtl
CHISEL_DESIGN_DIR ?= $(ROOT_DIR)/src/main/scala
CHISEL_DESIGN_SRCS := $(shell find $(CHISEL_DESIGN_DIR) -name "*.scala")

BOOTROM_HEX ?= src/sw/bootrom.hex
#BOOTROM_HEX ?= src/sw-rs/bootrom.hex

ifeq ($(TARGET),comprocboard_9k)
RISCV_ELABORATE := fpga.Elaborate_ComProcCpuBoard 
#RISCV_ELABORATE := fpga.Elaborate_ComProcCpuBoard_RustBootrom 
RISCV_ELABORATE_OUTPUT_DIR := $(RTL_DIR)/comproc_cpu_board
endif

RISCV_CORE_SRC := src/$(TARGET)/riscv.v
PROJECT_ADDITIONAL_ARGS := $(abspath $(RISCV_CORE_SRC))
PROJECT_ADDITIONAL_CLEAN := $(RISCV_CORE_SRC)

SRCS := $(wildcard src/$(TARGET)/*.cst) $(wildcard src/$(TARGET)/*.sdc) $(wildcard src/$(TARGET)/*.sv) $(RISCV_CORE_SRC) project.tcl $(BOOTROM_HEX)

include ../build_gowin.mk

$(RISCV_CORE_SRC): $(CHISEL_DESIGN_SRCS)
	cd $(ROOT_DIR) && sbt "project root; runMain $(RISCV_ELABORATE)"
	cp $(RISCV_ELABORATE_OUTPUT_DIR)/riscv.v $@

src/sw/bootrom.hex: src/sw/bootrom.c src/sw/link.ld src/sw/Makefile
	cd src/sw; make

src/sw-rs/bootrom.hex: $(wildcard src/sw-rs/src/*.rs) src/sw-rs/pac/build.rs src/sw-rs/pac/cpu_riscv_chisel_book.svd
	cd src/sw-rs; make