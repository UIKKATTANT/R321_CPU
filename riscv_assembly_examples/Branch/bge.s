# bge.s - branch if rs1 >= rs2 (signed)
li x5, 5
li x6, 3
bge x5, x6, ge_label
ge_label:
    # code here
