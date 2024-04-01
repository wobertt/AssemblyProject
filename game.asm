# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.text

    # Define constants
    .eqv RED $s0
    li RED 0xff0000

    .eqv BASE_ADR $s6
    li BASE_ADR 0x10008000

    .eqv KEY $s7
    li KEY 0xffff0000


# Sleep for %d milliseconds.
.macro sleep (%d)
    li $a0, %d
    li $v0, 32
    syscall
.end_macro

# Colour the pixel `offset` units after BASE_ADR
# with the colour %col,
# where `offset` is the value in register %s.
# 
# Modifies $t9.
.macro colour (%col, %s)
    add $t9, BASE_ADR, %s
    sw %col 0($t9)
.end_macro

.globl main
main:
    li $t0, 0
    
_while:
    colour RED, $t0
    sleep 1000
    addi $t0, $t0, 4
    j _while


    # Exit
    li $v0, 10
    syscall
