.data 
 maze: .byte 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,0,0,0,1,1,0,1,0,1,0,1,1,1,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,0,0,0,0,0,1,0,1,1,0,1,0,1,1,1,0,1,0,1,1,0,0,0,0,0,1,0,1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,1
 welcome_str: .asciiz "Welcome to the MIPS maze solver!\nEnter a direction: R for right, L for left, F for forward, and B for backward:\n"
 mistake_str: .asciiz "Invalid move! Try again... \n"
 invalid_str: .asciiz "Invalid input, please re-enter\n"
 end_str: .asciiz "Congratulations! You reached the exit!"
 moves_count_str: .asciiz "\nTotal number of moves: "
 mistakes_count_str: .asciiz "\nNumber of mistakes: "
 user_input: .space 3 # 3 spaces, one for the char, one for enter, one for null
 
.text
.globl main

main:
 la $s0, maze # We will keep the maze location in s0
 addi $s1, $0, 11 # s1 stores the number of cols
 addi $s2, $0, 13 # s2 the number of rows
 addi $s3, $0, 1 # s3 the value of the current row
 addi $s4, $0, 0 # s4 the value of the current col
 add $s5, $0, 1 # s5 will store the "moves counter" (Half steps start at 1, full steps start at 0)
 add $s6, $0, $0 # s6 the number of moves
 add $s7, $0, $0 # s7 the number of mistakes
 
 addi $t1, $0, 0x52 # R in t1
 addi $t2, $0, 0x4c # L in t2
 addi $t3, $0, 0x46 # F in t3
 addi $t4, $0, 0x42 # B in t4 
 add $t5, $0, $0 # Ensure $t5 is empty to use as valid move storage
 
 # Print welcome string
 addi $v0, $0, 4
 la $a0, welcome_str
 syscall
 
 j input
 
input:
 # Receive input as string (so they can hit enter after)
 addi $v0, $0, 8
 la $a0, user_input
 addi $a1, $0, 3
 syscall
 lb $t6, user_input # store the user input at $t6
 
 addi $s6, $s6, 1 # add one to moves counter
 j check_limited_move
 
check_limited_move:
 # If the valid move storage is empty, they can move
 beqz $t5, move_robot
 # If the move if the only valid move, also continue movement
 beq $t6, $t5, move_robot
 # Else, print invalid move message
 j invalid_move
 
# Check where the robot needs to move 
move_robot:
 beq $t6, $t1, move_right
 beq $t6, $t2, move_left
 beq $t6, $t3, move_forward
 beq $t6, $t4, move_backward
 
 addi $v0, $0, 4
 la $a0, invalid_str
 syscall
 j input
 
# Moves one cell in the defined direction and stores the opposite in only valid move
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
 # Calculate crr cell value as offset to the beginning of the maze based
 mult $s3, $s1
 mflo $t8
 add $t8, $t8, $s4
 
 # Load that cell from the maze, if 1, we robor is standing on a wall
 lb $t9, maze($t8)
 jr $ra

check_move:
 # check if the current position is valid
 jal get_crr_position_val
 # if the current position is a wall, go to invalid move
 beq $t9, 1, invalid_move
 # if the current position is empty, check if this is the second move
 # if so, go to check if the user won
 beq $s5, 1, check_win
 # else, this must be the first move, so repeat the move to move two spaces
 # but update the move counter so the next step goes to check winner
 addi $s5, $s5, 1
 j move_robot

invalid_move:
 # Make sure the next step is a half step
 addi $s5, $0, 1

 # Tell user move is invalid, increase wall hit counter and go back to input
 # Note that the user will only be able to move in the opposite direction
 addi $v0, $0, 4
 la $a0, mistake_str
 syscall
 
 addi $s7, $s7, 1 # add one to mistakes counter
 j input
   
# Next step can be a full step again, so reset move counter as 0
# Also make sure valid move register is empty so the user can do anything again
# Then checks if they land outside the maze, if so, winner!
check_win:
 add $s5, $0, $0
 add $t5, $0, $0
 beq $s3, $s2, end
 beq $s4, $s1, end
 j input

# If they get to the end, print output strings
end:
 addi $v0, $0, 4
 la $a0, end_str
 syscall
 
 addi $v0, $0, 4
 la $a0, moves_count_str
 syscall

 addi $v0, $0, 1
 add $a0, $0, $s6
 syscall

 addi $v0, $0, 4
 la $a0, mistakes_count_str
 syscall

 addi $v0, $0, 1
 add $a0, $0, $s7
 syscall

 addi $v0, $0, 10
 syscall
