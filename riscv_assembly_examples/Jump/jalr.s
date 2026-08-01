# jalr.s - jump register (indirect call / return)
la x5, my_function
jalr x1, x5, 0         # call my_function
# ... later ...
my_function:
    jalr x0, x1, 0     # return
