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
# - Milestone 5
#
# Which approved additional features have been implemented?
# - Easy Feature #1: display lives
# - Easy Feature #5: different rows move with different speed (speed & direction is customizable by changing shiftDirection array)
# - Easy Feature #6: 3 rows of vehicles & logs
# - Hard Feature #6: 2 player mode (change using multiPlayer byte in memory)
# - Hard Feature #7: display score
#
# Any additional information that the TA needs to know:
# - At any point in the game, the 'R' key can be used to reset the game (including lives & scores).
# - At any point in the game, the 'M' key can be used to toggle multiplayer mode on & off (game is reset).
#
#####################################################################
.data
	##### Display Data #####
	displayAddress: .word 0x10008000
	displayBuffer: .space 0x4000
	black: .word 0x000000 # '0' - used for clear
	white: .word 0xffffff # '1' - used for undefined values
	red: .word 0xff0000 # 'r' - used for vehicles
	green: .word 0x00ff00 # 'g' - used for safe areas
	blue: .word 0x0000ff # 'b' - used for border
	lightBlue: .word 0x00bfff # 'l' - stands for light - used for water
	darkGreen: .word 0x008000 # 'f' - stands for frog - used for frog!
	brown: .word 0xd2691e # 'w' - stands for wood - used for logs
	gray: .word 0x696969 # 's' - stands for street - used for road!
	scene: .byte 0, 0, 59, 5, 'b', # border top
		59, 0, 5, 59, 'b', # border right
		5, 59, 59, 5, 'b', # border bottom
		0, 5, 5, 59, 'b', # border left
		5, 53, 54, 6, 'g', # safe bottom
		5, 29, 54, 6, 'g', # safe mid
		5, 35, 54, 18, 's', # road
		5, 5, 54, 24, 'l', # water
		5, 5, 7, 6, 'g', # safe top 1
		16, 5, 8, 6, 'g', # safe top 2
		28, 5, 8, 6, 'g', # safe top 3
		40, 5, 8, 6, 'g', # safe top 4
		52, 5, 7, 6, 'g' # safe top 5
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
	
	##### Movement Data #####
	inputAddress: .word 0xffff0000
	scenePosition: .byte 0, 0
	frogData: .byte 30, 54, # frog position
		30, 54, # init frog position
		3, # lives
		0, # game time
		0, 0 # score (half word)
	roadPosition: .byte 5, 35
	waterPosition: .byte 5, 11
	shiftDirection: .byte 2, 2, 2, # vehicles - row 1
		-1, -1, # vehicles - row 2
		1, 1, 1, # vehicles - row 3
		1, 1, # logs - row 1
		-1, -1, -1, # logs - row 2
		1, 1 # logs - row 3
	
	##### Game Logic Data #####
	wins: .byte 0
	completedFrogs: .byte 6, 6, 0, # safe region 1
		18, 6, 0, # safe region 2
		30, 6, 0, # safe region 3
		42, 6, 0, # safe region 4
		54, 6, 0 # safe region 5
	forbiddenColours: .byte 'b', 'f' # border & frog
	loseColours: .byte 'r', 'l' # cars & water
	
	##### Game Stats Data #####
	livesText: .asciiz "lives:"
	scoreText: .asciiz "score:"
	inlineSeparatorText: .asciiz "/"
	separatorText: .asciiz "----------"
	
	##### Multiplayer Data #####
	frogDataMulti: .byte 18, 54, # frog position 1
		18, 54, # init frog position 1
		3, # lives 1
		0, # game time 1
		0, 0, # score 1 (half word)
		42, 54, # frog position 2
		42, 54, # init frog position 2
		3, # lives 1
		0, # game time 2
		0, 0 # score 2 (half word)
	multiPlayer: .byte 0
	
	##### Keybind Data #####
	tick: .byte 0
	initVehicles: .byte 6, 1, 6, 4, 'r', # row 1 - car 1
		24, 1, 6, 4, 'r', # row 1 - car 2
		42, 1, 6, 4, 'r', # row 1 - car 3
		6, 7, 12, 4, 'r', # row 2 - car 1
		36, 7, 12, 4, 'r', # row 2 - car 2
		6, 13, 6, 4, 'r', # row 3 - car 1
		24, 13, 6, 4, 'r', # row 3 - car 2
		42, 13, 6, 4 'r' # row 3 - car 3
	initLogs: .byte 6, 1, 12, 4, 'w', # row 1 - log 1
		36, 1, 12, 4, 'w', # row 1 - log 2
		6, 7, 6, 4, 'w', # row 2 - log 1
		24, 7, 6, 4, 'w', # row 2 - log 2
		42, 7, 6, 4, 'w', # row 2 - log 3
		6, 13, 12, 4, 'w', # row 3 - log 1
		36, 13, 12, 4, 'w' # row 3 - log 2

