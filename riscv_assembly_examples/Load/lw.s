# lw.s - load word from memory
.data
my_data: .word 0x12345678
.text
la x5, my_data
lw x7, 0(x5)         # x7 = 0x12345678
