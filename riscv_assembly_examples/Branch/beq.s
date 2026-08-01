# beq.s - branch if rs1 == rs2
li x5, 5
li x6, 5
beq x5, x6, equal_label
j end
equal_label:
    # code here
end:
