# slti.s - rd = (rs1 < immediate) ? 1 : 0 (signed)
li x5, -3
slti x7, x5, 5       # x7 = 1
