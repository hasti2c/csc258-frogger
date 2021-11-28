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
	darkGreen: .word 0x008000 # 'f' - stands for frog
	scene: .byte 0, 0, 58, 6, 'b', # border top
		58, 0, 6, 58, 'b', # border right
		6, 58, 58, 6, 'b', # border bottom
		0, 6, 6, 58, 'b', # border left
		6, 51, 52, 7, 'g', # safe bottom
		6, 29, 52, 6, 'g', # safe mid
		8, 6, 8, 7, 'g', # safe top 1
		18, 6, 8, 7, 'g', # safe top 2
		28, 6, 8, 7, 'g', # safe top 3
		38, 6, 8, 7, 'g', # safe top 4
		48, 6, 8, 7, 'g' # safe top 5
	frog: .byte 1, 1, 2, 2, 'f', # body
		0, 0, 1, 1, 'f', # top left
		3, 0, 1, 1, 'f', # top right
		0, 3, 1, 1, 'f', # bottom left
		3, 3, 1, 1, 'f' # bottom right
	vehicles: .byte 6, 1, 6, 4, 'r', # row 1 - car 1
		23, 1, 6, 4, 'r', # row 1 - car 2
		41, 1, 6, 4, 'r', # row 1 - car 3
		7, 6, 12, 4, 'r', # row 2 - car 1
		33, 6, 12, 4, 'r', # row 2 - car 2
		6, 11, 6, 4, 'r', # row 3 - car 1
		23, 11, 6, 4, 'r', # row 3 - car 2
		41, 11, 6, 4 'r' # row 3 - car 3
	logs: .byte 6, 1, 14, 4, 'b',
		32, 1, 14, 4, 'b',
		3, 6, 11, 4, 'b',
		20, 6, 12, 4, 'b',
		38, 6, 11, 4, 'b',
		6, 11, 14, 4, 'b',
		32, 11, 14, 4, 'b'
	frogPosition: .byte 30, 52
	roadPosition: .byte 6, 35
	waterPosition: .byte 6, 13
	
.text
main:
	lw $s0, displayAddress # $s0 always holds displayAddress (constant) 
	jal Clear
	jal Scene
	jal Frog
	jal Vehicles
	jal Water
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
	
Scene:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, scene
	li $a1, 11
	li $a2, 0
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
Frog:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lb $a0, frogPosition
	lb $a1, frogPosition + 1
	jal GetPos
	move $a2, $v0
	la $a0, frog
	li $a1, 5
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
Vehicles:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lb $a0, roadPosition
	lb $a1, roadPosition + 1
	jal GetPos
	move $a2, $v0
	la $a0, vehicles
	li $a1, 8
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

Water:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lb $a0, waterPosition
	lb $a1, waterPosition + 1
	jal GetPos
	move $a2, $v0
	la $a0, logs
	li $a1, 8
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
RectArray: # $a0 is start of array (mem address), $a1 is length of array (num of rects), $a2 is origin position (unit)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $s3, $a2 # $s3 preserves origin position (unit)
	move $s1, $a0 # $s1 is current rect of array (mem address)
	li $s2, 5
	mult $a1, $s2
	mflo $s2
	add $s2, $a0, $s2 # $s2 is end of array (mem address)
	NextRect:
		move $a0, $s1
		move $a1, $s3
		jal RectFromMem
		add $s1, $s1, 5
	bne $s1, $s2, NextRect
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
RectFromMem: # $a0 has the memory address for the rectangle, $a1 is origin position (unit)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $a0 # $t0 preserves the memory address
	move $t1, $a1 # $t1 preserves origin position (unit)
	lbu $a0, 4($t0)
	jal GetColor
	move $a3, $v0
	lb $a0, 0($t0)
	lb $a1, 1($t0)
	jal GetPos
	add $a0, $v0, $t1
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
	
GetPos: # $a0 has x coord (unit), $a1 has y coord (unit), $v0 returns position (unit) - preserves $t registers
	sll $v0, $a1, 6
	add $v0, $v0, $a0
	jr $ra
	
GetColor: # $a0 has color name (char), $v0 returns color (rgb) - preserves $t registers
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
	bne $a0, 'f', NotDarkGreen
	lw $v0, darkGreen
	NotDarkGreen:
	jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
