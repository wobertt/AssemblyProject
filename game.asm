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

.text


# --------------------- CONSTANTS --------------------- #
# TODO: reconsider what you're storing in registers. This probably isn't it if you're using functions.
# You have 18 registers, 8 saved and 10 temporary.
    .eqv PLAYER_X $s0
    li PLAYER_X 0

    .eqv PLAYER_Y $s1
    li PLAYER_Y 0

    .eqv BASE_ADR $s7
    li BASE_ADR 0x10008000

    .eqv KEY_ADR $s6
    li KEY_ADR 0xffff0000


# --------------------- MACROS --------------------- #
# I'm treating these as custom pseudoinstructions!

# Print the contents of register %s as an int.
.macro print_int (%s)
    move $a0, %s
    li $v0, 1
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
    
_while:
    jal check_movement
    jal draw_player
    
    sleep 100

    j _while


    # Exit
    li $v0, 10
    syscall


# Draw the player. The coordinates of the top-left pixel
# should be stored in PLAYER_X and PLAYER_Y.
# Overwrites $t0 and $t1.
draw_player:
    print_int PLAYER_X
    print_str " "
    print_int PLAYER_Y
    print_str "\n"
    # Set $t1 to actual memory location of top-left pixel
    move $t1, PLAYER_Y
    sll $t1, $t1, 6
    add $t1, $t1, PLAYER_X
    sll $t1, $t1, 2
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
		sw $t0, 32($t1)
		li $t0, 0xd3f9bc
		sw $t0, 36($t1)
		li $t0, 0xd3f9bc
		sw $t0, 40($t1)
		li $t0, 0xd3f9bc
		sw $t0, 44($t1)
		li $t0, 0xd3f9bc
		sw $t0, 48($t1)
		li $t0, 0xd3f9bc
		sw $t0, 52($t1)
		li $t0, 0xd3f9bc
		sw $t0, 56($t1)
		li $t0, 0x22b14c
		sw $t0, 60($t1)
		li $t0, 0x22b14c
		sw $t0, 64($t1)
		li $t0, 0xd3f9bc
		sw $t0, 68($t1)
		li $t0, 0xa8e61d
		sw $t0, 72($t1)
		li $t0, 0xd3f9bc
		sw $t0, 76($t1)
		li $t0, 0xd3f9bc
		sw $t0, 80($t1)
		li $t0, 0xa8e61d
		sw $t0, 84($t1)
		li $t0, 0xd3f9bc
		sw $t0, 88($t1)
		li $t0, 0x22b14c
		sw $t0, 92($t1)
		li $t0, 0x22b14c
		sw $t0, 96($t1)
		li $t0, 0xd3f9bc
		sw $t0, 100($t1)
		li $t0, 0xa8e61d
		sw $t0, 104($t1)
		li $t0, 0xd3f9bc
		sw $t0, 108($t1)
		li $t0, 0xd3f9bc
		sw $t0, 112($t1)
		li $t0, 0xa8e61d
		sw $t0, 116($t1)
		li $t0, 0xd3f9bc
		sw $t0, 120($t1)
		li $t0, 0x22b14c
		sw $t0, 124($t1)
		li $t0, 0x22b14c
		sw $t0, 128($t1)
		li $t0, 0xd3f9bc
		sw $t0, 132($t1)
		li $t0, 0xd3f9bc
		sw $t0, 136($t1)
		li $t0, 0xd3f9bc
		sw $t0, 140($t1)
		li $t0, 0xd3f9bc
		sw $t0, 144($t1)
		li $t0, 0xd3f9bc
		sw $t0, 148($t1)
		li $t0, 0xd3f9bc
		sw $t0, 152($t1)
		li $t0, 0x22b14c
		sw $t0, 156($t1)
		li $t0, 0x22b14c
		sw $t0, 160($t1)
		li $t0, 0xd3f9bc
		sw $t0, 164($t1)
		li $t0, 0xd3f9bc
		sw $t0, 168($t1)
		li $t0, 0xd3f9bc
		sw $t0, 172($t1)
		li $t0, 0xd3f9bc
		sw $t0, 176($t1)
		li $t0, 0xd3f9bc
		sw $t0, 180($t1)
		li $t0, 0xd3f9bc
		sw $t0, 184($t1)
		li $t0, 0x22b14c
		sw $t0, 188($t1)
		li $t0, 0x22b14c
		sw $t0, 192($t1)
		li $t0, 0xd3f9bc
		sw $t0, 196($t1)
		li $t0, 0xd3f9bc
		sw $t0, 200($t1)
		li $t0, 0xd3f9bc
		sw $t0, 204($t1)
		li $t0, 0xd3f9bc
		sw $t0, 208($t1)
		li $t0, 0xd3f9bc
		sw $t0, 212($t1)
		li $t0, 0xd3f9bc
		sw $t0, 216($t1)
		li $t0, 0x22b14c
		sw $t0, 220($t1)
		li $t0, 0x22b14c
		sw $t0, 224($t1)
		li $t0, 0x22b14c
		sw $t0, 228($t1)
		li $t0, 0x22b14c
		sw $t0, 232($t1)
		li $t0, 0x22b14c
		sw $t0, 236($t1)
		li $t0, 0x22b14c
		sw $t0, 240($t1)
		li $t0, 0x22b14c
		sw $t0, 244($t1)
		li $t0, 0x22b14c
		sw $t0, 248($t1)
		li $t0, 0x22b14c
		sw $t0, 252($t1)


# Update the player location based on the current keypress.
# Overwrites $t0.
check_movement:
    get_keypress $t0

    bne $t0, 119, move_player_left
    move_player_up:
        addi PLAYER_Y, PLAYER_Y, -1
        jr $ra

    bne $t0, 97, move_player_down 
    move_player_left:
        addi PLAYER_X, PLAYER_X, -1
        jr $ra

    bne $t0, 115, move_player_right
    move_player_down:
        addi PLAYER_Y, PLAYER_Y, 1
        jr $ra

    bne $t0, 100, move_player_none
    move_player_right:
        addi PLAYER_X, PLAYER_X, 1

    move_player_none:
        jr $ra
