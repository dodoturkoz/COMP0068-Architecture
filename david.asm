.data 
 maze: .byte 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,0,0,0,1,1,0,1,0,1,0,1,1,1,0,1,1,0,0,0,0,0,1,0,0,0,1,1,1,1,1,1,0,1,1,1,0,1,1,0,1,0,0,0,0,0,1,0,1,1,0,1,0,1,1,1,0,1,0,1,1,0,0,0,0,0,1,0,1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,1
 welcome_str: .asciiz "Welcome to the MIPS maze solver!"
 instruction_str: .asciiz "\nEnter a direction: R for right, L for left, F for forward, and B for backward:\n"
 mistake_str: .asciiz "\nInvalid move, there is a wall in that direction! Try again... \n"
 invalid_str: .asciiz "\nInvalid input, please re-enter\n"
 end_str: .asciiz "\nCongratulations! You reached the exit!"
 moves_count_str: .asciiz "\nTotal number of moves: "
 mistakes_count_str: .asciiz "\nNumber of mistakes: "

.text
.globl main

main:
 la $s0, maze # We will keep the maze location in s0
 add $s1, $0, 11 # s1 stores the number of cols
 add $s2, $0, 13 # s2 the number of rows
 add $s3, $0, 1 # s3 the value of the current row
 add $s4, $0, -1 # s4 the value of the current col
 add $s6, $0, $0 # s6 the number of moves
 add $s7, $0, $0 # s7 the number of mistakes
 
 addi $t1, $0, 0x52 # R in t1
 addi $t2, $0, 0x4c # L in t2
 addi $t3, $0, 0x46 # F in t3
 addi $t4, $0, 0x42 # B in t4 
 
 # Print welcome string
 addi $v0, $0, 4
 la $a0, welcome_str
 syscall
 
 addi $v0, $0, 4
 la $a0, instruction_str
 syscall
 
 j input
 
input:
 # Receive input
 addi $v0, $0, 12
 syscall
 
 addi $s6, $s6, 1 # add one to moves counter

 beq $v0, $t1, move_right
 beq $v0, $t2, move_left
 beq $v0, $t3, move_forward
 beq $v0, $t4, move_backward
 
 addi $v0, $0, 4
 la $a0, invalid_str
 syscall
 j input
 
# In the set of moves, $a1 and $a2 represent the target cell
# while $t6 and $t7 represent the potential wall cell they would need to go through
move_left:
 addi $a1, $s3, 2
 addi $a2, $s4, 0
 addi $t6, $s3, 1
 addi $t7, $s4, 0
 j check_move
move_right:
 addi $a1, $s3, -2
 addi $a2, $s4, 0
 addi $t6, $s3, -1
 addi $t7, $s4, 0
 j check_move
move_forward:
 addi $a1, $s3, 0
 addi $a2, $s4, 2
 addi $t6, $s3, 0
 addi $t7, $s4, 1
 j check_move
move_backward:
 addi $a1, $s3, 0
 addi $a2, $s4, -2
 addi $t6, $s3, 0
 addi $t7, $s4, -1
 j check_move

check_move:
 # Get the offset based temp column and row
 mult $t6, $s1
 mflo $t8
 add $t8, $t8, $t7
 
 # Load that cell from the maze, if 0, is a valid move and go to check winner
 lb $t9, maze($t8) 
 beqz $t9, check_win
 
 # Else, tell them is an invalid move, increase wall hit counter and go back to input 
 addi $v0, $0, 4
 la $a0, mistake_str
 syscall
 
 addi $s7, $s7, 1 # add one to moves counter
 j input
   
# Stores the target cell as the current cell
# Then checks if they land outside the maze, if so, winner!
check_win:
 add $s3, $0, $a1
 add $s4, $0, $a2
 beq $s3, $s2, end
 beq $s4, $s1, end
 j input

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