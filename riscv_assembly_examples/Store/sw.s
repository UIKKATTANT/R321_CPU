# sw.s - store word to memory
.data
my_data: .word 0
.text
li x6, 0xDEADBEEF
la x5, my_data
sw x6, 0(x5)         # memory[my_data] = 0xDEADBEEF
