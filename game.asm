#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Robert Chung, 1009184473, chungro4, ro.chung@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# TODO - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# TODO (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# TODO Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
# TODO: add github link
# Any additional information that the TA needs to know:
# - (write here, if any)
# TODO
#####################################################################

# --------------------- CONSTANTS --------------------- #
.text
# TODO: reconsider what you're storing in registers. This probably isn't it if you're using functions.
# You have 18 registers, 8 saved and 10 temporary.

    # Stored in pixel format (always a multiple of 4).
    .eqv PLAYER_X $s0
    li PLAYER_X, 0

    .eqv PLAYER_Y $s1
    li PLAYER_Y, 0

    .eqv BASE_ADR $s7
    li BASE_ADR, 0x10008000

    .eqv KEY_ADR $s6
    li KEY_ADR, 0xffff0000

    .eqv CLEAR_STACK_ADR $s5    # Stores 4 + the address of the last element.
    la CLEAR_STACK_ADR, to_clear_stack

    .eqv CLEAR_COLOUR $s4
    li CLEAR_COLOUR 0x0000ff


# Numeric constants
    .eqv PLAYER_WIDTH 8
    .eqv PLAYER_HEIGHT 8
    .eqv MIN_PLAYER_X 0
    .eqv MIN_PLAYER_Y 0
    .eqv MAX_PLAYER_X 224
    .eqv MAX_PLAYER_Y 224

    .eqv DISPLAY_WIDTH_PIXELS 256

# --------------------- DATA --------------------- #
.data
    to_clear_stack: .space 16384    # Stores addresses to locations on screen that should be cleared.
    to_clear_stack_size: .word 0

    newline_str: .asciiz "\n"


# --------------------- MACROS --------------------- #
.text
# I'm treating these as custom pseudoinstructions!

# Print the contents of register %s as an int.
.macro print_int (%s)
    move $a0, %s
    li $v0, 1
    syscall
.end_macro

# Print the contents of register %s in hex.
.macro print_hex (%s)
    move $a0, %s
    li $v0, 34
    syscall
.end_macro

# Allocate memory for and print %str.
# %str should be a string in double quotes.
.macro print_str (%str)
    .data
    str_label: .asciiz %str
    .text
    la $a0, str_label
    li $v0, 4
    syscall
.end_macro

# Print a newline.
.macro print_newline
    la $a0, newline_str
    li $v0, 4
    syscall
.end_macro


# Store the current keypress in %s, if possible.
# If no key was pressed, 0 is stored.
.macro get_keypress (%s)
    # Implementation detail - %s is initially 0 (no keypress) or 1 (keypress)
    # This saves a register
    lw %s, 0(KEY_ADR)
    beq %s, 0, _done
    # If keypress, change 1 to the correct value
    lw %s, 4(KEY_ADR)
    _done:
.end_macro

# Sleep for %d milliseconds.
.macro sleep (%d)
    li $a0, %d
    li $v0, 32
    syscall
.end_macro

# Mark the current player's location for clearing.
.macro mark_player_for_clear
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    jal mark_rectangle_for_clear
.end_macro

.globl main
main:
    
_while:
    mark_player_for_clear
    jal check_movement
    jal draw_player
    jal clear_from_stack

    sleep 100

    j _while

    # Exit
    li $v0, 10
    syscall


# Mark the rectangle starting at ($a0, $a1) with height=$a2, width=$a3 for clearing.
# a0, a1 are in pixel format, while $a2 and $a3 are in normal format.
# Modifies $t0-$t7.
mark_rectangle_for_clear:
    move $t3, $a0
    move $t4, $a1
    move $t5, $a2
    move $t6, $a3
    # $t0 = increase to clear stack size
    mul $t0, $t5, $t6

    # $a2 = upper bound for $a0
    sll $t5, $t5, 2
    add $t5, $t5, $t3
    # a3 = upper bound for $a2
    sll $t6, $t6, 2
    add $t6, $t6, $t4

    for_outer_mrect: bge $t3, $t5, done_mrect
        move $t7, $t4   # Inner looping variable
        for_inner_mrect: bge $t7, $t6, done_inner_mrect
            # $t1 = actual address of pixel
            # (t3, t7) -> t3 * 64 + t7
            sll $t1, $t3, 6
            add $t1, $t1, $t7
            add $t1, $t1, BASE_ADR
            # Push actual address to be cleared to the stack.
            sw $t1, 0(CLEAR_STACK_ADR)

            addi CLEAR_STACK_ADR, CLEAR_STACK_ADR, 4

            addi $t7, $t7, 4
        j for_inner_mrect

        done_inner_mrect:
        addi $t3, $t3, 4
    j for_outer_mrect
    
    done_mrect:
        # Update stack size (add $t0)
        la $t2, to_clear_stack_size
        lw $t1, 0($t2)
        add $t1, $t1, $t0
        sw $t1, 0($t2)
    jr $ra

# Clear all addresses specified in to_clear_stack.
# Modifies $t0, $t1, $t2.
clear_from_stack:
    # $t1 = address of stack size
    la $t1, to_clear_stack_size
    # $t0 = number of elements in stack
    lw $t0, 0($t1)

    while_stack_nonempty: blez $t0, done_clear_from_stack
        addi CLEAR_STACK_ADR, CLEAR_STACK_ADR, -4
        # $t2 = address to clear from the screen
        lw $t2, 0(CLEAR_STACK_ADR)
        sw CLEAR_COLOUR, 0($t2)

        addi $t0, $t0, -1
        j while_stack_nonempty

    done_clear_from_stack:
        sw $zero, 0($t1)    # Set stack size = 0
    jr $ra