.text
main:
	li $s0, 0
	jal PrintAllData
	MainLoop:
		sb $s0, tick
		jal LoopInit
		jal LoopDraw
		lb $s0, tick
		jal LoopTime
		bne $s0, 30, MainLoop
		jal LoopSecond
		j MainLoop
	j Exit
		
LoopInit:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal CheckInitConditions
	jal CheckInput
	lb $t0, wins
	bge $t0, 5, Exit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

LoopDraw:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal Clear
	jal Scene
	jal FrogRoadWater
	jal CompletedFrogs
	jal FlushBuffer
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
LoopTime: # uses $s0 same as main
	li $v0, 32
	li $a0, 16
	syscall
	addi $s0, $s0, 1
	jr $ra
	
LoopSecond: # uses $s0 same as main
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $s0, 0
	jal ShiftAllFrogs
	jal ShiftRoadWater
	jal LoopDraw
	jal UpdateGameTime
	
	ReturnLoopSecond:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

				
##### Display Functions #####
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
	li $a1, 13
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
	jal DrawFrogs
	
	ReturnFrogRoadWater:
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
	la $t4, displayBuffer # $t4 stores displayBuffer (mem address)
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
		
FlushBuffer:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, displayBuffer # $t0 is current element displayBuffer (mem address)
	lw $t1, displayAddress # $t1 is current element in display (mem address)
	li $t2, 0x1000 # $t2 is the length of display
	li $t3, 0 # $t3 is index of current element in display
	FlushPixel:
		lw $t4, 0($t0)
		sw $t4, 0($t1)
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		addi $t3, $t3, 1
		bne $t3, $t2, FlushPixel
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
#### Movement Functions #####
CheckInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, inputAddress # $t0 is inputAddress (mem address)
	lw $t1, 0($t0) # $t1 is whether or not there has been keyboard input (0/1)
	bne $t1, 1, ReturnCheckInput
	lw $a0, 4($t0)
	jal CheckMoveInput
	bnez $v0, ReturnCheckInput
	jal CheckKeybindInput
	
	ReturnCheckInput:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
InputWASD: # $a0 is keyboard input, $v0 is whether or not input was wasd (0/1), $v1 is simplified input (w/a/s/d)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 1
	beq $a0, 'w', InputLowerWASD
	beq $a0, 'W', InputUpperWASD
	beq $a0, 'a', InputLowerWASD
	beq $a0, 'A', InputUpperWASD
	beq $a0, 's', InputLowerWASD
	beq $a0, 'S', InputUpperWASD
	beq $a0, 'd', InputLowerWASD
	beq $a0, 'D', InputUpperWASD
	li $v0, 0
	j ReturnInputWASD
	InputUpperWASD:
		addi $a0, $a0, 0x20
	InputLowerWASD:
		move $v1, $a0
	
	ReturnInputWASD:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
