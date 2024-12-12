.data
 # Note that the maze is only open on the exit, the starting point is defined in code but "closed" to avoid someone winning by going back through the entrance
 maze: .byte 1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,0,0,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,0,0,0,1,1,0,1,0,1,0,1,1,1,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,0,0,0,0,0,1,0,1,1,0,1,0,1,1,1,0,1,0,1,1,0,0,0,0,0,1,0,1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,1
 welcome_str: .asciiz "Welcome to the MIPS maze solver!\nEnter a direction: R for right, L for left, F for forward, and B for backward:\n"
 welcome_note: .asciiz "Note: to input a command, write a letter and then press enter to confirm.\n" 
 mistake_str: .asciiz "Invalid move! Try again... \n"
 invalid_str: .asciiz "Invalid input, please re-enter\n"
 end_str: .asciiz "Congratulations! You reached the exit!"
 moves_count_str: .asciiz "\nTotal number of moves: "
 mistakes_count_str: .asciiz "\nNumber of mistakes: "
 user_input: .space 3 # 3 spaces, one for the char, one for enter, one for null
 
.text
.globl main

main:
 la $s0, maze          # Maze Address
 addi $s1, $0, 11      # Number of columns
 addi $s2, $0, 13      # Number of rows
 addi $s3, $0, 1       # Current row: Initialised to 1
 addi $s4, $0, 0       # Current column: Initialised to 0 (Outside the maze)
 add $s5, $0, 1        # Move increment: Measured in half-step (01) and full steps (10) 
 add $s6, $0, $0       # Number of moves
 add $s7, $0, $0       # Number of mistakes
 addi $t1, $0, 0x52    # R in $t1
 addi $t2, $0, 0x4c    # L in $t2
 addi $t3, $0, 0x46    # F in $t3
 addi $t4, $0, 0x42    # B in $t4
 addi $t5, $0, 0x46    # Valid moves: Initialised to F only
 
 addi $v0, $0, 4
 la $a0, welcome_str
 syscall  # Print welcome string

 addi $v0, $0, 4
 la $a0, welcome_note
 syscall  # Print welcome note
 
 j input
 
 # NOTE TO EXAMINER: We are assuming the user types the input and then presses Enter for each move
 
input:
 addi $v0, $0, 8 # Load Syscall for User Input
 la $a0, user_input
 addi $a1, $0, 3
 syscall
 lb $t6, user_input # User Input - Updated every iteration
 addi $s6, $s6, 1 # Add Half Step
 j check_limited_move
 
check_limited_move:
 beqz $t5, move_robot # If the valid move storage is empty, they can move
 beq $t6, $t5, move_robot  # If the move if the only valid move, also continue movement
 j invalid_move
 
move_robot:
 beq $t6, $t1, move_right
 beq $t6, $t2, move_left
 beq $t6, $t3, move_forward
 beq $t6, $t4, move_backward
 
 addi $v0, $0, 4
 la $a0, invalid_str
 syscall
 j input
 

move_left: 
 addi $s3, $s3, 1 
 addi $s4, $s4, 0
 addi $t5, $0, 0x52
 j check_move
move_right:
 addi $s3, $s3, -1
 addi $s4, $s4, 0
 addi $t5, $0, 0x4c
 j check_move
move_forward:
 addi $s3, $s3, 0
 addi $s4, $s4, 1
 addi $t5, $0, 0x42
 j check_move
move_backward:
 addi $s3, $s3, 0
 addi $s4, $s4, -1
 addi $t5, $0, 0x46
 j check_move
 
get_crr_position_val:
 mult $s3, $s1 # Current Row x Total Columns
 mflo $t8 # Store Product
 add $t8, $t8, $s4 # Linear Index
 lb $t9, maze($t8) # Load value at index
 jr $ra

check_move:
 jal get_crr_position_val
 beq $t9, 1, invalid_move # Wall
 beq $s5, 1, check_win #Check on half step
 addi $s5, $s5, 1 # Handles unique case of initial half step
 j move_robot

invalid_move:
 addi $s5, $0, 1 #Set increment to half step
 addi $v0, $0, 4
 la $a0, mistake_str
 syscall #Print "Invalid Move! Try again..."
 addi $s7, $s7, 1 # add one to mistakes counter
 j input

check_win:
 add $t5, $0, $0 #Reset valid moves before deciding 
 
 beq $s3, $s2, end #13th Row
 beq $s3, $0, end 
 beq $s4, $s1, end 
 beq $s4, $0, end 
 
 beqz $s4, go_to_input #Skip incrementation if first move
 add $s5, $0, $0 #Move increment set to full step

go_to_input:
 j input

end:
 addi $v0, $0, 4
 la $a0, end_str
 syscall
 
 addi $v0, $0, 4
 la $a0, mistakes_count_str
 syscall

 addi $v0, $0, 1
 add $a0, $0, $s7
 syscall

 addi $v0, $0, 4
 la $a0, moves_count_str
 syscall

 addi $v0, $0, 1
 add $a0, $0, $s6
 syscall

 addi $v0, $0, 10
 syscall
