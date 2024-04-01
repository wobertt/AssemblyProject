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



# Update the player location based on the current keypress.
# Overwrites $t0.
check_movement:
    get_keypress $t0

    move_player_up: bne $t0, 119, move_player_left
        addi PLAYER_Y, PLAYER_Y, -1
        jr $ra

    move_player_left: bne $t0, 97, move_player_down 
        addi PLAYER_X, PLAYER_X, -1
        jr $ra

    move_player_down: bne $t0, 115, move_player_right
        addi PLAYER_Y, PLAYER_Y, 1
        jr $ra

    move_player_right: bne $t0, 100, move_player_none
        addi PLAYER_X, PLAYER_X, 1

    move_player_none:
        jr $ra
