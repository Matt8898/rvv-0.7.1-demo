#CC := /var/lib/machines/ubuntuintel/root/allwinner/tina/prebuilt/gcc/linux-x86/riscv/toolchain-thead-glibc/riscv64-glibc-gcc-thead_20200702/bin/riscv64-unknown-linux-gnu-gcc
#AS := ../rvtoolchain2/bin/riscv64-unknown-elf-as
CC := ../spike/toolchain-spike/bin/riscv64-unknown-elf-gcc
AS := ../spike/toolchain-spike/bin/riscv64-unknown-elf-as

SFC := $(shell find src/ -type f -name '*.c')
SFS := $(SFC:.c=-s.S)
EXE := $(SFC:.c=.out)
EXE := $(patsubst src/%,out/%,$(EXE))

all: $(EXE)

$(EXE): out/%.out : src/%.c
	echo $(subst .c,.S, $<)
	$(CC) -mabi=lp64d -O3 -c $< -o $(subst .c,.o, $<)
	$(AS) -march=rv64gcv $(subst .c,-s.S, $<) -o $(subst .c,-s.o, $<)
	$(CC) -o $@ $(subst .c,-s.o, $<) $(subst .c,.o, $<)

clean:
	rm -f src/*.o
	rm -f out/*.out
