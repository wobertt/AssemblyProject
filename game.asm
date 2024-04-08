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
    # Stored in pixel format (always a multiple of 4).
    .eqv PLAYER_X $s0
    .eqv PLAYER_Y $s1

    .eqv STATUS_ARR_ADR $s2
    la STATUS_ARR_ADR, grid_status_arr

    .eqv CUR_FRAME $s3
    move CUR_FRAME, $zero

    .eqv CLEAR_COLOUR $s4
    li CLEAR_COLOUR, 0x0

    # Grows in + direction; stores 4 + the address of the last element.
    .eqv CLEAR_STACK_ADR $s5    

    .eqv KEY_ADR $s6
    li KEY_ADR, 0xffff0000

    .eqv BASE_ADR $s7
    li BASE_ADR, 0x10008000


# Numeric constants
    # Player
    .eqv PLAYER_WIDTH 8
    .eqv PLAYER_HEIGHT 8
    .eqv JUMP_HEIGHT 12

    # Display
    .eqv DISPLAY_WIDTH_PIXELS 256
    .eqv GAME_OVER_WIDTH 42
    .eqv GAME_OVER_HEIGHT 5
    .eqv STAR_SIZE 10
    .eqv STAR_SIZE_4 40

    # Status masks
    .eqv NO_OVERLAP_MASK 1
    .eqv REMOVE_OVERLAP_MASK 0xfffe
    .eqv PLAYER_MASK 4
    .eqv REMOVE_PLAYER_MASK 0xfffb
    .eqv REMOVE_ALL 0

    # Colours
    .eqv SKY_BLUE 0x99d9ea
    .eqv DIRT 0x9c5a3c
    .eqv DARK_GRAY 0x464646
    .eqv LIGHT_GRAY 0xb4b4b4
    .eqv HEALTHBAR_FULL 0x22b14c
    .eqv HEALTHBAR_EMPTY 0xb4b4b4

    # Objects/enemies
    .eqv COIN_TYPE 1
    .eqv COIN_WIDTH 3

    .eqv BASIC_ENEMY_TYPE 2
    .eqv ENEMY_HEIGHT 5
    .eqv ENEMY_WIDTH 5

    .eqv OBJ_SIZE 8         # struct size
    .eqv OBJ_SIZE_POW 3     # log(size)


# --------------------- DATA --------------------- #
.data
    last_updated_arr: .word 0:4096 # Current frame (used to update this) is stored in register

    grid_status_arr: .word 0:4096

    to_clear_stack: .space 16384    # Stores addresses to locations on screen that should be cleared.
    to_clear_stack_size: .word 0

    player_hex_arr: .word 0x22b14c, 0x22b14c, 0x0022b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0xd3f9bc, 0xa8e61d, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0xd3f9bc, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c, 0x22b14c
    player_hurt_hex_arr: .word 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xed1c24, 0xed1c24, 0xf5e49c, 0xff7e00, 0xf5e49c, 0xf5e49c, 0xff7e00, 0xf5e49c, 0xed1c24, 0xed1c24, 0xf5e49c, 0xff7e00, 0xf5e49c, 0xf5e49c, 0xff7e00, 0xf5e49c, 0xed1c24, 0xed1c24, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xed1c24, 0xed1c24, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xed1c24, 0xed1c24, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xf5e49c, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24
    enemy_hex_arr: .word 0x990030, 0x0, 0x0, 0x0, 0x990030, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0x1, 0xed1c24, 0x1, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24, 0xed1c24
    coin_hex_arr: .word 0xfff200, 0xfff200, 0xfff200, 0xfff200, 0xffc20e, 0xfff200, 0xfff200, 0xfff200, 0xfff200
    gameover_hex_arr: .word 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0xffffff, 0x0, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0x0, 0xffffff, 0x0, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0x0, 0xffffff, 0x0, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0x0, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0x0, 0xffffff, 0xffffff, 0xffffff, 0x0, 0x0, 0x0, 0xffffff, 0x0, 0xffffff, 0xffffff, 0x0
    gray_star_hex_arr: .word 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xbabab3, 0xbabab3, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff
    yellow_star_hex_arr: .word 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0xffc20e, 0xffc20e, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0

    newline_str: .asciiz "\n"

    player_info: .word 0 0 0 2 3 0
    # xvel (0), yvel (4),
    # jump_end (8), jumps_remaining (12),
    # health_remaining (16),
    # hurt_frame (20)

    # TODO - update OBJ_SIZE_POW as needed
    object_arr: .space 16384
    # alive/dead (0), object_type (1),
    # pos_x (2), pos_y (3), obj_length (4), direction (5), 
    # min_x (6), max_x (7)
    # TODO - remember that it's lbu not lb, except for direction

    num_objects: .word 0 0 0
    # total objects (0), enemies alive (4), coins alive (8)

    current_level: .word 0
    

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
# Modifies t8.
.macro colour (%x, %y, %col_reg)
    to_address $t8, BASE_ADR, %x, %y
    sw %col_reg, 0($t8)
.end_macro

# Write the colour specified at %col_adr to (%x, %y),
# then increment to the next address.
# Modifies t8-t9.
.macro colour_address_and_increment (%x, %y, %col_adr)
    to_address $t8, BASE_ADR, %x, %y
    lw $t9, 0(%col_adr)
    sw $t9, 0($t8)
    addi %col_adr, %col_adr, 4
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

### Rectangle macros

# Pass the specified immediate values as function arguments
# for use in other rect macros.
.macro set_rect (%x_imm, %y_imm, %width_imm, %height_imm)
    li $a0, %y_imm
    li $a1, %x_imm
    li $a2, %height_imm
    li $a3, %width_imm
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
    add $t3, $t3, $t1   # t3 = 4 + max_x
    
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
# Same as above but with %args passed to %macro.
.macro apply_rect (%macro, %args)
    move $t0, $a0
    move $t1, $a1

    sll $t2, $a2, 2
    add $t2, $t2, $t0   # t2 = 4 + max_y

    sll $t3, $a3, 2
    add $t3, $t3, $t1   # t3 = 4 + max_x
    
    loop_y: bge $t0, $t2, done_loop_y

        move $t4, $t1
        loop_x: bge $t4, $t3, done_loop_x
            %macro $t4, $t0, %args
            
            addi $t4, $t4, 4
            j loop_x
        done_loop_x:

        addi $t0, $t0, 4
        j loop_y
    done_loop_y:
.end_macro

# Draw an object with $a0-$a3 specified as usual,
# and the start of the colour array stored in %col_arr.
# t0-t4, t6, t8 will be modified. The convention is %col_arr = $t5.
.macro draw_from_hex_arr (%col_arr)
    apply_rect colour_address_and_increment %col_arr
.end_macro

# Mark the current pixel (%x, %y) for clearing.
# Modifies t8-t9.
.macro mark_pixel_for_clear (%x, %y)
    to_address $t8, BASE_ADR, %x, %y
    sw $t8, 0(CLEAR_STACK_ADR)  # Add address to stack
    addi CLEAR_STACK_ADR, CLEAR_STACK_ADR, 4

    # Increment stack size
    la $t9, to_clear_stack_size
    lw $t8, 0($t9)
    addi $t8, $t8, 1
    sw $t8, 0($t9)
.end_macro

# Mark the current player's location for clearing.
# This also removes the player status from the cleared pixels.
# Modifies t0-t4, t8-t9.
.macro mark_player_for_clear
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    apply_rect mark_pixel_for_clear
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    apply_rect remove_status REMOVE_PLAYER_MASK
.end_macro

# Mark the current pixel as being updated this frame,
# so it won't be cleared.
# Modifies t8.
.macro mark_pixel_no_clear (%x, %y)
    la $t9, last_updated_arr
    to_address $t8, $t9, %x, %y
    sw CUR_FRAME 0($t8)
.end_macro

