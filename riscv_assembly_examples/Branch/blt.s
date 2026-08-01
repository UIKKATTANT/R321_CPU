# blt.s - branch if rs1 < rs2 (signed)
li x5, -2
li x6, 3
blt x5, x6, less_label
less_label:
    # code here
