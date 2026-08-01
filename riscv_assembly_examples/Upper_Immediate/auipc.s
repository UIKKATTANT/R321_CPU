# auipc.s - add upper immediate to PC (rd = PC + (imm << 12))
auipc x5, 0x12345      # x5 = current_PC + 0x12345000