InputIJKL: # $a0 is keyboard input, $v0 is whether or not input was ijkl (0/1), $v1 is simplified input (w/a/s/d)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 1
	beq $a0, 'i', InputIToW
	beq $a0, 'I', InputIToW
	beq $a0, 'j', InputJToA
	beq $a0, 'J', InputJToA
	beq $a0, 'k', InputKToS
	beq $a0, 'K', InputKToS
	beq $a0, 'l', InputLToD
	beq $a0, 'L', InputLToD
	li $v0, 0
	j ReturnInputIJKL
	InputIToW:
		li $v1, 'w'
		j ReturnInputIJKL
	InputJToA:
		li $v1, 'a'
		j ReturnInputIJKL
	InputKToS:
		li $v1, 's'
		j ReturnInputIJKL
	InputLToD:
		li $v1, 'd'
		j ReturnInputIJKL
	
	ReturnInputIJKL:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
Move: # $a0 is move direction (w/a/s/d), $a1 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $t0, $a0 # $t0 preserves move direction (w/a/s/d)
	move $s0, $a1 # $s0 preserves frogData (mem address)
	move $a2, $a1
	lb $a0, 0($s0)
	lb $a1, 1($s0)
	beq $t0, 'w', MoveForward
	beq $t0, 'a', MoveLeft
	beq $t0, 's', MoveBackward
	beq $t0, 'd', MoveRight
	j ReturnMove
	MoveForward:
		add $a1, $a1, -6
		j ReturnMove
	MoveLeft:
		add $a0, $a0, -6
		j ReturnMove
	MoveBackward:
		add $a1, $a1, 6
		j ReturnMove
	MoveRight:
		add $a0, $a0, 6
	ReturnMove:
		jal CheckMoveConditions
		sb $v0, 0($s0)
		sb $v1, 1($s0)
		
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
ShiftRoadWater:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, vehicles
	li $a1, 8
	la $a2, shiftDirection
	jal Shift
	la $a0, logs
	li $a1, 7
	la $a2, shiftDirection + 8
	jal Shift
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
Shift: # $a0 is element array (mem address), $a1 is length of element array, $a2 is shiftDirection array (mem address), $a3 is overflow amount
	li $t0, 0 # $t0 is the number of vehicles/logs we've shifted
	ShiftElement:
		lb $t2, 0($a2)
		li $t3, 6
		mult $t2, $t3
		mflo $t2 # $t2 is the amount to shift (unit)
		lb $t1, 0($a0)
		add $t1, $t1, $t2 # $t1 is the new x value of the element (unit)
		bge $t1, 54, RightShiftOverflow
		blt $t1, 0, LeftShiftOverflow
		j ShiftDone
		RightShiftOverflow:
			add $t1, $t1, -54
			j ShiftDone
		LeftShiftOverflow:
			add $t1, $t1, 54
		ShiftDone:
			sb $t1, 0($a0)
			add $a0, $a0, 5
			add $t0, $t0, 1
			add $a2, $a2, 1
			bne $t0, $a1, ShiftElement
	jr $ra
	
ShiftFrog: # a0 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0 # $s0 preserves frogData (mem address)
	lb $a0, 0($s0)
	lb $a1, 1($s0)
	addi $a1, $a1, 1
	jal GetPositionColour
	bne $v0, 'w', ReturnShiftFrog
	lb $a0, 0($s0)
	lb $a1, 1($s0)
	jal FindFrogLog
	move $a0, $s0
	li $a1, 1
	la $a2, shiftDirection
	add $a2, $a2, $v0
	
	lb $t0, 0($s0) # correction for border in frog position
	addi $t0, $t0, -5
	sb $t0, 0($s0)
	jal Shift
	lb $t0, 0($s0)
	addi $t0, $t0, 5
	sb $t0, 0($s0)
	
	ReturnShiftFrog:
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
FindFrogLog: # $a0, $a1 are x, y coords of frog (unit), $v0 is index of frog log
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $t0, waterPosition
	lb $t1, waterPosition + 1
	sub $a0, $a0, $t0
	sub $a1, $a1, $t1
	la $t0, logs # $t0 is current log (mem address)
	li $t1, 0 # $t1 is the number of logs checked
	NextFrogLog:
		lb $t3, 1($t0)
		bne $a1, $t3, IterateFrogLog
		move $t2, $a0 # $t2 is x coord of frog (unit)
		lb $t3, 0($t0)
		lb $t4, 2($t0)
		add $t3, $t3, $t4
		ble $t3, 54, FrogLogNormal
		addi $t2, $t2, 54
		FrogLogNormal:
			bge $t2, $t3, IterateFrogLog
			lb $t3, 0($t0)
			blt $t2, $t3, IterateFrogLog
			move $v0, $t1
		j ReturnFrogLog
		IterateFrogLog:
			addi $t0, $t0, 5
			addi $t1, $t1, 1
			bne $t1, 7, NextFrogLog
	
	ReturnFrogLog:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
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

