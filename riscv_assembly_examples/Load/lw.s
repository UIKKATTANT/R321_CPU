.section .text
.global _start
_start:
    # Write 42 to address 0x80000100
    lui x2, 0x80000
    addi x2, x2, 0x100
    li x1, 42
    sw x1, 0(x2)
    # Load it back
    lw x3, 0(x2)
    # Stop
    ebreak
