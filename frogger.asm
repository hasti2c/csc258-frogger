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
	scene: .byte 14, 54, 6, 3, 29, 12, 14, 7
	sceneColors: .byte 'r', 'g' 
	
.text
	lw $s0, displayAddress # $s0 always holds displayAddress (constant) 
	la $s1, scene # $s1 holds the first memory address of current scene rect
	add $s2, $s1, 8 # $s2 is the first memory address after scene array
	la $s3, sceneColors # $s3 holds the memory address of the color of current rect
	
Scene:
	lbu $a0, 0($s3)
	jal GetColor
	move $a1, $v0
	move $a0, $s1
	jal RectFromMem
	add $s1, $s1, 4
	add $s3, $s3, 1
	beq $s1, $s2, Exit
	j Scene
	
RectFromMem: # $a0 has the memory address for the rectangle, $a1 has color of current address
	move $a3, $a1
	move $t0, $a0 # $t0 stores the original memory address
	lb $a0, 0($t0)
	lb $a1, 1($t0)
	move $s7, $ra # $s7 preserves the original $ra - TODO use stack
	jal GetPos
	move $a0, $v0
	lb $a1, 2($t0)
	lb $a2, 3($t0)
	move $ra, $s7 # return from RectFromMem
	j Rectangle
	
GetPos: # $a0 has x coord (unit), $a1 has y coord (unit), $v0 returns position (unit)
	sll $v0, $a1, 6
	add $v0, $v0, $a0
	jr $ra
	
GetColor: # $a0 has color name (char), $v0 returns color (rgb)
	beq $a0, 'r', ReturnRed
	beq $a0, 'g', ReturnGreen
	beq $a0, 'b', ReturnBlue
	li $v0, 0x000000
	jr $ra
	ReturnRed: 
		lw $v0, red
		jr $ra
	ReturnBlue: 
		lw $v0, blue
		jr $ra
	ReturnGreen:
		lw $v0, green
		jr $ra
	
Rectangle: # $a0 has start position (unit), $a1 length (unit), $a2 height (unit), $a3 color
	move $t0, $a0 # $t0 stores current position (unit)
	add $t1, $a0, $a1 # $t1 stores the final position in the current row (unit)
	sll $t2, $a2, 6
	add $t2, $t2, $a0 # $t2 stores the final position of the first column (unit)
	sll $t3, $t0, 2
	add $t3, $t3, $s0 # $t3 stores the current memory address
	Row:
		sw $a3, 0($t3)
		addi $t0, $t0, 1
		addi $t3, $t3, 4
		beq $t0, $t1, Column
		j Row
	Column:
		sub $t0, $t0, $a1
		addi $t0, $t0, 0x40
		addi $t1, $t1, 0x40
		sll $t3, $t0, 2
		add $t3, $t3, $s0
		beq $t0, $t2, RectangleReturn
		j Row
	RectangleReturn:
		jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
