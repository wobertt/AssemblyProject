.text
    li $t0, 1000000
    
while: beq $t0, 0, done
    addi $sp, $sp, -4
    lw $s0, 0($sp)
    sw $s0, 0($sp)

    addi $t0, $t0, -1
    j while

done:
