# bne.s - branch if rs1 != rs2
li x5, 5
li x6, 3
bne x5, x6, not_equal_label
not_equal_label:
    # code here
