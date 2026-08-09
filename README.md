# R321 CPU

This repository contains a small RV32I single-cycle CPU written in Verilog, plus the assembly programs, testbench, and checker used to verify it.

The current verification flow is driven by the `Makefile`: it compiles a chosen assembly test into a hex image, loads that image into instruction memory, runs the RTL simulation, and compares the final register state against Spike.

## Project Layout

- `rtl/` - synthesizable CPU modules
- `tb/` - simulation testbenches
- `riscv_assembly_examples/` - directed assembly tests
- `scripts/` - test generation and comparison scripts
- `riscv-isa-sim/` - Spike sources used as the golden model checker dependency
- `link.ld` - linker script for placing code at `0x80000000`
- `Makefile` - build, simulation, regression, and cleanup commands

## CPU Overview

The top-level module is [`rtl/tob_module.v`](rtl/tob_module.v). It connects the following blocks:

- program counter
- instruction memory
- control unit
- immediate generator
- register file
- ALU control and ALU
- data memory
- writeback mux

Supported instruction groups include:

- R-type arithmetic and logic instructions
- I-type ALU instructions
- loads and stores
- branches
- `lui` and `auipc`
- `jal` and `jalr`

## How Verification Works

The main testbench is [`tb/cpu_tb.v`](tb/cpu_tb.v). It:

- drives `clk` and `rst`
- loads `program.hex` through instruction memory
- runs the CPU for a fixed number of cycles
- prints a register dump at the end

The instruction memory in [`rtl/instruction_memory.v`](rtl/instruction_memory.v) uses `$readmemh("program.hex", imem)`, so the simulation must run with `program.hex` available in the working directory.

The checker in [`scripts/checker.py`](scripts/checker.py) compares the final RTL register dump against Spike output for the same test program.

## Quick Start

Run the default directed test:

```bash
make
```

Run a specific test:

```bash
make TEST_NAME=bne
```

Run the full directed regression:

```bash
make regression
```

Generate and run a random test:

```bash
make random
```

Clean build outputs:

```bash
make clean
```

## Vivado Verification

Vivado is not checked in as a project here, but you can verify the design with Vivado simulation:

1. Create a new RTL project.
2. Add all files from `rtl/` as design sources.
3. Add [`tb/cpu_tb.v`](tb/cpu_tb.v) as a simulation source.
4. Set `top_module` as the design top and `cpu_tb` as the simulation top.
5. Make sure `program.hex` is present in the Vivado simulation working directory, or copy it there before launching simulation.
6. Run Behavioral Simulation and check the console for the final register dump between `RTL_REGISTER_DUMP_START` and `RTL_REGISTER_DUMP_END`.

If you want implementation results as well, run synthesis and implementation after adding board constraints (`.xdc`) for your target board.

## Notes

- The RTL currently includes verbose debug prints in a few modules, so simulation output will be noisy.
- The default build flow assumes a RISC-V cross compiler such as `riscv64-unknown-elf-gcc` and `riscv64-unknown-elf-objcopy`.
