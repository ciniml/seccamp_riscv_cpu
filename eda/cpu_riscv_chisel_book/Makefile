PROJECT_NAME := cpu_riscv_chisel_book

TARGET ?= tangnano9k_pmod
ROOT_DIR ?= $(abspath ../..)
RTL_DIR ?= $(ROOT_DIR)/rtl
CHISEL_DESIGN_DIR ?= $(ROOT_DIR)/cpu_design/src/main/scala
CHISEL_DESIGN_SRCS := $(shell find $(CHISEL_DESIGN_DIR) -name "*.scala")

RISCV_ELABORATE := fpga.Elaborate_Minimal 

RISCV_CORE_SRC := $(RTL_DIR)/chisel_output/Top.sv
PROJECT_ADDITIONAL_ARGS := $(abspath $(RISCV_CORE_SRC))
PROJECT_ADDITIONAL_CLEAN := $(RISCV_CORE_SRC)

SRCS := $(RISCV_CORE_SRC) project.tcl

include ../build_gowin.mk

$(RISCV_CORE_SRC): $(CHISEL_DESIGN_SRCS) $(BOOTROM_HEX)
	cd $(ROOT_DIR) && sbt "project cpu_design; runMain $(RISCV_ELABORATE)"