# Draw the player with top-left pixels (PLAYER_X, PLAYER_Y).
# In addition to the actual drawing, this marks the player pixels as no-clear
# and adds PLAYER_MASK.
.macro draw_player
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    # Choose colour array based on last hurt frame
    la $t0, player_info
    lw $t0, 20($t0)
    load_normal_player: beq $t0, CUR_FRAME, load_hurt_player
        la $t5, player_hex_arr
        j continue_draw_player
    load_hurt_player:
        la $t5, player_hurt_hex_arr
    continue_draw_player:
    draw_from_hex_arr $t5

    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    apply_rect mark_pixel_no_clear
    
    move $a0, PLAYER_Y
    move $a1, PLAYER_X
    li $a2, PLAYER_HEIGHT
    li $a3, PLAYER_WIDTH
    apply_rect add_status PLAYER_MASK
.end_macro

# Draw an enemy pixel at (%x, %y).
# Assumes that &col_arr[i] is in $t5; this address will be incremented.
.macro draw_enemy_pixel (%x, %y)
    lw $t6, 0($t5)  # col
    
    beq $t6, $zero, done_drawing    # 0x0 is "transparent"; don't draw
    colour %x, %y, $t6

    done_drawing:
    addi $t5, $t5, 4
.end_macro
# Draw an enemy starting at ($a0, $a1).
# Modifies t0-t6, t8.
.macro draw_enemy
    la $t5, enemy_hex_arr
    li $a2, ENEMY_HEIGHT
    li $a3, ENEMY_WIDTH
    apply_rect draw_enemy_pixel
.end_macro

# Draw a platform pixel at (%x, %y). The colour should be in %col_reg.
# Modifies $t8-t9.
.macro draw_platform_pixel (%x, %y, %col_reg)
    colour %x, %y, %col_reg
    add_status %x, %y, NO_OVERLAP_MASK
.end_macro
# Draw a platform at the rectangle starting at ($a0, $a1), with height=$a2, width=$a3.
# Uses the colour specified in the register %platform_colour.
# Modifies t-registers.
.macro draw_platform (%platform_color)
    apply_rect draw_platform_pixel, %platform_color
.end_macro

# Set v0 to a nonzero value if (%x, %y) has %status_mask,
# and leave it the same otherwise.
# Modifies v1.
.macro has_collision_pixel (%x, %y, %status_mask)
    check_status $v1, %x, %y, %status_mask
    or $v0, $v0, $v1
.end_macro
# Check if any pixel in the given rectangle contains %status_mask.
# v0 will be nonzero if the status was found, and it will be zero otherwise.
# a0-a3 are specified as usual.
.macro has_collision (%status_mask)
    move $v0, $zero
    apply_rect has_collision_pixel %status_mask
.end_macro

## Object management

# Add a basic enemy object at the immediate location (%pos_x, %pos_y).
.macro add_basic_enemy_object (%pos_x, %pos_y)
    la $t0, num_objects
    la $t1, object_arr
    
    # Get offset
    lw $t2, 0($t0)
    sll $t3, $t2, OBJ_SIZE_POW
    add $t1, $t1, $t3   # t1 = start of new obj struct

    # num_objects++
    addi $t2, $t2, 1
    sw $t2, 0($t0)

    # alive_enemies++
    lw $t3, 4($t0)
    addi $t3, $t3, 1
    sw $t3, 4($t0)

    # Populate object fields
    li $t3, 1
    sb $t3, 0($t1)  # alive = 1
    li $t3, BASIC_ENEMY_TYPE
    sb $t3, 1($t1)  # type = BASIC_ENEMY_TYPE
    li $t3, %pos_x
    sb $t3, 2($t1)  # pos_x = %pos_x
    li $t3, %pos_y
    sb $t3, 3($t1)  # pos_y = %pos_y
    li $t3, ENEMY_WIDTH
    sb $t3, 4($t1)  # length = 5
    # There are more fields, but the basic enemy doesn't use them
.end_macro

# Add a coin object at the immediate location (%pos_x, %pos_y).
.macro add_coin_object (%pos_x, %pos_y)
    la $t0, num_objects
    la $t1, object_arr
    
    # Get offset
    lw $t2, 0($t0)
    sll $t3, $t2, OBJ_SIZE_POW
    add $t1, $t1, $t3   # t1 = start of new obj struct

    # num_objects++
    addi $t2, $t2, 1
    sw $t2, 0($t0)

    # num_coins++
    lw $t3, 8($t0)
    addi $t3, $t3, 1
    sw $t3, 8($t0)

    # Populate object fields
    li $t3, 1
    sb $t3, 0($t1)  # alive = 1
    li $t3, COIN_TYPE
    sb $t3, 1($t1)  # type = COIN_TYPE
    li $t3, %pos_x
    sb $t3, 2($t1)  # pos_x = %pos_x
    li $t3, %pos_y
    sb $t3, 3($t1)  # pos_y = %pos_y
    li $t3, COIN_WIDTH
    sb $t3, 4($t1)  # length = COIN_WIDTH
.end_macro

# Update the enemy status (dead + cleared from screen)
# and the player health after a collision.
# %enemy_adr should contain the address of the enemy object struct.
.macro handle_enemy_collision (%enemy_adr)
    # Check if the player collided anywhere else besides the top - if they did, reduce health
    lbu $a0, 3(%enemy_adr)
    addi $a0, $a0, 4    # y++
    lbu $a1, 2(%enemy_adr)
    lbu $a2, 4(%enemy_adr)
    addi $a2, $a2, -1   # height--
    lbu $a3, 4(%enemy_adr)
    has_collision PLAYER_MASK

    beq $v0, $zero, kill_enemy  # v0 = 0 means no side collision
    player_hurt:
        add_health (-1)
        la $t1, player_info
        sw CUR_FRAME, 20($t1)
    kill_enemy:
        lbu $a0, 3(%enemy_adr)
        lbu $a1, 2(%enemy_adr)
        lbu $a2, 4(%enemy_adr)
        lbu $a3, 4(%enemy_adr)
        apply_rect mark_pixel_for_clear
        sw $zero, 0(%enemy_adr)    # alive = false
    
    # alive_enemies--
    la $t0, num_objects
    lw $t1, 4($t0)
    addi $t1, $t1, -1
    sw $t1, 4($t0)
.end_macro

# Update a coin's status (dead + cleared from screen)
# and possibly the player's health after collision.
# %coin_adr should contain the address of the coin object struct.
.macro handle_coin_collision (%coin_adr)
    lbu $a0, 3(%coin_adr)
    lbu $a1, 2(%coin_adr)
    lbu $a2, 4(%coin_adr)
    lbu $a3, 4(%coin_adr)
    apply_rect mark_pixel_for_clear
    sw $zero, 0(%coin_adr)    # alive = false

    # num_coins--
    la $t0, num_objects
    lw $t1, 8($t0)
    addi $t1, $t1, -1
    sw $t1, 8($t0)

    zero_coins: bne $t1, $zero, done
        add_health 1
    done:
.end_macro

## Healthbar 

# Draw the healthbar.
# Modifies t-registers.
.macro draw_healthbar
    la $t5, player_info
    lw $t5, 16($t5) # t5 = health

    li $t7, HEALTHBAR_FULL
    set_rect 12, 12, 0, 2   
    sll $a3, $t5, 1 # width = health*2
    apply_rect colour, $t7

    li $t7, HEALTHBAR_EMPTY
    set_rect 0, 12, 5, 2
    # xleft = 12 + health*8
    sll $a1, $t5, 3
    addi $a1, $a1, 12
    # width = (5-health)*2
    sub $a3, $a3, $t5
    sll $a3, $a3, 1
    apply_rect colour, $t7
.end_macro

# Add an immediate value, %amt, to the healthbar.
# Note that the player health is capped at 5 units.
.macro add_health (%amt)
    la $t5, player_info
    lw $t6, 16($t5)
    addi $t6, $t6, %amt

    limit_health: ble $t6, 5, set_health
        li $t6, 5
    set_health:
        sw $t6, 16($t5)
.end_macro

### Level initialization

# Draw a minimal set of borders to stop the player from going out-of-bounds.
.macro draw_borders
    # Floor
    set_rect 0, 252, 64, 1
    draw_platform CLEAR_COLOUR
    # Left border
    set_rect 0, 0, 1, 64
    draw_platform CLEAR_COLOUR
    # Right border
    set_rect 252, 0, 1, 64
    draw_platform CLEAR_COLOUR
    # Ceiling
    set_rect 0, 0, 64, 4
    draw_platform CLEAR_COLOUR
.end_macro

### Initialization 

# Reset all non-level-specific data and s-registers.
# Level-specific data should be handled separately.
.macro reset_data
    addi CUR_FRAME, CUR_FRAME, 1    # Lazy reset for last_updated_arr

    # Clear screen
    set_rect 0, 0, 64, 64
    apply_rect colour, CLEAR_COLOUR

    # Reset grid_status_arr
    set_rect 0, 0, 64, 64
    apply_rect remove_status, REMOVE_ALL

    # Reset to_clear_stack
    la CLEAR_STACK_ADR, to_clear_stack
    la $t0, to_clear_stack_size
    sw $zero, 0($t0)

    # Reset player_info
    la $t0, player_info
    sw $zero, 0($t0)
    sw $zero, 4($t0)
    sw $zero, 8($t0)
    li $t1, 2
    sw $t1, 12($t0)
    li $t1, 3
    sw $t1, 16($t0)
    sw $zero, 20($t0)

    # Reset num_objects
    la $t0, num_objects
    sw $zero, 0($t0)
    sw $zero, 4($t0)
    sw $zero, 8($t0)
.end_macro

# Set data for level one.
.macro start_level_one
    # Set background
    li CLEAR_COLOUR, SKY_BLUE
    set_rect 0, 0, 64, 64
    apply_rect colour, CLEAR_COLOUR
    draw_borders

    li PLAYER_X, 20
    li PLAYER_Y, 208

    # Level-specific objects
    # Ground
    li $t7, DIRT
    set_rect 0, 240, 64, 4
    draw_platform $t7
    # Platforms
    li $t7, DARK_GRAY
    set_rect 120, 164, 34, 2
    draw_platform $t7
    set_rect 0, 104, 22, 2
    draw_platform $t7
    set_rect 188, 84, 17, 2
    draw_platform $t7
    # Rock thing
    li $t7, LIGHT_GRAY
    set_rect 100, 232, 9, 2
    draw_platform $t7
    set_rect 104, 228, 8, 1
    draw_platform $t7
    set_rect 108, 224, 6, 1
    draw_platform $t7
    set_rect 112, 220, 4, 1
    draw_platform $t7
    # Enemies
    add_basic_enemy_object 4, 84
    add_basic_enemy_object 212, 220
    add_basic_enemy_object 220, 144
    add_basic_enemy_object 204, 64
    # Coins
    add_coin_object 64, 84
    add_coin_object 132, 144
    add_coin_object 236, 68
.end_macro

# Initialize data based on the value in current_level.
.macro initialize_current_level
    la $t0, current_level
    lw $t0, 0($t0)

    level_one: bne $t0, 1, level_two
        start_level_one
        j done_select
    level_two:
        start_level_one # TODO - update
    
    done_select:
.end_macro

.globl main
main:
    # Set to level one
    la $t0, current_level
    li $t1, 1
    sw $t1, 0($t0)

select_level:
    reset_data
    initialize_current_level

main_loop:
    addi CUR_FRAME, CUR_FRAME, 1

    jal update_objects
    mark_player_for_clear
    jal check_keypress
    jal get_yvel_from_jump
    jal apply_movement
    draw_player
    draw_healthbar
    jal clear_from_stack

    sleep 30

    jal check_level_fail
    jal check_level_success

    j main_loop

    # Exit
    li $v0, 10
    syscall
# Check if the player has 0 health.
# If they do, display the game over screen, then go back to the beginning.
check_level_fail:
    la $t0, player_info
    lw $t1, 16($t0) # health

    bne $t1, $zero, no_level_fail

    # Draw game over screen
    set_rect 0, 0, 64, 64
    li CLEAR_COLOUR 0xffffff
    apply_rect colour CLEAR_COLOUR
    
    set_rect 44, 76, GAME_OVER_WIDTH, GAME_OVER_HEIGHT
    la $t5, gameover_hex_arr
    apply_rect colour_address_and_increment $t5

    li $t6, 28
    li $t7, 228  # start_x + 4(5 * STAR_SIZE)
    draw_stars: bge $t6, $t7, done_draw_stars
        set_rect 0, 132, STAR_SIZE, STAR_SIZE
        move $a1, $t6
        la $t5, gray_star_hex_arr
        apply_rect colour_address_and_increment $t5
    draw_stars_increment:
        addi $t6, $t6, STAR_SIZE_4
        j draw_stars

    done_draw_stars:
    sleep 3000
    
    j main  # Back to the beginning

    no_level_fail:
        jr $ra

# Check if the player has met the win condition for the current level.
# If they have, jump to select_level.
check_level_success:
    la $t0, num_objects
    lw $t1, 4($t0)

    bne $t1, $zero, no_level_success  # nonzero enemies remaining -> no success
    level_success:
        addi $t1, $t1, 1
        sw $t1, 0($t0)  # current_level++
        j select_level
    no_level_success:
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
# Update all objects (redraw and check collisions).
# Modifies t-registers.
update_objects:
    sw $s0, -4($sp)
    sw $s1, -8($sp)
    sw $s6, -12($sp)
    addi $sp, $sp, -12

    la $s0, object_arr
    la $s1, num_objects
    lw $s1, 0($s1)
    sll $s1, $s1, OBJ_SIZE_POW
    add $s1, $s1, $s0
    # for (s0 = &obj_arr[0]; s0 < s1; s0 += sizeof(obj struct))

    for_objects: bge $s0, $s1, done_for_objects
        # Decide if we need to kill the object
        # If we don't, redraw it at the correct spot
        lbu $t0, 0($s0) # alive
        beq $t0, $zero, increment   # don't draw dead enemies

        lbu $a0, 3($s0)
        lbu $a1, 2($s0)
        lbu $a2, 4($s0)
        lbu $a3, 4($s0)
        has_collision PLAYER_MASK

        ## Type-specific logic

        lbu $t0, 1($s0) # obj type
        if_basic_enemy: bne $t0, BASIC_ENEMY_TYPE, if_coin
            # Only draw if they didn't collide with player
            beq $v0, $zero, draw_basic_enemy
            handle_enemy_collision $s0
            j increment

            draw_basic_enemy:
            lbu $a0, 3($s0)
            lbu $a1, 2($s0)
            lbu $a2, 4($s0)
            lbu $a3, 4($s0)
            draw_enemy  # Overwrites t0-t6, t8!!

            j increment

        if_coin: bne $t0, COIN_TYPE, increment
            beq $v0, $zero, draw_coin
            handle_coin_collision $s0
            j increment

            draw_coin:
            lbu $a0, 3($s0)
            lbu $a1, 2($s0)
            lbu $a2, 4($s0)
            lbu $a3, 4($s0)
            la $t5, coin_hex_arr

            apply_rect colour_address_and_increment $t5

            j increment

    increment:
        addi $s0, $s0, OBJ_SIZE
        j for_objects
    
    done_for_objects:
        addi $sp, $sp, 12
        lw $s0, -4($sp)
        lw $s1, -8($sp)
        lw $s6, -12($sp)
        jr $ra


# Check for all keypresses and handle them accordingly.
# Modifies t-registers.
check_keypress:

    get_keypress $t0

    la $t1, player_info  # offset 0 for xvel, 8 for jump status
    # t2 = xvel for this iter, t3 = end of jump frame
    move $t2, $zero
    lw $t3, 8($t1)  # jump frame
    lw $t4, 12($t1) # jumps remaining

    w_keypress: bne $t0, 119, a_keypress
        ble CUR_FRAME, $t3, done_keypress   # Already jumping or just finished jumping
        blez $t4, done_keypress             # No jumps remaining
        
        # Jump
        addi $t3, CUR_FRAME, JUMP_HEIGHT
        addi $t4, $t4, -1
        j done_keypress

    a_keypress: bne $t0, 97, d_keypress
        li $t2, -4
        j done_keypress

    d_keypress: bne $t0, 100, r_keypress
        li $t2, 4
        j done_keypress
    
    r_keypress: bne $t0, 114, h_keypress
        j main  # Reset
    
    h_keypress: bne $t0, 104, k_keypress
        add_health 1
        j done_keypress

    k_keypress: bne $t0, 107, q_keypress
        add_health (-1)
        j done_keypress

    q_keypress: bne $t0, 113, done_keypress
        # Exit the game
        li $v0, 10
        syscall


    done_keypress:
        sw $t2, 0($t1)  # Store xvel
        sw $t3, 8($t1)  # Store jump status
        sw $t4, 12($t1) # Store jumps remaining
        jr $ra

