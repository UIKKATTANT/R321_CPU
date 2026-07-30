import random
import os

# --------------------------------------------------------------
# RISC-V INSTRUCTION PACKERS (Bit-accurate for RV32I)
# --------------------------------------------------------------

def pack_r_type(funct7, rs2, rs1, funct3, rd, opcode):
    """Packs R-type: funct7(7) | rs2(5) | rs1(5) | funct3(3) | rd(5) | opcode(7)"""
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def pack_i_type(imm, rs1, funct3, rd, opcode):
    """Packs I-type: imm[11:0](12) | rs1(5) | funct3(3) | rd(5) | opcode(7)"""
    # imm must be signed 12-bit, mask to ensure it fits
    imm = imm & 0xFFF
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def pack_s_type(imm, rs2, rs1, funct3, opcode):
    """Packs S-type (Store): imm[11:5](7) | rs2(5) | rs1(5) | funct3(3) | imm[4:0](5) | opcode(7)"""
    imm = imm & 0xFFF
    imm_11_5 = (imm >> 5) & 0x7F   # bits 11 to 5
    imm_4_0 = imm & 0x1F           # bits 4 to 0
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

def pack_b_type(imm, rs2, rs1, funct3, opcode):
    """Packs B-type (Branch): imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode"""
    imm = imm & 0xFFF  # Branch imm is 12-bit but uses bit 0 as 0 (halfword aligned)
    # RISC-V branch encoding is scattered:
    imm_12 = (imm >> 12) & 0x1
    imm_11 = (imm >> 11) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1 = (imm >> 1) & 0xF
    return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode

# --------------------------------------------------------------
# OPCODE & FUNCT3 / FUNCT7 DEFINITIONS
# --------------------------------------------------------------
OPCODE_R = 0b0110011
OPCODE_I = 0b0010011
OPCODE_LOAD = 0b0000011
OPCODE_STORE = 0b0100011
OPCODE_BRANCH = 0b1100011
OPCODE_JAL = 0b1101111
OPCODE_LUI = 0b0110111

FUNCT3_ADD = 0b000
FUNCT3_SUB = 0b000  # Uses funct7 bit 30 to distinguish ADD vs SUB
FUNCT3_XOR = 0b100
FUNCT3_OR = 0b110
FUNCT3_AND = 0b111
FUNCT3_SLT = 0b010

FUNCT3_BEQ = 0b000
FUNCT3_BNE = 0b001
FUNCT3_BLT = 0b100
FUNCT3_BGE = 0b101

FUNCT7_ADD = 0b0000000
FUNCT7_SUB = 0b0100000

