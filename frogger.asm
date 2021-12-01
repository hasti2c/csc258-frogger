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
# - Milestone 2
#
# Which approved additional features have been implemented?
# - ...
#
# Any additional information that the TA needs to know:
# - ...
#
#####################################################################
.data
	##### Milestone 1 Data #####
	displayAddress: .word 0x10008000
	black: .word 0x000000 # '0' - used for clear
	white: .word 0xffffff # '1' - used for undefined values
	red: .word 0xff0000 # 'r' - used for vehicles
	green: .word 0x00ff00 # 'g' - used for safe areas
	blue: .word 0x0000ff # 'b' - used for border
	lightBlue: .word 0x00bfff # 'l' - stands for light - used for water
	darkGreen: .word 0x008000 # 'f' - stands for frog - used for frog!
	brown: .word 0xd2691e # 'w' - stands for wood - used for logs
	gray: .word 0x696969 # 's' - stands for street - used for road!
	scene: .byte 0, 0, 59, 5, 'b', # border top
		59, 0, 5, 59, 'b', # border right
		5, 59, 59, 5, 'b', # border bottom
		0, 5, 5, 59, 'b', # border left
		5, 53, 54, 6, 'g', # safe bottom
		5, 29, 54, 6, 'g', # safe mid
		5, 5, 7, 6, 'g', # safe top 1
		12, 5, 4, 6, 'l', # unsafe top 1
		16, 5, 8, 6, 'g', # safe top 2
		24, 5, 4, 6, 'l', # unsafe top 2
		28, 5, 8, 6, 'g', # safe top 3
		36, 5, 4, 6, 'l', # unsafe top 3
		40, 5, 8, 6, 'g', # safe top 4
		48, 5, 4, 6, 'l', # unsafe top 5
		52, 5, 7, 6, 'g', # safe top 5
		5, 11, 54, 18, 'l', # water
		5, 35, 54, 18, 's' # road
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
	logs: .byte 6, 1, 12, 4, 'w', # row 1 - log 1
		36, 1, 12, 4, 'w', # row 1 - log 2
		6, 7, 6, 4, 'w', # row 2 - log 1
		24, 7, 6, 4, 'w', # row 2 - log 2
		42, 7, 6, 4, 'w', # row 2 - log 3
		6, 13, 12, 4, 'w', # row 3 - log 1
		36, 13, 12, 4, 'w' # row 3 - log 2
	
	##### Milestone 2 Data #####
	inputAddress: .word 0xffff0000
	scenePosition: .byte 0, 0
	frogPosition: .byte 30, 54
	roadPosition: .byte 5, 35
	waterPosition: .byte 5, 11
	shiftDirection: .byte 1, 1, 1, # vehicles - row 1
		-1, -1, # vehicles - row 2
		1, 1, 1, # vehicles - row 3
		1, 1, # logs - row 1
		-1, -1, -1, # logs - row 2
		1, 1 # logs - row 3
	
	##### Milestone 3 Data #####
	completedFrogs: .byte 6, 6, 0, # safe region 1
		18, 6, 0, # safe region 2
		30, 6, 0, # safe region 3
		42, 6, 0, # safe region 4
		54, 6, 0 # safe region 5
	forbiddenColours: .byte 'b', 'f' # border & frog
	loseColours: .byte 'r', 'l' # cars & water
		
.text
main:
	li $s0, 0 # $s0 is the number of times MainLoop has been run
	jal Clear
	MainLoop:
		jal CheckStandConditions
		jal CheckInput
		jal Scene
		jal FrogRoadWater
		jal CompletedFrogs
		li $v0, 32
		li $a0, 16
		syscall
		addi $s0, $s0, 1
		bne $s0, 30, MainLoop
		li $s0, 0
		jal Shift
		j MainLoop
	j Exit
		
##### Milestone 1 Functions #####
Clear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 0
	li $a1, 0
	li $a2, 64
	li $a3, 64
	
	lw $t0, black
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	jal Rectangle
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
Scene:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, scene
	li $a1, 17
	la $a2, scenePosition
	li $a3, 0
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
	li $a3, 1
	jal RectArray
	la $a0, logs
	li $a1, 7
	la $a2, waterPosition
	li $a3, 1
	jal RectArray
	la $a0, frog
	li $a1, 5
	la $a2, frogPosition
	li $a3, 0
	jal RectArray
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
RectArray: # $a0 is start of array (mem address), $a1 is length of array (num of rects), $a2 is origin position (mem address), $a3 is whether or not to use wrapping behaviour (0/1)
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	
	move $s0, $a0 # $s0 is current rect of array (mem address)
	li $s1, 5
	mult $a1, $s1
	mflo $s1
	add $s1, $a0, $s1 # $s1 is end of array (mem address)
	move $s2, $a2 # $s2 preserves origin position (mem address)
	move $s3, $a3 # $s3 preserves whether or not to use wrapping behaviour (0/1)
	NextRect:
		move $a0, $s0
		move $a1, $s2
		move $a2, $s3
		jal RectFromMem
		add $s0, $s0, 5
	bne $s0, $s1, NextRect
	
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
RectFromMem: # $a0 is rectangle (mem address), $a1 is origin position (mem address), $a2 is whether or not to use wrapping behaviour (0/1)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t0, $a0 # $t0 preserves the rectangle (mem address)
	move $t1, $a1 # $t1 preserves origin position (mem address)
	move $t2, $a2 # $t2 preserves whether or not to use wrapping behaviour (0/1)
	
	
	lbu $a0, 4($t0)
	jal GetColourCode
	addi $sp, $sp, -4
	sw $v0, 0($sp)
	
	lb $a0, 0($t0)
	lb $a1, 1($t0)
	lb $t3, 0($t1)
	add $a0, $a0, $t3
	lb $t3, 1($t1)
	add $a1, $a1, $t3
	lb $a2, 2($t0)
	lb $a3, 3($t0)
	bnez $t2, RectWrappedFromMem
	jal Rectangle
	j ReturnRectFromMem
	RectWrappedFromMem:
		jal RectangleWrapped
	ReturnRectFromMem:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
Rectangle: # $a0 has x-coord of start position (unit), $a1 has y-coord of start position (unit), $a2 length (unit), $a3 height (unit), stack has colour code (rgb) - doesn't change $a registers
	lw $t5, 0($sp) # $t5 stores colour
	sw $ra, 0($sp)
	
	jal GetPos
	move $t0, $v0 # $t0 stores current position (unit)
	add $t1, $t0, $a2 # $t1 stores the final position in the current row (unit)
	sll $t2, $a3, 6
	add $t2, $t2, $t0 # $t2 stores the final position of the first column (unit)
	lw $t4, displayAddress # $t4 stores displayAddress (mem address)
	sll $t3, $t0, 2
	add $t3, $t3, $t4 # $t3 stores the current memory address
	Row:
		sw $t5, 0($t3)
		addi $t0, $t0, 1
		addi $t3, $t3, 4
		beq $t0, $t1, Column
		j Row
	Column:
		sub $t0, $t0, $a2
		addi $t0, $t0, 0x40
		addi $t1, $t1, 0x40
		sll $t3, $t0, 2
		add $t3, $t3, $t4
		beq $t0, $t2, RectangleReturn
		j Row
		
	RectangleReturn:
		lw $ra, 0($sp)	
		addi $sp, $sp, 4
		jr $ra
	
GetPos: # $a0 has x coord (unit), $a1 has y coord (unit), $v0 returns position (unit) - preserves $a and $t registers
	sll $v0, $a1, 6
	add $v0, $v0, $a0
	jr $ra
	
GetColourCode: # $a0 has colour name (char), $v0 returns colour code (rgb) - preserves $a and $t registers
	lw $v0, white
	BlackCode:
		bne $a0, '0', RedCode
		lw $v0, black
	RedCode:
		bne $a0, 'r', GreenCode
		lw $v0, red
	GreenCode:
		bne $a0, 'g', BlueCode
		lw $v0, green
	BlueCode:
		bne $a0, 'b', LightBlueCode
		lw $v0, blue
	LightBlueCode:
		bne $a0, 'l', DarkGreenCode
		lw $v0, lightBlue
	DarkGreenCode:
		bne $a0, 'f', BrownCode
		lw $v0, darkGreen
	BrownCode:
		bne $a0, 'w', GrayCode
		lw $v0, brown
	GrayCode:
		bne $a0, 's', ReturnColourCode
		lw $v0, gray
	ReturnColourCode:
		jr $ra
		