# Draw the player. The coordinates of the top-left pixel
# should be stored in PLAYER_X and PLAYER_Y.
# Overwrites $t0 and $t1.
draw_player:
    # Set $t1 to actual memory location of top-left pixel
    move $t1, PLAYER_Y
    sll $t1, $t1, 6
    add $t1, $t1, PLAYER_X
    add $t1, $t1, BASE_ADR

    draw_player_pixels:
		li $t0, 0x22b14c
		sw $t0, 0($t1)
		li $t0, 0x22b14c
		sw $t0, 4($t1)
		li $t0, 0x22b14c
		sw $t0, 8($t1)
		li $t0, 0x22b14c
		sw $t0, 12($t1)
		li $t0, 0x22b14c
		sw $t0, 16($t1)
		li $t0, 0x22b14c
		sw $t0, 20($t1)
		li $t0, 0x22b14c
		sw $t0, 24($t1)
		li $t0, 0x22b14c
		sw $t0, 28($t1)
		li $t0, 0x22b14c
		sw $t0, 256($t1)
		li $t0, 0xd3f9bc
		sw $t0, 260($t1)
		li $t0, 0xd3f9bc
		sw $t0, 264($t1)
		li $t0, 0xd3f9bc
		sw $t0, 268($t1)
		li $t0, 0xd3f9bc
		sw $t0, 272($t1)
		li $t0, 0xd3f9bc
		sw $t0, 276($t1)
		li $t0, 0xd3f9bc
		sw $t0, 280($t1)
		li $t0, 0x22b14c
		sw $t0, 284($t1)
		li $t0, 0x22b14c
		sw $t0, 512($t1)
		li $t0, 0xd3f9bc
		sw $t0, 516($t1)
		li $t0, 0xa8e61d
		sw $t0, 520($t1)
		li $t0, 0xd3f9bc
		sw $t0, 524($t1)
		li $t0, 0xd3f9bc
		sw $t0, 528($t1)
		li $t0, 0xa8e61d
		sw $t0, 532($t1)
		li $t0, 0xd3f9bc
		sw $t0, 536($t1)
		li $t0, 0x22b14c
		sw $t0, 540($t1)
		li $t0, 0x22b14c
		sw $t0, 768($t1)
		li $t0, 0xd3f9bc
		sw $t0, 772($t1)
		li $t0, 0xa8e61d
		sw $t0, 776($t1)
		li $t0, 0xd3f9bc
		sw $t0, 780($t1)
		li $t0, 0xd3f9bc
		sw $t0, 784($t1)
		li $t0, 0xa8e61d
		sw $t0, 788($t1)
		li $t0, 0xd3f9bc
		sw $t0, 792($t1)
		li $t0, 0x22b14c
		sw $t0, 796($t1)
		li $t0, 0x22b14c
		sw $t0, 1024($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1028($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1032($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1036($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1040($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1044($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1048($t1)
		li $t0, 0x22b14c
		sw $t0, 1052($t1)
		li $t0, 0x22b14c
		sw $t0, 1280($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1284($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1288($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1292($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1296($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1300($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1304($t1)
		li $t0, 0x22b14c
		sw $t0, 1308($t1)
		li $t0, 0x22b14c
		sw $t0, 1536($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1540($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1544($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1548($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1552($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1556($t1)
		li $t0, 0xd3f9bc
		sw $t0, 1560($t1)
		li $t0, 0x22b14c
		sw $t0, 1564($t1)
		li $t0, 0x22b14c
		sw $t0, 1792($t1)
		li $t0, 0x22b14c
		sw $t0, 1796($t1)
		li $t0, 0x22b14c
		sw $t0, 1800($t1)
		li $t0, 0x22b14c
		sw $t0, 1804($t1)
		li $t0, 0x22b14c
		sw $t0, 1808($t1)
		li $t0, 0x22b14c
		sw $t0, 1812($t1)
		li $t0, 0x22b14c
		sw $t0, 1816($t1)
		li $t0, 0x22b14c
		sw $t0, 1820($t1)



# Update the PLAYER_X and PLAYER_Y based on the current keypress.
# Overwrites $t0.
check_movement:
    get_keypress $t0

    move_player_up: bne $t0, 119, move_player_left
        beq PLAYER_Y, MIN_PLAYER_Y, move_player_none
        addi PLAYER_Y, PLAYER_Y, -4
        jr $ra

    move_player_left: bne $t0, 97, move_player_down 
        beq PLAYER_X, MIN_PLAYER_X, move_player_none
        addi PLAYER_X, PLAYER_X, -4
        jr $ra

    move_player_down: bne $t0, 115, move_player_right
        beq PLAYER_Y, MAX_PLAYER_Y, move_player_none
        addi PLAYER_Y, PLAYER_Y, 4
        jr $ra

    move_player_right: bne $t0, 100, move_player_none
        beq PLAYER_X, MAX_PLAYER_Y, move_player_none
        addi PLAYER_X, PLAYER_X, 4

    move_player_none:
        jr $ra
