.PHONY: docker docker-build

RISCV_CHISEL_BOOK_DIR ?= $(PWD)/external/riscv-chisel-book

docker:
	docker run -it -v $(PWD):/src seccamp-riscv

docker-build:
	cd docker && docker build . -t seccamp-riscv
