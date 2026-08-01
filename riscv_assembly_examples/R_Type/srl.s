# srl.s - rd = rs1 >> rs2 (logical right, zero-fill)
li x5, 0b1000
li x6, 2
srl x7, x5, x6   # x7 = 0b0010 (2)
