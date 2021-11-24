#####################################################################
#
# CSC258H1 Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Hasti Toossi, 1007091004
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 0
#
# Which approved additional features have been implemented?
# - ...
#
# Any additional information that the TA needs to know:
# - ...
#
#####################################################################
.data
	displayAddress: .word 0x10008000
	red: .word 0xff0000
	green: .word 0x00ff00
	blue: .word 0x0000ff
.text
	lw $a0, displayAddress
	addi $a0, $a0, 516
	li $a1, 16
	li $a2, 28
	lw $a3, blue
Rectangle: # $a0 has start point, $a1 length, $a2 height, $a3 color
	move $t0, $a0 # $t0 stores current display address
	add $t1, $a0, $a1 # $t1 stores the final point in the row
	sll $t2, $a2, 6
	add $t2, $t2, $a0 # $t2 stores the final point of the first column
	li $t3, 0 # $t3 stores the current offset
	Row:
		sw $a3, 0($t0)
		addi $t0, $t0, 4
		beq $t0, $t1, Column
		j Row
	Column:
		sub $t0, $t0, $a1
		addi $t0, $t0, 0x100
		addi $t1, $t1, 0x100
		beq $t0, $t2, Exit
		j Row
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall