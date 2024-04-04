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

    .eqv STATUS_ARR_ADR $s2
    la STATUS_ARR_ADR, grid_status_arr

    .eqv CUR_FRAME $s3
    move CUR_FRAME, $zero

    .eqv CLEAR_COLOUR $s4
    li CLEAR_COLOUR 0x0000ff

    .eqv CLEAR_STACK_ADR $s5    # Stores 4 + the address of the last element.
    la CLEAR_STACK_ADR, to_clear_stack

    .eqv KEY_ADR $s6
    li KEY_ADR, 0xffff0000

    .eqv BASE_ADR $s7
    li BASE_ADR, 0x10008000


# Numeric constants
    .eqv PLAYER_WIDTH 8
    .eqv PLAYER_HEIGHT 8
    .eqv MIN_PLAYER_X 0
    .eqv MIN_PLAYER_Y 0
    .eqv MAX_PLAYER_X 224
    .eqv MAX_PLAYER_Y 224

    .eqv DISPLAY_WIDTH_PIXELS 256

    # Status mask constants - MUST BE POWERS OF TWO
    .eqv PLATFORM_MASK 1
    .eqv NOT_PLATFORM_MASK 0xfffe

# --------------------- DATA --------------------- #
.data
    last_updated_arr: .word 0:4096 # Current frame (used to update this) is stored in register

    grid_status_arr: .word 0:4096

    to_clear_stack: .space 16384    # Stores addresses to locations on screen that should be cleared.
    to_clear_stack_size: .word 0

    newline_str: .asciiz "\n"

    player_hex_arr: .word 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c

# --------------------- MACROS --------------------- #
.text

# (All arguments are registers)
# Convert the pixel values stored in %x and %y into a grid address starting at %start_adr.
# The result is stored in %dest.
.macro to_address (%dest, %start_adr, %x, %y)
    sll %dest, %y, 6
    add %dest, %dest, %x
    add %dest, %dest, %start_adr
.end_macro

# Write the contents of %col_reg to the screen at pixels (%x, %y).
# Modifies $t8.
.macro colour (%x, %y, %col_reg)
    to_address $t8, BASE_ADR, %x, %y
    sw %col_reg, 0($t8)
.end_macro
### Grid status macros

# Check the %status_mask constant at (%x, %y) and store the result in %dest.
# If the status was set, %dest will be set to some nonzero value. Otherwise, it will be zero.
.macro check_status (%dest, %x, %y, %status_mask)
    # Initially %dest contains the address used to fetch the status
    to_address %dest, STATUS_ARR_ADR, %x, %y
    # Now %dest is the actual status
    lw %dest, 0(%dest)
    andi %dest, %dest, %status_mask
.end_macro

# Add %status_mask to the location (%x, %y).
# Modifies $t8, $t9.
.macro add_status (%x, %y, %status_mask)
    to_address $t8, STATUS_ARR_ADR, %x, %y
    lw $t9, 0($t8)
    ori $t9, $t9, %status_mask
    sw $t9, 0($t8)
.end_macro

# Remove %not_status_mask to the location (%x, %y).
# Modifies $t8, $t9.
# %not_status_mask should use the "NOT_" version of the status.
.macro remove_status (%x, %y, %not_status_mask)
    to_address $t8, STATUS_ARR_ADR, %x, %y
    lw $t9, 0($t8)
    andi $t9, $t9, %not_status_mask
    sw $t9, 0($t8)
.end_macro

### Printing macros

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
# Modifies $ra.
.macro mark_player_for_clear
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    jal mark_rectangle_for_clear
.end_macro

# Draw the player with top-left pixels (PLAYER_X, PLAYER_Y).
# Modifies $ra.
.macro draw_player
    to_address $a0, BASE_ADR, PLAYER_X, PLAYER_Y
    la $a1, player_hex_arr
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    jal draw_rectangle
.end_macro