# --------------------------------------------------------------
# RANDOM PROGRAM GENERATOR
# --------------------------------------------------------------
def generate_random_program(num_instructions=80):
    """
    Generates a valid 50-80 instruction random assembly program.
    Strategy:
    - Initialize x1=5, x2=10, x3=0 (base pointer).
    - Mix ALU ops, Stores, Loads, and Branches.
    - End with 'ebreak' (0x00100073) so Spike stops gracefully.
    """
    insts = []
    labels = {}  # For branch targets
    
    # --- Setup phase: Initialize registers to known values ---
    # x1 = 5
    insts.append(pack_i_type(5, 0, FUNCT3_ADD, 1, OPCODE_I))
    # x2 = 10
    insts.append(pack_i_type(10, 0, FUNCT3_ADD, 2, OPCODE_I))
    # x3 = 100 (will be used as a base address for loads/stores)
    insts.append(pack_i_type(100, 0, FUNCT3_ADD, 3, OPCODE_I))
    # x4 = 0 (counter)
    insts.append(pack_i_type(0, 0, FUNCT3_ADD, 4, OPCODE_I))

    current_pc = 4 * len(insts)  # PC at 0x0000_0000 + bytes offset

    # --- Main instruction mix ---
    for i in range(num_instructions):
        # Weighted random: 40% R-type, 20% I-type, 15% Store, 15% Load, 10% Branch
        op_choice = random.choices(
            ['R', 'I', 'S', 'L', 'B'], 
            weights=[40, 20, 15, 15, 10]
        )[0]
        
        rd = random.randint(1, 31)  # Never write to x0
        rs1 = random.randint(1, 31) # Use x0 sometimes? Let's allow 0 for RS1 to test immediates.
        rs2 = random.randint(1, 31)
        
        imm = random.randint(-2048, 2047)  # 12-bit signed
        
        if op_choice == 'R':
            # Pick between add, sub, and, or, xor
            r_op = random.choice(['add', 'sub', 'and', 'or', 'xor'])
            if r_op == 'add':
                insts.append(pack_r_type(FUNCT7_ADD, rs2, rs1, FUNCT3_ADD, rd, OPCODE_R))
            elif r_op == 'sub':
                insts.append(pack_r_type(FUNCT7_SUB, rs2, rs1, FUNCT3_SUB, rd, OPCODE_R))
            elif r_op == 'and':
                insts.append(pack_r_type(0b0000000, rs2, rs1, FUNCT3_AND, rd, OPCODE_R))
            elif r_op == 'or':
                insts.append(pack_r_type(0b0000000, rs2, rs1, FUNCT3_OR, rd, OPCODE_R))
            elif r_op == 'xor':
                insts.append(pack_r_type(0b0000000, rs2, rs1, FUNCT3_XOR, rd, OPCODE_R))
        
        elif op_choice == 'I':
            # ALU Immediate (addi, andi, ori, xori)
            i_op = random.choice(['addi', 'andi', 'ori'])
            if i_op == 'addi':
                insts.append(pack_i_type(imm, rs1, FUNCT3_ADD, rd, OPCODE_I))
            elif i_op == 'andi':
                insts.append(pack_i_type(imm, rs1, FUNCT3_AND, rd, OPCODE_I))
            elif i_op == 'ori':
                insts.append(pack_i_type(imm, rs1, FUNCT3_OR, rd, OPCODE_I))
        
        elif op_choice == 'L':
            # Load Word: lw rd, imm(rs1)  - Use x3 (base=100) or x0 for absolute
            base = random.choice([3, 0])  # x3=100, or x0=0
            offset = random.randint(0, 60) & 0xFFC  # Align to word boundary (multiple of 4)
            insts.append(pack_i_type(offset, base, 0b010, rd, OPCODE_LOAD))  # funct3=010 for lw
        
        elif op_choice == 'S':
            # Store Word: sw rs2, imm(rs1)
            base = random.choice([3, 0])
            offset = random.randint(0, 60) & 0xFFC
            # Note: For stores, 'rd' field is reused to hold the offset bits, but our pack_s_type uses imm directly.
            insts.append(pack_s_type(offset, rs2, base, 0b010, OPCODE_STORE))
        
        elif op_choice == 'B':
            # Branch: Compare x1 and x2, branch forward if condition matches.
            # We use a fixed branch: If x1 == x2, skip the next instruction (forward jump).
            # To avoid infinite loops, ALWAYS branch forward by 8 bytes (1 instruction skip).
            branch_imm = 8  # Skip 1 instruction (PC+8)
            b_op = random.choice(['beq', 'bne'])
            if b_op == 'beq':
                insts.append(pack_b_type(branch_imm, rs2, rs1, FUNCT3_BEQ, OPCODE_BRANCH))
            else:
                insts.append(pack_b_type(branch_imm, rs2, rs1, FUNCT3_BNE, OPCODE_BRANCH))
            # Insert a dummy instruction that will be skipped if branch is taken, 
            # or executed if branch is not taken. This tests the pipeline.
            insts.append(pack_i_type(999, 0, FUNCT3_ADD, 31, OPCODE_I)) # x31 = 999 (should be skipped if branch taken)

    # --- End of program: Write a final value to x10 and stop ---
    # x10 = 0xDEADBEEF (signature to check)
    insts.append(pack_i_type(0xDEF, 0, FUNCT3_ADD, 10, OPCODE_LUI))  # lui x10, 0xDEF
    insts.append(pack_i_type(0xBEE, 10, FUNCT3_ADD, 10, OPCODE_I))   # addi x10, x10, 0xBEE
    
    # Ebreak (0x00100073) - Standard RISC-V halt instruction for Spike
    insts.append(0x00100073)  

    return insts

# --------------------------------------------------------------
# SAVE TO .s FILE (Assembly format for your Makefile)
# --------------------------------------------------------------
def save_random_program(insts, filename="riscv_assembly_examples/random.s"):
    os.makedirs("riscv_assembly_examples", exist_ok=True)
    with open(filename, "w") as f:
        f.write(".section .text\n")
        f.write(".global _start\n")
        f.write("_start:\n")
        for inst in insts:
            f.write(f"    .word 0x{inst:08x}\n")
    print(f"✅ Generated {len(insts)} random instructions -> {filename}")

if __name__ == "__main__":
    insts = generate_random_program(num_instructions=80)
    save_random_program(insts)