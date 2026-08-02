import re, subprocess, sys, argparse, os

def run_spike(test):
    elf = f"build/{test}.elf"
    cmd = ["spike", "--isa=rv32i", "-m0x80000000:0x1000000", "-l", "--log-commits", elf]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        output = result.stderr
    except subprocess.TimeoutExpired as e:
        output = e.stderr
        if output is None:
            output = ""
        elif isinstance(output, bytes):
            output = output.decode('utf-8')
    regs = {}
    in_test_region = False
    # \b ensures we match "x" as a word, not part of "0x"
    for line in output.split('\n'):
        if not in_test_region:
            if re.search(r'^\s*core\s+0:\s+0x80000000\s+\(', line):
                in_test_region = True
            continue
        if re.search(r'\bebreak\b|00100073', line, re.IGNORECASE):
            break
        m = re.search(r'\bx(\d+)\s+(?:<-\s+)?(0x[0-9a-f]+)', line, re.IGNORECASE)
        if m:
            reg_num = int(m.group(1))
            if reg_num != 0:
                regs[reg_num] = int(m.group(2), 16)
    return regs

def run_rtl():
    with open("build/rtl_output.log") as f:
        data = f.read()
    start = data.find("=== RTL_REGISTER_DUMP_START ===")
    end = data.find("=== RTL_REGISTER_DUMP_END ===")
    if start == -1 or end == -1:
        print("ERROR: RTL dump not found. Check cpu_tb.v for the dump block.")
        sys.exit(1)
    regs = {}
    for line in data[start:end].split('\n'):
        m = re.search(r'\bx(\d+)=(-?\d+)', line, re.IGNORECASE)
        if m:
            reg_num = int(m.group(1))
            if reg_num != 0:
                regs[reg_num] = int(m.group(2))
    return regs

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", required=True)
    args = parser.parse_args()

    if not os.path.exists(f"build/{args.test}.elf"):
        s_path = f"riscv_assembly_examples/{args.test}.s"
        if not os.path.exists(s_path):
            import glob
            candidates = glob.glob(f"riscv_assembly_examples/*/{args.test}.s")
            if candidates:
                s_path = candidates[0]
            else:
                print(f"ERROR: Could not find {args.test}.s")
                sys.exit(1)
        subprocess.run([
            "riscv64-unknown-elf-gcc",
            "-march=rv32i", "-mabi=ilp32", "-nostdlib",
            "-T", "link.ld",
            "-ffreestanding", "-fno-builtin",
            s_path,
            "-o", f"build/{args.test}.elf"
        ], check=True)

    spike_regs = run_spike(args.test)
    rtl_regs = run_rtl()

    all_regs = set(spike_regs.keys()) & set(rtl_regs.keys())
    failed = False
    print(f"\n--- Comparing {args.test} ---")
    for r in sorted(all_regs):
        sv = spike_regs.get(r, "MISSING")
        rv = rtl_regs.get(r, "MISSING")
        if sv != rv:
            print(f"❌ x{r}: Spike={sv}  vs  RTL={rv}")
            failed = True
    missing_spike = sorted(set(rtl_regs.keys()) - set(spike_regs.keys()))
    missing_rtl = sorted(set(spike_regs.keys()) - set(rtl_regs.keys()))
    for r in missing_spike:
        print(f"ℹ️  x{r}: RTL has {rtl_regs[r]} but Spike did not report a final value")
    for r in missing_rtl:
        print(f"ℹ️  x{r}: Spike has {spike_regs[r]} but RTL did not report a final value")
    if not failed:
        print("✅ PASSED")
        sys.exit(0)
    else:
        print("❌ FAILED")
        sys.exit(1)