# Apply %macro to each pixel in the rectangle starting at the pixel values ($a0, $a1), with height = $a2, width = $a3.
# %macro will be called with two registers (%x, %y) (must have %x and %y const!).
# For convenience, the temporary registers 5-9 will not be modified between calls to %macro.
.macro apply_rect (%macro)
    move $t0, $a0
    move $t1, $a1

    sll $t2, $a2, 2
    add $t2, $t2, $t0   # t2 = 4 + max_y

    sll $t3, $a3, 2
    add $t3, $t3, $t1 # t3 = 4 + max_x
    

    loop_y: bge $t0, $t2, done_loop_y

        move $t4, $t1
        loop_x: bge $t4, $t3, done_loop_x
            %macro $t4, $t0
            
            addi $t4, $t4, 4
            j loop_x
        done_loop_x:

        addi $t0, $t0, 4
        j loop_y
    done_loop_y:
.end_macro

# Draw a platform pixel at (%x, %y).
# Modifies $t9, $t8.
.macro draw_platform_pixel (%x, %y)
    li $t7, 0xff0000    # Platform colour
    colour %x, %y, $t7
    add_status %x, %y, PLATFORM_MASK
.end_macro

# Draw a platform at the rectangle starting at ($a0, $a1), with height=$a2, width=$a3.
# Modifies t registers.
.macro draw_platform
    apply_rect draw_platform_pixel
.end_macro


.globl main
main:
    
    li $a0, 64
    li $a1, 64
    li $a2, 8
    li $a3, 8
    draw_platform

_while:
    addi CUR_FRAME, CUR_FRAME, 1

    mark_player_for_clear
    jal check_movement
    draw_player
    jal clear_from_stack

    sleep 33

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
# Modifies t-registers.
clear_from_stack:
    # $t1 = address of stack size
    la $t1, to_clear_stack_size
    # $t0 = number of elements in stack
    lw $t0, 0($t1)

    la $t8, last_updated_arr
    sub $t8, $t8, BASE_ADR

    while_stack_nonempty: blez $t0, done_clear_from_stack
        addi CLEAR_STACK_ADR, CLEAR_STACK_ADR, -4
        # $t2 = address to clear from the screen
        # $t3 = last updated frame
        lw $t2, 0(CLEAR_STACK_ADR)
        add $t3, $t8, $t2
        lw $t3, 0($t3)

        beq $t3, CUR_FRAME, increment_while_stack_nonempty
        # Clear colour
        sw CLEAR_COLOUR, 0($t2)
    
    increment_while_stack_nonempty:
        addi $t0, $t0, -1
        j while_stack_nonempty

    done_clear_from_stack:
        sw $zero, 0($t1)    # Set stack size = 0
    jr $ra



# Draw the rectangle starting at the address $a0, with height = $a2, width = $a3.
# The address of the start of the colour array should be in $a1.
# Modifies $t0-$t8.
draw_rectangle:
    move $t0, $a0
    move $t1, $a1
    move $t2, $a2
    move $t3, $a3

    la $t8, last_updated_arr    # Offset for last_updated_arr
    sub $t8, $t8, BASE_ADR
 
    for_outer_drect: blez $t2, done_outer_drect
        move $t4, $t0   # Address for this row
        
        move $t5, $t3   # Counter for inner loop
        for_inner_drect: blez $t5, done_inner_drect
            # Draw (all drawing stuff is here)
            lw $t6, 0($t1)  # Load colour
            sw $t6, 0($t4)  # Draw to screen
            add $t7, $t4, $t8
            sw CUR_FRAME 0($t7) # Update last_updated_arr

            # Increment inner
            addi $t5, $t5, -1
            addi $t4, $t4, 4
            addi $t1, $t1, 4    # Colour array always increments
            j for_inner_drect
        done_inner_drect:
        # Increment outer
        addi $t2, $t2, -1
        addi $t0, $t0, DISPLAY_WIDTH_PIXELS
        j for_outer_drect
    done_outer_drect:
    jr $ra

# Update PLAYER_X and PLAYER_Y based on the current keypress.
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
