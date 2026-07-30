import re
import subprocess
import sys
import argparse
import os

def run_spike(test_name):
    """Run Spike on the compiled ELF and parse final register values."""
    elf_file = f"build/{test_name}.elf"
    
    # Spike log commit shows every register write
    result = subprocess.run(
        ["spike", "-l", "--log-commits", elf_file],
        capture_output=True,
        text=True
    )
    
    regs = {}
    # Parse lines like: core   0: 0 0x00000000 (0x00000005) x1
    # Or simpler: match "x1 <- 0x00000005"
    for line in result.stderr.split('\n'):
        match = re.search(r'x(\d+)\s*<-\s*(0x[0-9a-f]+)', line)
        if match:
            reg_num = int(match.group(1))
            if reg_num != 0:
                regs[reg_num] = int(match.group(2), 16)
    
    # If Spike didn't output writes (sometimes it just logs), 
    # we can also parse the final PC/regs from the end, but the above works for --log-commits.
    return regs

def run_rtl():
    """Parse the VVP simulation output log for register dumps."""
    with open("build/rtl_output.log", "r") as f:
        data = f.read()
    
    start = data.find("=== RTL_REGISTER_DUMP_START ===")
    end = data.find("=== RTL_REGISTER_DUMP_END ===")
    if start == -1 or end == -1:
        print("ERROR: RTL dump not found!")
        print("Did you add the $display block to cpu_tb.v and set the correct hierarchy path?")
        sys.exit(1)
    
    regs = {}
    for line in data[start:end].split('\n'):
        match = re.search(r'x(\d+)=(-?\d+)', line)
        if match:
            reg_num = int(match.group(1))
            if reg_num != 0:
                regs[reg_num] = int(match.group(2))
    return regs

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", required=True)
    args = parser.parse_args()
    
    # Ensure the ELF exists for Spike
    if not os.path.exists(f"build/{args.test}.elf"):
        subprocess.run([
            "riscv64-unknown-elf-gcc",  # Change to riscv32 if you have it
            "-march=rv32i", "-mabi=ilp32", "-nostdlib", "-Ttext=0x00000000",
            f"riscv_assembly_examples/*/{args.test}.s",
            "-o", f"build/{args.test}.elf"
        ], check=True)
    
    spike_regs = run_spike(args.test)
    rtl_regs = run_rtl()
    
    all_regs = set(spike_regs.keys()) | set(rtl_regs.keys())
    failed = False
    
    print(f"\n--- Comparing {args.test} ---")
    for r in sorted(all_regs):
        s_val = spike_regs.get(r, "MISSING")
        r_val = rtl_regs.get(r, "MISSING")
        if s_val != r_val:
            print(f"❌ x{r}: Spike={s_val}  vs  RTL={r_val}")
            failed = True
    
    if not failed:
        print("✅ TEST PASSED")
        sys.exit(0)
    else:
        print("❌ TEST FAILED")
        sys.exit(1)