# Modify the player's yvel based on the jump status.
get_yvel_from_jump:
    la $t1, player_info
    lw $t0, 8($t1)  # jump status

    # t2 = yvel

    is_jumping: bge CUR_FRAME, $t0, is_not_jumping
        li $t2, -4
        j update_yvel
    is_not_jumping:
        li $t2, 4   # Gravity

    update_yvel:
        sw $t2, 4($t1)
    
    jr $ra

# Move the player based on player_info.
# This does collision and out-of-bounds checking,
# and updates the number of available jumps.
# Modifies t-registers.
apply_movement:

    la $t1, player_info

    # The player can only jump once if already in the air.
    # If they're touching a platform,
    # we'll update the allowed jumps to 2 later on.
    lw $t0, 12($t1) # jumps remaining
    blt $t0, 2, continue_check_movement
    li $t0, 1
    sw $t0, 12($t1)

    continue_check_movement:

    lw $t2, 0($t1)  # xvel
    lw $t3, 4($t1)  # yvel

    check_movement_x: beq $t2, $zero, check_movement_y
        # t4 = x-value to check.
        # t6 = is valid (bool)
        li $t6, 1

        addi $t5, PLAYER_Y, 28  # y (init value for the loop)

        if_xright: bltz $t2, if_xleft
            addi $t4, PLAYER_X, 32
        if_xleft: bgtz $t2, check_x
            addi $t4, PLAYER_X, -4

        # check x = $t4, y in rev(range(PLAYER_Y, PLAYER_Y+8)) for collisions
        check_x: blt $t5, PLAYER_Y, apply_movement_x
            
            check_status $t7, $t4, $t5, NO_OVERLAP_MASK
            bne $t7, $zero, bad_x

            addi $t5, $t5, -4
        j check_x
        
        bad_x: move $t6, $zero  # Collision in x direction

        apply_movement_x: beq $t6, $zero, check_movement_y
            add PLAYER_X, PLAYER_X, $t2
    

    check_movement_y: beq $t3, $zero, done_movement
        # t4 = y-value to check
        # t6 = is valid (bool)
        li $t6, 1

        addi $t5, PLAYER_X, 28 # init x for the loop

        if_yup: bltz $t3, if_ydown
            addi $t4, PLAYER_Y, 32
        if_ydown: bgtz $t3, check_y
            addi $t4, PLAYER_Y, -4
        
        check_y: blt $t5, PLAYER_X, apply_movement_y
            check_status $t7, $t5, $t4, NO_OVERLAP_MASK
            bne $t7, $zero, bad_y

            addi $t5, $t5, -4
        j check_y

        bad_y: move $t6, $zero  # Collision in y direction
            sw $ra, -4($sp) # abuse - we don't need to update sp
            jal update_jump_status_from_collision
            lw $ra, -4($sp)

        apply_movement_y: beq $t6, $zero, done_movement
            add PLAYER_Y, PLAYER_Y, $t3        

    done_movement:
        jr $ra

    # (Nested in apply_movement)
    # Update the jump status due to collision as follows - 
    # If the player is jumping, cancel the jump.
    # If the player is not jumping, then allow them to jump again.
    # For convenience, only modify the registers unused in apply_movement (t8, t9).
    update_jump_status_from_collision:
        lw $t8, 8($t1)  # jump status
        update_is_jumping: bge CUR_FRAME, $t8, update_not_jumping
            sw CUR_FRAME, 8($t1)    # Jump ends this frame
            jr $ra

        update_not_jumping:
            li $t9, 2
            sw $t9, 12($t1)         # Two jumps remaining
            jr $ra