##### Game Logic Functions #####
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
	DrawCompletedFrog:
		move $a0, $s2
		move $a1, $s3
		lb $t2, 2($s0)
		beq $t2, 0, DrawFrogIncrement
		move $a2, $s0
		jal RectArray
		DrawFrogIncrement:
			add $s0, $s0, 3
			addi $s1, $s1, 1
			bne $s1, 5, DrawCompletedFrog
	
	lw $s3, 0($sp)
	lw $s2, 4($sp)
	lw $s1, 8($sp)
	lw $s0, 12($sp)
	lw $ra, 16($sp)	
	addi $sp, $sp, 20
	jr $ra
		
CheckStandConditions: # $a0 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0 # $s0 preserves frogData (mem address)
	lb $a0, 0($s0)
	lb $a1, 1($s0)
	addi $a1, $a1, 1
	jal GetPositionColour
	move $a2, $v0
	la $a0, loseColours
	li $a1, 2
	jal Contains
	beqz $v0, ReturnCheckStandConditions
	move $a0, $s0
	jal AddLossToLives
	lb $t0, 2($s0)
	lb $t1, 3($s0)
	sb $t0, 0($s0)
	sb $t1, 1($s0)
		
	ReturnCheckStandConditions:
		lw $s0, 0($sp)
		lw $ra, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
CheckMoveConditions: # $a0, $a1 are the intended x, y coord of frog position (unit), $a2 is frogData (mem address) - $v0, $v1 are result x, y coord of frog position (unit)
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $s3, 0($sp)
	
	move $s0, $a0 # $s0 is the intended x-coord of frog position (unit)
	move $s1, $a1 # $s1 is the intended y-coord of frog position (unit)
	move $s2, $a2 # $s2 is frogData (mem address)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal GetPositionColour
	move $s3, $v0 # $s3 is the color of intended frog position (char)
	
	la $a0, forbiddenColours
	li $a1, 2
	move $a2, $s3
	jal Contains
	bnez $v0, ReturnMoveForbidden
	
	la $a0, loseColours
	li $a1, 2
	move $a2, $s3
	jal Contains
	bnez $v0, ReturnMoveLoss
	
	ble $s1, 6, ReturnMoveWin
	j ReturnMoveApproved
	
	ReturnMoveForbidden:
		lb $v0, 0($s2)
		lb $v1, 1($s2)
		j ReturnCheckMoveConditions	
	ReturnMoveLoss:
		move $a0, $s2
		jal AddLossToLives
		lb $v0, 2($s2)
		lb $v1, 3($s2)
		j ReturnCheckMoveConditions
	ReturnMoveWin:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		jal MarkWin
		lb $v0, 2($s2)
		lb $v1, 3($s2)
		j ReturnCheckMoveConditions
	ReturnMoveApproved:
		move $v0, $s0
		move $v1, $s1
		
	ReturnCheckMoveConditions:
		lw $s3, 0($sp)
		lw $s2, 4($sp)
		lw $s1, 8($sp)
		lw $s0, 12($sp)
		lw $ra, 16($sp)	
		addi $sp, $sp, 20
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
	
MarkWin: # $a0, $a1 are intended x, y coords of frog position (unit), $a2 is frogData (mem address)
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s0, 4($sp)
	sw $s1, 0($sp)
	
	la $s0, completedFrogs # $s0 is current element of completed frogs array (mem address)
	li $s1, 0 # st1 is the number of frogs checked
	NextFrog:
		lb $t0, 0($s0)
		bne $t0, $a0, NextFrogIncrement
		li $t0, 1
		sb $t0, 2($s0)
		NextFrogIncrement:
			add $s0, $s0, 3
			addi $s1, $s1, 1
			bne $s1, 5, NextFrog
	move $a0, $a2
	jal AddWinToScore
	lb $t0, wins
	addi $t0, $t0, 1
	sb $t0, wins
	
	lw $s1, 0($sp)
	lw $s0, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
		
