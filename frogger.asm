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
# - Milestone 1
#
# Which approved additional features have been implemented?
# - ...
#
# Any additional information that the TA needs to know:
# - ...
#
#####################################################################
.data
	##### Display Data #####
	displayAddress: .word 0x10008000
	black: .word 0x000000 # '0'
	white: .word 0xffffff # 'w'
	red: .word 0xff0000 # 'r'
	green: .word 0x00ff00 # 'g'
	blue: .word 0x0000ff # 'b'
	darkGreen: .word 0x008000 # 'f' - stands for frog
	scene: .byte 0, 0, 59, 5, 'b', # border top
		59, 0, 5, 59, 'b', # border right
		5, 59, 59, 5, 'b', # border bottom
		0, 5, 5, 59, 'b', # border left
		5, 53, 54, 6, 'g', # safe bottom
		5, 29, 54, 6, 'g', # safe mid
		5, 5, 7, 6, 'g', # safe top 1
		16, 5, 8, 6, 'g', # safe top 2
		28, 5, 8, 6, 'g', # safe top 3
		40, 5, 8, 6, 'g', # safe top 4
		52, 5, 7, 6, 'g', # safe top 5
		5, 11, 54, 18, '0', # water
		5, 35, 54, 18, '0' # water
	frog: .byte 1, 1, 2, 2, 'f', # body
		0, 0, 1, 1, 'f', # top left
		3, 0, 1, 1, 'f', # top right
		0, 3, 1, 1, 'f', # bottom left
		3, 3, 1, 1, 'f' # bottom right
	vehicles: .byte 6, 1, 6, 4, 'r', # row 1 - car 1
		24, 1, 6, 4, 'r', # row 1 - car 2
		42, 1, 6, 4, 'r', # row 1 - car 3
		6, 7, 12, 4, 'r', # row 2 - car 1
		36, 7, 12, 4, 'r', # row 2 - car 2
		6, 13, 6, 4, 'r', # row 3 - car 1
		24, 13, 6, 4, 'r', # row 3 - car 2
		42, 13, 6, 4 'r' # row 3 - car 3
	logs: .byte 6, 1, 12, 4, 'b', # row 1 - log 1
		36, 1, 12, 4, 'b', # row 1 - log 2
		6, 7, 6, 4, 'b', # row 2 - log 1
		24, 7, 6, 4, 'b', # row 2 - log 2
		42, 7, 6, 4, 'b', # row 2 - log 3
		6, 13, 12, 4, 'b', # row 3 - log 1
		36, 13, 12, 4, 'b' # row 3 - log 2
	scenePosition: .byte 0, 0
	frogPosition: .byte 30, 54
	roadPosition: .byte 5, 35
	waterPosition: .byte 5, 11
	completedFrogs: .byte 6, 6, 1, # safe region 1
		18, 6, 1, # safe region 2
		30, 6, 1, # safe region 3
		42, 6, 1, # safe region 4
		54, 6, 1 # safe region 5
	
	##### Input Data #####
	inputAddress: .word 0xffff0000
		
.text
main:
	lw $s0, displayAddress # $s0 always holds displayAddress (constant) 
	lw $s1, inputAddress
	jal Clear
	MainLoop:
		jal CheckInput
		jal Scene
		jal FrogRoadWater
		jal CompletedFrogs
		li $v0, 32
		li $a0, 16
		syscall
		j MainLoop
	j Exit
		
##### Display Functions #####
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
	li $a1, 13
	la $a2, scenePosition
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
FrogRoadWater:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, vehicles
	li $a1, 8
	la $a2, roadPosition
	jal RectArray
	la $a0, logs
	li $a1, 7
	la $a2, waterPosition
	jal RectArray
	la $a0, frog
	li $a1, 5
	la $a2, frogPosition
	jal RectArray
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
CompletedFrogs:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $s5, completedFrogs # $s5 is start of completed frog array (mem address)
	li $s6, 0 # $s6 is the number of frogs checked
	DrawFrog:
		la $a0, frog # TODO: use $s register
		li $a1, 5 # TODO: use $s register
		lb $t2, 2($s5)
		beq $t2, 0, DrawFrogIncrement
		move $a2, $s5
		# jal RectArray
		DrawFrogIncrement:
			add $s5, $s5, 3
			addi $s6, $s6, 1
			bne $s6, 5, DrawFrog
	addi $sp, $sp, 4
	jr $ra
		
RectArray: # $a0 is start of array (mem address), $a1 is length of array (num of rects), $a2 is origin position (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $s2, $a0 # $s2 is current rect of array (mem address)
	li $s3, 5
	mult $a1, $s3
	mflo $s3
	add $s3, $a0, $s3 # $s3 is end of array (mem address)
	move $s4, $a2 # $s4 preserves origin position (mem address)
	NextRect:
		move $a0, $s2
		move $a1, $s4
		jal RectFromMem
		add $s2, $s2, 5
	bne $s2, $s3, NextRect
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
RectFromMem: # $a0 is rectangle (mem address), $a1 is origin position (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $a0 # $t0 preserves the rectangle (mem address)
	move $t1, $a1 # $t1 preserves origin position (mem address)
	lbu $a0, 4($t0)
	jal GetColor
	move $a3, $v0
	lb $a0, 0($t0)
	lb $a1, 1($t0)
	jal GetPos
	move $t2, $v0
	lb $a0, 0($t1)
	lb $a1, 1($t1)
	jal GetPos
	add $a0, $v0, $t2
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
	lw $v0, white
	Black:
		bne $a0, '0', Red
		lw $v0, black
	Red:
		bne $a0, 'r', Green
		lw $v0, red
	Green:
		bne $a0, 'g', Blue
		lw $v0, green
	Blue:
		bne $a0, 'b', DarkGreen
		lw $v0, blue
	DarkGreen:
		bne $a0, 'f', ReturnColor
		lw $v0, darkGreen
	ReturnColor:
		jr $ra
		
#### Input Functions #####
CheckInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)		
	lw $t0, 0($s1)
	bne $t0, 1, ReturnCheckInput
	lw $a0, 4($s1)
	jal Move
	ReturnCheckInput:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
Move: # $a0 is keyboard input, $v0 is whether or not input was wasd (0/1)
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	move $t0, $a0 # $t0 preserves the keyboard input
	lb $a0, frogPosition # $a0 is the x coord of frog position
	lb $a1, frogPosition + 1 # $a1 is the y coord of frog position
	li $v0, 1
	ble $a1, 6, ReturnMove
	beq $t0, 'w', InputW
	beq $t0, 'W', InputW
	beq $t0, 'a', InputA
	beq $t0, 'A', InputA
	beq $t0, 's', InputS
	beq $t0, 'S', InputS
	beq $t0, 'd', InputD
	beq $t0, 'D', InputD
	li $v0, 0
	j ReturnMove
	InputW:
		add $a1, $a1, -6
		j ReturnMove
	InputA:
		ble $a0, 6, ReturnMove
		add $a0, $a0, -6
		j ReturnMove
	InputS:
		bge $a1, 54, ReturnMove
		add $a1, $a1, 6
		j ReturnMove
	InputD:
		bge $a0, 54, ReturnMove
		add $a0, $a0, 6
		j ReturnMove
	ReturnMove:
		jal CheckCompletion
		sb $v0, frogPosition
		sb $v1, frogPosition + 1
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
CheckCompletion: # $a0, $a1 are current x, y coord of frog position (unit), $v0, $v1 are result x, y coord of frog position (unit)
	bgt $a1, 6, NotCompleted
	la $t0, completedFrogs # $t0 is current element of completed frogs array (mem address)
	li $t1, 0 # $t1 is the number of frogs checked
	CheckFrog:
		lb $t2, 0($t0)
		bne $t2, $a0, CheckFrogIncrement
		li $t2, 1
		sb $t2, 2($t0)
		CheckFrogIncrement:
			add $t0, $t0, 3
			addi $t1, $t1, 1
			bne $t1, 5, CheckFrog
		li $v0, 30
		li $v1, 54
		jr $ra
	NotCompleted:
		move $v0, $a0
		move $v1, $a1
		jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
