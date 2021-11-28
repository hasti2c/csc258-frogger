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
	black: .word 0x000000 # '0'
	red: .word 0xff0000 # 'r'
	green: .word 0x00ff00 # 'g'
	blue: .word 0x0000ff # 'b'
	scene: .byte 0, 0, 58, 6, # border top
	58, 0, 6, 58, # border right
	6, 58, 58, 6, # border bottom
	0, 6, 6, 58, # border left
	6, 51, 52, 7, # safe bottom
	6, 29, 52, 6, # safe mid
	8, 6, 8, 7, # safe top 1
	18, 6, 8, 7, # safe top 2
	28, 6, 8, 7, # safe top 3
	38, 6, 8, 7, # safe top 4
	48, 6, 8, 7 # safe top 5
	sceneColors: .byte 'b', 'b', 'b', 'b', 'g', 'g', 'g', 'g', 'g', 'g', 'g'
	
.text
main:
	lw $s0, displayAddress # $s0 always holds displayAddress (constant) 
	jal Clear
	la $a0, scene
	li $a1, 11
	la $a2, sceneColors
	jal RectArray
	j Exit
	
Clear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $a0, 0
	li $a1, 64
	li $a2, 64
	lw $a3, black
	jal Rectangle
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
RectArray: # $a0 is start of array (mem address), $a1 is length of array (num of rects), $a2 is start of color array (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $s1, $a0 # $s1 is current rect of array (mem address)
	sll $s2, $a1, 2
	add $s2, $s2, $s1 # $s2 is end of array (mem address)
	move $s3, $a2 # $s3 is start of color array (mem address)
	NextRect:
		lbu $a0, 0($s3)
		jal GetColor
		move $a1, $v0
		move $a0, $s1
		jal RectFromMem
		add $s1, $s1, 4
		add $s3, $s3, 1
	bne $s1, $s2, NextRect
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
RectFromMem: # $a0 has the memory address for the rectangle, $a1 has color of current address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a3, $a1
	move $t0, $a0 # $t0 stores the original memory address
	lb $a0, 0($t0)
	lb $a1, 1($t0)
	jal GetPos
	move $a0, $v0
	lb $a1, 2($t0)
	lb $a2, 3($t0)
	jal Rectangle
	lw $ra, 0($sp)
	addi $sp, $sp, 4
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
	
GetPos: # $a0 has x coord (unit), $a1 has y coord (unit), $v0 returns position (unit)
	sll $v0, $a1, 6
	add $v0, $v0, $a0
	jr $ra
	
GetColor: # $a0 has color name (char), $v0 returns color (rgb)
	lw $v0, black
	bne $a0, 'r', NotRed
	lw $v0, red
	NotRed:
	bne $a0, 'g', NotGreen
	lw $v0, green
	NotGreen:
	bne $a0, 'b', NotBlue
	lw $v0, blue
	NotBlue:
	jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
