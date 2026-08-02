# -----------------------------------------------
# RISC-V Verification Makefile (Icarus Verilog)
# -----------------------------------------------
# If you have riscv32-unknown-elf-gcc, use that. If you only have riscv64, use riscv64-unknown-elf-gcc
RISCV_PREFIX ?= riscv64-unknown-elf-
CC = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy

# Icarus settings
SIM = iverilog
VVP = vvp
VCD_DIR = vcd

# Collect all RTL and TB files
RTL_FILES = $(wildcard rtl/*.v) $(wildcard tb/*.v)

# Default test (change this to run a specific one, e.g., TEST_NAME=bne)
TEST_NAME ?= addi

# Default target
all: compile run check

# ------------------------------------------------------------
# 1. Compile Assembly (.s) -> Hex (.hex) for Instruction Memory
# ------------------------------------------------------------
build/%.hex: riscv_assembly_examples/%.s
	mkdir -p $(dir $@)
	$(CC) -march=rv32i -mabi=ilp32 -nostdlib -T link.ld -ffreestanding -fno-builtin $< -o build/$*.elf
	$(OBJCOPY) -O verilog --verilog-data-width=4 --strip-all build/$*.elf build/$*.hex
	# Remove @address lines (Icarus $readmemh only wants raw hex)
	sed -i '/@/d' build/$*.hex

# ------------------------------------------------------------
# 2. Compile RTL + Run Simulation (Icarus -> VVP)
# ------------------------------------------------------------
compile: build/$(TEST_NAME).hex
	mkdir -p $(VCD_DIR)
	cp build/$(TEST_NAME).hex program.hex
	$(SIM) -g2005-sv -o build/cpu_sim.vvp $(RTL_FILES) -s cpu_tb

run: compile
	# Run the simulation and capture stdout for the checker
	$(VVP) build/cpu_sim.vvp > build/rtl_output.log 2>&1
	# Move the generated VCD to your dedicated folder (optional, but keeps things clean)
	mv *.vcd $(VCD_DIR)/ 2>/dev/null || true

# ------------------------------------------------------------
# 3. Run Spike (Golden Model) + Python Checker
# ------------------------------------------------------------
check: run
	python3 scripts/checker.py --test $(TEST_NAME)

# ------------------------------------------------------------
# 4. Run ALL directed tests (Full Regression)
# ------------------------------------------------------------
regression:
	@for test in $$(find riscv_assembly_examples -name "*.s" | sed 's|^riscv_assembly_examples/||' | sed 's/\.s$$//'); do \
		echo ">>> Running $$test..."; \
		$(MAKE) TEST_NAME=$$test check || exit 1; \
	done

# 5. Generate + Run Random Test
# ------------------------------------------------------------
random:
	python3 scripts/random_gen.py
	$(MAKE) TEST_NAME=random check

# ------------------------------------------------------------
# 6. Clean up
# ------------------------------------------------------------
clean:
	rm -rf build/ *.vcd $(VCD_DIR)/*.vcd