##### Game Stats Functions #####
AddWinToScore: # $a0 is frogData (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lh $t0, 6($a0) # $t0 is the score
	addi $t0, $t0, 1200
	lb $t1, 5($a0)
	sll $t1, $t1, 1
	sub $t0, $t0, $t1
	sh $t0, 6($a0)
	sb $zero, 5($a0)
	jal PrintAllData
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
AddLossToLives: # $a0 is frogData (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lb $t0, 4($a0)
	addi $t0, $t0, -1
	sb $t0, 4($a0)
	jal PrintAllData
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
PrintData: # $a0 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0 # $s0 preserves frogData (mem address)
	la $a0, livesText
	jal PrintString
	lb $a0, 4($s0)
	jal PrintInt
	la $a0, inlineSeparatorText
	jal PrintString
	la $a0, scoreText
	jal PrintString
	lh $a0, 6($s0)
	jal PrintInt
	jal NextLine
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
		
##### Multiplayer Functions #####
DrawFrogs:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $t0, multiPlayer
	beqz $t0, DrawFrogSingle
	j DrawFrogMulti
	
	DrawFrogSingle:
		la $a0, frogData
		jal DrawFrogHelper
		j ReturnDrawFrog
	DrawFrogMulti:
		la $a0, frogDataMulti
		jal DrawFrogHelper
		la $a0, frogDataMulti + 8
		jal DrawFrogHelper
	
	ReturnDrawFrog:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
DrawFrogHelper: # $a0 is frogData (mem address)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a2, $a0
	la $a0, frog
	li $a1, 5	
	li $a3, 0
	jal RectArray
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
CheckMoveInput: # $a0 is keyboard input (char), $v0 returns whether or not input was valid move input (0/1)
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lb $t0, multiPlayer
	beqz $t0, MoveInputSingle
	j MoveInputMulti
	
	MoveInputSingle:
		jal InputWASD
		beqz $v0, ReturnCheckMoveInput
		la $a1, frogData
		jal Move
		j ReturnCheckMoveInput
	MoveInputMulti:
		jal InputWASD
		bnez $v0, MoveInputFrog1
		jal InputIJKL
		bnez $v0, MoveInputFrog2
		beqz $v0, ReturnCheckMoveInput
		MoveInputFrog1:
			move $a0, $v1
			la $a1, frogDataMulti
			jal Move
			j ReturnCheckMoveInput
		MoveInputFrog2:
			move $a0, $v1
			la $a1, frogDataMulti + 8
			jal Move
	
	ReturnCheckMoveInput:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
CheckInitConditions:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $t0, multiPlayer
	beqz $t0, CheckInitSingle
	j CheckInitMulti
	
	CheckInitSingle:
		la $a0, frogData
		jal CheckInitConditionsHelper
		j ReturnCheckInit
	CheckInitMulti:
		la $a0, frogDataMulti
		jal CheckInitConditionsHelper
		la $a0, frogDataMulti + 8
		jal CheckInitConditionsHelper
		
	ReturnCheckInit:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
CheckInitConditionsHelper: # $a0 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0 # $s0 preserves frogData (mem address)
	jal CheckStandConditions
	lb $t0, 4($s0)
	blez $t0, Exit
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
		
UpdateGameTime:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lb $t0, multiPlayer
	beqz $t0, UpdateGameTimeSingle
	j UpdateGameTimeMulti

	UpdateGameTimeSingle:
		la $a0, frogData
		jal UpdateGameTimeHelper
		j ReturnUpdateAllGameTime
	UpdateGameTimeMulti:
		la $a0, frogDataMulti
		jal UpdateGameTimeHelper
		la $a0, frogDataMulti + 8
		jal UpdateGameTimeHelper
	
	ReturnUpdateAllGameTime:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
