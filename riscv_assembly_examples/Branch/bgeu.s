# bgeu.s - branch if rs1 >= rs2 (unsigned)
li x5, 10
li x6, 3
bgeu x5, x6, geu_label     # branch taken
geu_label:
    # code here
