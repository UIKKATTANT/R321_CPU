# bltu.s - branch if rs1 < rs2 (unsigned)
li x5, 10
li x6, 3
bltu x5, x6, lessu_label   # no branch (10 >= 3)
lessu_label:
    # not reached
