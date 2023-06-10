.PHONY: all build clean

RISCV ?= $(PWD)/riscv-gnu-toolchain-build

all: build

build:
	git clone -b rvv-0.9.x-for-book --single-branch https://github.com/chadyuu/riscv-gnu-toolchain.git
	cd riscv-gnu-toolchain && git submodule update --init --recursive riscv-binutils
	cd riscv-gnu-toolchain && git submodule update --init --recursive riscv-gcc
	cd riscv-gnu-toolchain && git submodule update --init --recursive riscv-newlib
	cd riscv-gnu-toolchain && git submodule update --init --recursive riscv-gdb
	cd riscv-gnu-toolchain && mkdir build && cd build && ../configure --prefix=$(RISCV) --enable-multilib && $(MAKE)

clean:
	cd riscv-gnu-toolchain && $(RM) -r build
