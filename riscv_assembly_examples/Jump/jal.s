# jal.s - jump and link (call function)
jal x1, my_function
# after return
my_function:
    jalr x0, x1, 0     # return