GetColourName: # $a0 has colour code (rgb), $v0 returns colour name (char)
	li $v0, '1'
	BlackName:
		lw $t0, black
		bne $a0, $t0, RedName
		li $v0, '0'
	RedName:
		lw $t0, red
		bne $a0, $t0, GreenName
		li $v0, 'r'
	GreenName:
		lw $t0, green
		bne $a0, $t0, BlueName
		li $v0, 'g'
	BlueName:
		lw $t0, blue
		bne $a0, $t0, LightBlueName
		li $v0, 'b'
	LightBlueName:
		lw $t0, lightBlue
		bne $a0, $t0, DarkGreenName
		li $v0, 'l'
	DarkGreenName:
		lw $t0, darkGreen
		bne $a0, $t0, BrownName
		li $v0, 'f'
	BrownName:
		lw $t0, brown
		bne $a0, $t0, GrayName
		li $v0, 'w'
	GrayName:
		lw $t0, gray
		bne $a0, $t0, ReturnColourName
		li $v0, 's'
	ReturnColourName:
		jr $ra
		
#### Milestone 2 Functions #####
CheckInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, inputAddress # $t0 is inputAddress (mem address)
	lw $t1, 0($t0) # $t1 is whether or not there has been keyboard input (0/1)
	bne $t1, 1, ReturnCheckInput
	lw $a0, 4($t0)
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
		add $a0, $a0, -6
		j ReturnMove
	InputS:
		add $a1, $a1, 6
		j ReturnMove
	InputD:
		add $a0, $a0, 6
		j ReturnMove
	ReturnMove:
		jal CheckMoveConditions
		sb $v0, frogPosition
		sb $v1, frogPosition + 1
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
Shift:
	la $t0, vehicles # $t0 is the address of current vehicle/log (mem address)
	li $t1, 0 # $t1 is the number of vehicles/logs we've shifted
	la $t2, shiftDirection # $t2 is current shiftDirection (mem address)
	ShiftElement:
		lb $t4, 0($t2)
		li $t5, 6
		mult $t4, $t5
		mflo $t4 # $t4 is the amount to shift (unit)
		lb $t3, 0($t0)
		add $t3, $t3, $t4 # $t3 is the new x value of the element (unit)
		bge $t3, 54, RightShiftOverflow
		blt $t3, 0, LeftShiftOverflow
		j ShiftDone
		RightShiftOverflow:
		add $t3, $t3, -54
		j ShiftDone
		LeftShiftOverflow:
		add $t3, $t3, 54
		ShiftDone:
		sb $t3, 0($t0)
		add $t0, $t0, 5
		add $t1, $t1, 1
		add $t2, $t2, 1
		bne $t1, 15, ShiftElement
	jr $ra
	
RectangleWrapped: # $a0 has x-coord of start position (unit), $a1 has y-coord of start position (unit), $a2 length (unit), $a3 height (unit), stack has colour	
	lw $t0, 0($sp)
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	bge $a0, 5, CheckRightWrap
	addi $a0, $a0, 59
	CheckRightWrap:
		move $s0, $t0 # $s0 is colour
		add $s1, $a0, $a2 # $s1 is final x-coord of rectangle (unit)
		bgt $s1, 59, RightWrap
		addi $sp, $sp, -4
		sw $s0, 0($sp)
		jal Rectangle
		j ReturnRectangleWrapped
	RightWrap:
		li $t0, 59
		sub $a2, $t0, $a0
		addi $sp, $sp, -4
		sw $s0, 0($sp)
		jal Rectangle
		li $a0, 5
		sub $a2, $s1, 59
		addi $sp, $sp, -4
		sw $s0, 0($sp)
		jal Rectangle
		j ReturnRectangleWrapped	
	ReturnRectangleWrapped:
		lw $s1, 0($sp)
		lw $s0, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	
##### Milestone 3 Functions #####
CompletedFrogs:
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	
	la $s0, completedFrogs # $s0 is start of completed frog array (mem address)
	li $s1, 0 # $s1 is the number of frogs checked
	la $s2, frog # $s2 is the frog array (mem address)
	li $s3, 5 # $s3 is the length of the frog array
	DrawFrog:
		move $a0, $s2
		move $a1, $s3
		lb $t2, 2($s0)
		beq $t2, 0, DrawFrogIncrement
		move $a2, $s0
		jal RectArray
		DrawFrogIncrement:
			add $s0, $s0, 3
			addi $s1, $s1, 1
			bne $s1, 5, DrawFrog
	
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)	
	addi $sp, $sp, 20
	jr $ra
		
CheckStandConditions:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $a0, frogPosition
	lb $a1, frogPosition + 1
	addi $a1, $a1, 1
	jal GetPositionColour
	move $a2, $v0
	la $a0, loseColours
	li $a1, 2
	jal Contains
	beqz $v0, ReturnCheckStandConditions
	li $t0, 30
	li $t1, 54
	sb $t0, frogPosition
	sb $t1, frogPosition + 1
		
	ReturnCheckStandConditions:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
CheckMoveConditions: # $a0, $a1 are the intended x, y coord of frog position (unit) - $v0, $v1 are result x, y coord of frog position (unit)
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	
	move $s0, $a0 # $s0 is the intended x-coord of frog position (unit)
	move $s1, $a1 # $s1 is the intended y-coord of frog position (unit)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal GetPositionColour
	move $s2, $v0 # $s2 is the color of intended frog position (char)
	
	la $a0, forbiddenColours
	li $a1, 2
	move $a2, $s2
	jal Contains
	bnez $v0, ReturnMoveForbidden
	
	la $a0, loseColours
	li $a1, 2
	move $a2, $s2
	jal Contains
	bnez $v0, ReturnMoveLoss
	
	ble $s1, 6, ReturnMoveWin
	j ReturnMoveApproved
	
	ReturnMoveForbidden:
		lb $v0, frogPosition
		lb $v1, frogPosition + 1
		j ReturnCheckMoveConditions	
	ReturnMoveLoss:
		li $v0, 30
		li $v1, 54
		j ReturnCheckMoveConditions
	ReturnMoveWin:
		move $a0, $s0
		move $a1, $s1
		jal MarkWin
		li $v0, 30
		li $v1, 54
		j ReturnCheckMoveConditions
	ReturnMoveApproved:
		move $v0, $s0
		move $v1, $s1
	ReturnCheckMoveConditions:
		lw $s2, 0($sp)
		lw $s1, 4($sp)
		lw $s0, 8($sp)
		lw $ra, 12($sp)	
		addi $sp, $sp, 16
		jr $ra
	
GetPositionColour: # $a0, $a1 are x, y coord (unit), $v0 returns colour of position (char)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal GetPos
	lw $t0, displayAddress # $t0 is displayAddress (mem address)
	sll $v0, $v0, 2
	add $t0, $t0, $v0
	lw $a0, 0($t0)
	jal GetColourName
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
MarkWin: # $a0, $a1 are intended x, y coords of frog position (unit)
	la $t0, completedFrogs # $t0 is current element of completed frogs array (mem address)
	li $t1, 0 # $t1 is the number of frogs checked
	NextFrog:
		lb $t2, 0($t0)
		bne $t2, $a0, NextFrogIncrement
		li $t2, 1
		sb $t2, 2($t0)
		NextFrogIncrement:
			add $t0, $t0, 3
			addi $t1, $t1, 1
			bne $t1, 5, NextFrog
	jr $ra
		
##### Utility Functions #####
PrintInt: # $a0 is int to print - all registers are preserved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	
	li $v0, 1
	syscall
	li $v0, 11
	li $a0, 0x20
	syscall
	
	lw $v0, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
PrintChar: # $a0 is char to print - all registers are preserved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	
	li $v0, 11
	syscall
	li $v0, 11
	li $a0, 0x20
	syscall
	
	lw $v0, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra

NextLine: # all registers are preserved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	
	li $v0, 11
	li $a0, 0xa
	syscall
	
	lw $v0, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	

Contains: # $a0 is beginning of array (mem address), $a1 is length of array, $a2 is element to find, $v0 returns whether or not $a2 is in array (0/1)
	li $t0, 0 # $t0 is number of elements checked
	li $v0, 0
	NextElement:
		lb $t1, 0($a0) # $t1 is the current array value
		beq $a2, $t1, ReturnContainsTrue
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		bne $t0, $a1, NextElement
		j ReturnContains
	ReturnContainsTrue:
		li $v0, 1
	ReturnContains:
		jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