UpdateGameTimeHelper: # $a0 is frogData (mem address)
	lb $t0, 5($a0) # $t0 is the gameTime (seconds)
	beq $t0, 100, ReturnUpdateGameTimeHelper
	addi $t0, $t0, 1
	sb $t0, 5($a0)
	
	ReturnUpdateGameTimeHelper:
		jr $ra

PrintAllData:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $t0, multiPlayer
	beqz $t0, PrintDataSingle
	j PrintDataMulti
	
	PrintDataSingle:
		la $a0, frogData
		jal PrintData
		j PrintDataSeparator
	PrintDataMulti:
		la $a0, frogDataMulti
		jal PrintData
		la $a0, frogDataMulti + 8
		jal PrintData
	
	PrintDataSeparator:
		la $a0, separatorText
		jal PrintString
		jal NextLine
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
ShiftAllFrogs:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lb $t0, multiPlayer
	beqz $t0, ShiftFrogSingle
	j ShiftFrogMulti
	
	ShiftFrogSingle:
		la $a0, frogData
		jal ShiftFrog
		j ReturnShiftAllFrogs
	ShiftFrogMulti:
		la $a0, frogDataMulti
		jal ShiftFrog
		la $a0, frogDataMulti + 8
		jal ShiftFrog
	
	ReturnShiftAllFrogs:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
##### Keybind Functions #####
CheckKeybindInput: # $a0 is keyboard input (char), $v0 returns whether or not input was valid keybind input (0/1)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	beq $a0, 'r', ResetInput
	beq $a0, 'R', ResetInput
	beq $a0, 'm', MultiPlayerInput
	beq $a0, 'M', MultiPlayerInput
	li $v0, 0
	j ReturnKeybindInput
	MultiPlayerInput:
		jal ToggleMultiPlayer
	ResetInput:
		jal Reset
		li $v0, 1
	
	ReturnKeybindInput:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

Reset:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal ResetScene
	jal ResetAllFrogs
	jal ResetCompletedFrogs
	sb $zero, wins
	sb $zero, tick
	jal LoopDraw
	jal PrintAllData
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
ResetScene:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal Clear
	la $a0, initVehicles
	la $a1, vehicles
	li $a2, 40
	jal Copy
	la $a0, initLogs
	la $a1, logs
	li $a2, 35
	jal Copy
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
ResetAllFrogs:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	la $a0, frogData
	jal ResetFrog
	la $a0, frogDataMulti
	jal ResetFrog
	la $a0, frogDataMulti + 8
	jal ResetFrog
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
ResetFrog: # $a0 is frogData (mem address)
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	move $s0, $a0
	addi $a0, $s0, 2
	move $a1, $s0
	li $a2, 2
	jal Copy
	li $t0, 3
	sb $t0, 4($s0)
	sb $zero, 5($s0)
	sh $zero, 6($s0)
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
ResetCompletedFrogs:
	la $t0, completedFrogs # $t0 is current element in completedFrogs (mem address)
	li $t1, 0 # $t1 is the number of frogs reset
	ResetNextFrog:
		sb $zero, 2($t0)
		addi $t0, $t0, 3
		addi $t1, $t1, 1
		bne $t1, 5, ResetNextFrog
	jr $ra
	
ToggleMultiPlayer:
	lb $t0, multiPlayer # $t0 is current value of multiplayer (0/1)
	li $t1, 1
	sub $t0, $t1, $t0
	sb $t0, multiPlayer
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
	
PrintString: # $a0 is string to print - all registers are preserved
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	
	li $v0, 4
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
		
Copy: # $a0 is copy source (mem address), $a1 is copy destination (mem address), $a2 is length of array	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t0, 0 # $t0 is index of current element in array
	CopyByte:
		lb $t1, 0($a0)
		sb $t1, 0($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $t0, $t0, 1
		bne $a2, $t0, CopyByte
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
Exit:
	jal LoopDraw
	li $v0, 10 # terminate the program gracefully
	syscall