
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2017 <Devin Dai>
#
# Unauthorized redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# Assignment:           4
# Due Date:             November 20, 2017
# Name:                 Devin Dai
# ID:              	1501722
# Lecture Section:      A1
# Instructor:           Nelson 
# Lab Section:          D05
# Teaching Assistant:   Rong Feng
#---------------------------------------------------------------
# getTile:
# 	Given the position of a tile on the board, specified as a (row, column) pair, return the address of the character byte 
# 	(from the List of Characters) that should be used to display the tile.
# register:
#	$a0 = row of tile
#	$a1 = column of tile
#	$v0 = address to character byte that should represent this tile (see List of Characters)
#	$v1 = consider using this return value to return the state of the tile
# 	t0 = row#
# 	t1 = col#
# 	t2 = max row#
# 	t3 = max col#
# 	t4 = content of the tile
# 	t5 = bomb counter
# 	t6 = offset for the gameBoard
# 	s2 = bomb counter
# 	s6 = rowstart + row off
# 	s7 = colstart + col off
#----------------------------------------------------------------
# hasBomb:
#	Check if a tile specified by a (row, column) pair has a bomb.
#Arguments:
#	$a0 = row of tile
#	$a1 = column of tile
#	$v0 = 1 if the tile has a bomb and 0 otherwise.
# 	s0 = total input row#
# 	s1 = total input col#
# 	t0 = row#
# 	t1 = col#
# 	s2 = the tile I need to check(offset)
#-----------------------------------------------------------------
#setBomb
#	Sets the tile (row, column) to contain an unrevealed bomb
#Arguments:
#	$a0 = row of tile to set
#	$a1 = column of tile to set
# 	s0 = total input row#
# 	s1 = total input col#
# 	t0 = row#
# 	t1 = col#
# 	s2 = the tile I need to set
# 	t4 = 12 for unrevealed bomb
#------------------------------------------------------------------
#prepareBoard
#	This prepareBoard function is intended to transform the initial gameBoard
#------------------------------------------------------------------
#printTile:
#	Prints the tile located at (row, column) using the appropriate character from the list of characters above. 
#	printTile must use the GLIM method printString to print to the specified tile location on the terminal window.
#-----------------------------------------------------------------------------
#exception handler:
#	The exception handler should replace the default exception handler
#---------------------------------------------------------------------------
#getReveal:
#	reveals the tiles and the region around it when there is 
# 	s0 = old row value
# 	s1 = old col value
# 	t0 = gameRow
# 	t1 = gameCol
#---------------------------------------------------------------------------




# interruption (computer calls it as it realize there is an exception)
# in coprocessor 0
	# $12 = status
	# $13 = cause
	# $14 = EPC
	# $9 / $11 = timer

.kdata
	.align 4
	savea0: .space 4
	savea1: .space 4
	saveat: .space 4

.ktext 0x80000180 
	la $k0, savea0
	sw $a0, 0($k0)		# save a0

	la $k0, savea1
	sw $a1, 0($k0)		# save a1
	
	.set noat
		la $k0, saveat
		sw $at, 0($k0)		# save at
	.set at

	# check which exception it is	

	li $k0, 0x00000800		# keyboard cause mask
	mfc0 $k1, $13			# Cause register
	and $a0, $k1, $k0		# if bit 11 is 1 then go to keyboard inter
	bnez $a0, keyInter		
	
	li $k0, 0x00008000
	and $a0, $k1, $k0	
	bnez $a0, timeInter		# if bit 15 is 1 then go to time inter
	
	j kfinish

	
# reset $11 an $9
timeInter:

	mtc0 $zero, $9            # counting the milliseconds
    	li $k0, 100
   	mtc0 $k0, $11             # counting the seconds

	li $k1, 1
	la $k0, interCheck
	sb $k1, 0($k0)		# the interCheck is 1 for timer

	j kfinish


# get ascii 
keyInter:
	
	
	li $k0, 0xffff0004
	lbu $k0, 0($k0)		# content for data (top 3 bytes cleared) # k0 = 8 bits ASCII	
	
	la $k1, ascii
	sb $k0, 0($k1)

	li $k1, 2
	la $k0, interCheck
	sb $k1, 0($k0)		# the interCheck is 2 for keyboard

	
	j doneKeyInter


doneKeyInter:
	li $k0, 0xffff0000
	lw $a0, 0($k0)		
	li $k1, 0x00000002
	or $k1, $k1, $a0
	sw $k1, 0($k0)			# re-enable keyboard interurpt

	j kfinish

kfinish:
	mtc0 $zero, $13			# Clear Cause register
	mfc0 $k0, $12			# Set Status register
	li $a1, 0x0000fffd
	and $k0, $k0, $a1		# clear exception level bit
	li $a1, 0x00000001
	or  $k0, $k0, $a1		# Interrupts re-enabled
	mtc0 $k0, $12			# write back to status


		
	la $k0, savea0
	lw $a0, 0($k0)		# restore a0 
	 
	la $k0, savea1
	lw $a1, 0($k0)		# restore a1

	.set noat
		la $k0, saveat
		lw $at, 0($k0)		# restore at
	.set at

	eret

	


####################################################
.data
	time: 
		.align 4
		.space 4

	ones:
		.align 2
		.space 1
	tens:
		.align 2
		.space 1

	hundreds:
		.align 2
		.space 1

	ascii: 
		.align 2
		.space 1

	interCheck:
		.align 2
		.space 1

	timerFlag:
		.align 2
		.space 1

	#loseFlag1:
		#.align 2
		#.space 1



.text	
main:
	addi $sp $sp -36
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)



	li $t0, 0x00000801		# status reg mask for key
	mfc0 $t1, $12			# status reg
	or $t1, $t1, $t0		# enable keyboard interruption
	mtc0 $t1, $12			# store the changes back to status reg
	
	jal updateCursor
	
	li $t0, 0xffff0000	# address for the control reg	
	li $t3, 0x00000002
	sw $t3, 0($t0)		# enable keyboard interurpt




timerPrinting:
	la $t4, time		# t4 = timer adress
	li $t5, 5
	li $t6, 999

	la $s6, gameRows
	lw $s6, 0($s6)
	
	la $s7, gameCols
	lw $s7, 0($s7)

	la $s5, totalBombs
	lw $s5, 0($s5)		# total number of bomb
	
	li $t3, 888
	mult $s5, $t3		# B*888
	mflo $t2
	mult $s6, $s7		# total tile
	mflo $t0
	sub $s4, $t0, $s5	# E(empty tile)
	div $t2, $s4
	mflo $t1		# final seconds = B*888/E
	
	bgt $t1, $t5, compareNext	# if time is bigger than 5 then compare with 999
	sw $t5, 0($t4)		# otherwise, store 5 in timer

	j printTime

compareNext:
	blt $t1, $t6, storeTime		# if time less than 999, store calculated time
	sw $t6, 0($t4)			# otherwise, store 999 in timer
	
	j printTime

storeTime:
	sw $t1, 0($t4)		# store calculated time in timer

	j printTime




printTime:
	la $t4, time
	lw $a0, 0($t4)		# load the number of timer
	
	addi $sp $sp -4
	sw $t4, 0($sp)

	jal intToChar

	lw $t4, 0($sp)
	addi $sp $sp 4

	lb $t0, 0($v0)		# one
	lb $t1, 1($v0)		# ten
	lb $t2, 2($v0) 		# hundred

	
	la $t5, ones
	sb $t0, 0($t5)

	la $t5, tens
	sb $t1, 0($t5)
	
	la $t5, hundreds
	sb $t2, 0($t5)
	
	la $a0, ones
	move $a1, $s6
	li $a2, 2

	jal printString


	la $a0, tens
	move $a1, $s6
	li $a2, 1

	jal printString
	
	la $a0, hundreds
	move $a1, $s6
	li $a2, 0

	jal printString





mainBegin:	

	la $t0, interCheck	# check what exception it is
	lb $t0, 0($t0)

	li $t1, 1
	beq $t1, $t0, timer	# 1 for timer

	li $t1, 2
	beq $t1, $t0, keyboard	# 2 for keyboard

	

	j infiniteLoop


timer:

lastDig:
	la $t0, ones
	lb $t1, 0($t0)
	li $t2, 0x30		# zero
	beq $t1, $t2, middleDig	# if lastDig is 0, got to middledig
	addi $t1, $t1, -1
	sb $t1, 0($t0)
	
	move $a0, $t0		# address for arg	
	la $t3, gameRows
	lw $a1, 0($t3)
	li $a2, 2
	jal printString

	j timerInfiniteLoop
	
	
	
middleDig:
	li $t0, 0x39
	la $t1, ones
	sb $t0, 0($t1)		# set the lastdig to 9

	move $a0, $t1
	la $t3, gameRows
	lw $a1, 0($t3)
	li $a2, 2
	jal printString
	

	la $t3, tens
	lb $t4, 0($t3)
	li $t2, 0x30	
	beq $t4, $t2, firstDig
	addi $t4, $t4, -1
	sb $t4, 0($t3)

	move $a0, $t3
	la $t5, gameRows
	lw $a1, 0($t5)
	li $a2, 1
	jal printString

	j timerInfiniteLoop
	
	
firstDig:
	li $t0, 0x39
	la $t1, tens
	sb $t0, 0($t1)  	# set middledig to 9

	move $a0, $t1
	la $t3, gameRows
	lw $a1, 0($t3)
	li $a2, 1
	jal printString
	
	la $t0, hundreds
	lb $t1, 0($t0)
	li $t2, 0x30
	beq $t1, $t2, firstToZero
	addi $t1, $t1, -1
	sb $t1, 0($t0)
	
	move $a0, $t0
	la $t5, gameRows
	lw $a1, 0($t5)
	li $a2, 0
	jal printString


	j timerInfiniteLoop

firstToZero:

	li $t0, 0x30
	la $t1, hundreds	
	sb $t0, 0($t1)
	
	move $a0, $t1
	la $t5, gameRows
	lw $a1, 0($t5)
	li $a2, 0
	jal printString

	j lose			# if the hundredth position is 0, player loses



keyboard:

	la $t2, ascii
	lb $t2, 0($t2)		# t2 = 8 bits ASCII


	la $t4, newCursorRow
	la $t5, newCursorCol
	

	la $t6, cursorRow	# old row value
	lw $t6, 0($t6)
	la $t7, cursorCol	# old col value
	lw $t7, 0($t7)

	la $s0, gameRows
	lw $s0, 0($s0)		# get the input row

	la $s1, gameCols
	lw $s1, 0($s1)		# get the input col

	# compare with 53(reveal), 55(mark), 50(down), 52(left), 54(right), 56(up), 113(q), 114(r)
	
	li $t3, 0x56
	beq $t2, $t3, up
	
	li $t3, 52
	beq $t2, $t3, left
	
	li $t3, 54
	beq $t2, $t3, right
		
	li $t3, 50
	beq $t2, $t3, down
	
	li $t3, 55
	beq $t2, $t3, mark

	li $t3, 53
	beq $t2, $t3, reveal

	li $t3, 113
	beq $t2, $t3, quit

	li $t3, 114
	beq $t2, $t3, restart

up:
	li $t9, 0
	beq $t6, $t9, noUp	# if row is 0, then noUp

	addi $t8, $t6, -1	# row# - 1
	sw $t8, 0($t4)		# new row into newCursorRow
	sw $t7, 0($t5)		# old col into newCursorCol
	jal updateCursor
	
	j restore
		
noUp:
	sw $t6, 0($t4)	# same row into newCursorRow
	sw $t7, 0($t5)	# same col into newCursorCol
	jal updateCursor

	j restore


left:
	li $t9 ,0
	beq $t7, $t9, noLeft	# if col is 0 then noLeft

	addi $t8, $t7, -1	# col# - 1
	sw $t6, 0($t4)		# old row# into newCursorRow
	sw $t8, 0($t5)		# new col# into newCursorCol
	jal updateCursor
	
	j restore
noLeft:
	sw $t6, 0($t4)		# same row into newCursorRow
	sw $t7, 0($t5)		# same col into newCursorCol
	jal updateCursor

	j restore
	


right:
	addi $t9, $s1, -1
	beq $t7, $t9, noRight	# if col# == total # of col -1

	addi $t8, $t7, 1	# col# + 1
	sw $t6, 0($t4)		# old row# into newCursorRow
	sw $t8, 0($t5)		# new col# into newCursorCol
	jal updateCursor
	
	j restore
noRight:
	sw $t6, 0($t4)	# same row into newCursorRow
	sw $t7, 0($t5)	# same col into newCursorCol
	jal updateCursor

	j restore


down:
	addi $t9, $s0, -1
	beq $t6, $t9, noDown	# if row# == total # of row - 1

	addi $t8, $t6, 1	# row# + 1
	sw $t8, 0($t4)		# new row into newCursorRow
	sw $t7, 0($t5)		# old col into newCursorCol
	jal updateCursor
	
	j restore
noDown:
	sw $t6, 0($t4)		# same row into newCursorRow
	sw $t7, 0($t5)		# same col into newCursorCol
	jal updateCursor

	
	j restore


mark:

	la $t3, loseFlag
	lb $t3, 0($t3)
	bnez $t3, restore	# if the flag is 1 then go to restore and loop again


	move $a0, $t6
	move $a1, $t7

	addi $sp $sp -8		# storing t reg for function call
	sw $t6 0($sp)
	sw $t7 4($sp)

	jal getTile

	
	lw $t6 0($sp)
	lw $t7 4($sp)
	addi $sp $sp 8

	li $t8, 12
	beq $v1, $t8, num12

	li $t8, 13
	beq $v1, $t8, num13

	li $t8, 10
	beq $v1, $t8, num10

	li $t8, 11
	beq $v1, $t8, num11

	j restore


num12:
	# t6 rows I have to skip for calculation
	mult $t6, $s7		# multiply total col # with the row # for calculation( how many bits I have to skip to get to row )
	mflo $t8
	add $t9, $t8, $t7	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
	
	la $t3, gameBoard
	add $t3, $t3, $t9
	li $s4, 10 		# 10 for marked bomb
	sb $s4, 0($t3)

	j restore

num13:
	# t6 rows I have to skip for calculation
	mult $t6, $s7		# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t8
	add $t9, $t8, $t7	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
	
	la $t3, gameBoard
	add $t3, $t3, $t9
	li $s4, 11 		# 11 for marked clear
	sb $s4, 0($t3)
	
	
	j restore

num10:
	# t6 rows I have to skip for calculation
	mult $t6, $s7		# multiply total col # with the row # for calculation( how many bits I have to skip to get to row )
	mflo $t8
	add $t9, $t8, $t7	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
	
	la $t3, gameBoard
	add $t3, $t3, $t9
	li $s4, 12		# 12 for unreveal bomb
	sb $s4, 0($t3)

	j restore

num11:
	# t6 rows I have to skip for calculation
	mult $t6, $s7		# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t8
	add $t9, $t8, $t7	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
	
	la $t3, gameBoard
	add $t3, $t3, $t9
	li $s4, 13		# 13 for unreavel clear
	sb $s4, 0($t3)
	
	
	j restore



reveal:
	la $t3, loseFlag
	lb $t3, 0($t3)
	bnez $t3, restore	# if the flag is 1 then go to restore and loop again


	la $t1, timerFlag	# check the timerflag
	lb $t2, 0($t1)
	bnez $t2, continuReveal


# initialize timer when 5 is pressed

	li $t0, 0x00008001		# status reg mask for timer
	mfc0 $t1, $12			# status reg
	or $t1, $t1, $t0		# enable timer interruption
	mtc0 $t1, $12			# store the changes back to status reg

	mtc0 $zero, $9            	# counting the milliseconds
    	li $t0, 100
   	mtc0 $t0, $11             	# counting the seconds
	
	la $t1, timerFlag
	li $t2, 1
	sb $t2, 0($t1)			# initialize flag


continuReveal:
	move $a0, $t6
	move $a1, $t7

	addi $sp $sp -8		# storing t reg for function call
	sw $t6 0($sp)
	sw $t7 4($sp)

	jal getReveal

	
	lw $t6 0($sp)
	lw $t7 4($sp)
	addi $sp $sp 8

	la $t8, loseFlag
	lb $t8, 0($t8)
	
	bnez $t8, lose		# lose otherwise do the winning stuff

	la $s3, gameRows
	lw $s3, 0($s3)
	
	la $s4, gameCols
	lw $s4, 0($s4)

	la $s5, totalBombs
	lw $s5, 0($s5)		

	mult $s3, $s4
	mflo $s6	# total number of tiles

	sub $s6, $s6, $s5	# total number of nobomb tiles


	la $t9, revealCount
	lw $t9, 0($t9)

	beq $s6, $t9, win	# if revealcount == total number of no-bomb tiles, win
	
	
	j restore

	
lose:
	li $t0, 0xFFFF7FFF		
	mfc0 $t1, $12			# status reg
	and $t1, $t1, $t0		# disable timer interruption
	mtc0 $t1, $12			# store the changes back to status reg

	la $a0, gameLost
	
	la $t0, gameRows
	lw $a1, 0($t0)

	li $a2, 0

	jal printString
	
	j gameOverRestore

win:
	li $t0, 0xFFFF7FFF		
	mfc0 $t1, $12			# status reg
	and $t1, $t1, $t0		# disable timer interruption
	mtc0 $t1, $12			# store the changes back to status reg

	la $a0, gameWon
	
	la $t0, gameRows
	lw $a1, 0($t0)

	li $a2, 0

	jal printString
	
	j gameOverRestore

quit:
		
	li $v0, 0
	
	j endMain


restart:
	
	la $t8, loseFlag
	sb $zero, 0($t8)	# restore the loseflag

	la $t0, interCheck	# restoring the flag to 0
	sb $zero, 0($t0)

	la $t9, revealCount
	sw $zero, 0($t9)	# restoring reveal count to 0

	la $t7, timerFlag	# restoring timer count to 0
	sw $zero, 0($t7)

	#disable timer inter
	li $t0, 0xFFFF7FFF		
	mfc0 $t1, $12			# status reg
	and $t1, $t1, $t0		# disable timer interruption
	mtc0 $t1, $12			# store the changes back to status reg

	li $v0, 1

	j endMain


restore:
	
	la $t0, interCheck	# restoring the flag to 0
	sb $zero, 0($t0)

	j infiniteLoop


gameOverRestore:
	la $t0, interCheck	# restoring the flag to 0
	sb $zero, 0($t0)


	la $t9, revealCount
	sw $zero, 0($t9)


	j infiniteLoop


infiniteLoop:

	j mainBegin 


timerInfiniteLoop:
	la $t0, interCheck	# restoring the flag to 0
	sb $zero, 0($t0)

	
	j mainBegin

	

endMain:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s7 32($sp)
	addi $sp $sp 36

	jr $ra




####################################################
# s0 = old row value
# s1 = old col value
# t0 = gameRow
# t1 = gameCol

.data
	
	loseFlag: 
		.align 2
		.space 1

	revealCount:
		.align 4
		.space 4

.text
getReveal:
	addi $sp $sp -36
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)


	move $s0, $a0	# current row value
	
	move $s1, $a1	# current  col value

	
	
	la $t0, gameRows
	lw $t0, 0($t0)

	la $t1, gameCols
	lw $t1, 0($t1)

		

	li    $t2, 0

	addi  $t3, $t0, -1			# check for the edges to see if we are in range
        slt   $t2, $t3, $s0
        beq   $t2, 1, doneGetReveal
        slt   $t2, $s0, $zero     
        beq   $t2, 1, doneGetReveal

	addi  $t3, $t1, -1			
        slt   $t2, $t3, $s1
        beq   $t2, 1, doneGetReveal
        slt   $t2, $s1, $zero     
        beq   $t2, 1, doneGetReveal

	
	# s0 rows I have to skip for calculation
	mult $s0, $t1	# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t2
	add $t3, $t2, $s1	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
				
	
	la $t4, gameBoard
	add $t4, $t4, $t3	# add the offset to address = t4
	lb $t5, 0($t4)		# load the content at that tile = t5

	
	##can only reveal the tile that has a number(unrevealClear) or if it's a unrevealbomb, 
	# can't reveal markedBomb or markedClear but can 
	# printTile that tile
	#then go to doneGetReveal


	li $t6, 13
	beq $t5, $t6, changeSymbol	# if tile has value 13(unreveal clear), go change it to 14 for bombcounting
	

	li $t6, 10
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 11
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	

	beqz $t5, doneGetReveal		# go wait for new cursor pos
	
	li $t6, 1
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 2
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 3
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos


	li $t6, 4
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	
	li $t6, 5
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 6
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 7
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos

	li $t6, 8
	beq $t5, $t6, doneGetReveal	# go wait for new cursor pos
	
	
	li $t6, 12
	beq $t5, $t6, showBomb

	

changeSymbol:
	li $t6, 14
	sb $t6, 0($t4)


	move $a0, $s0
	move $a1, $s1


	addi $sp $sp -12
	sw $t4, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)

	jal getTile

	lw $t4, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp $sp 12



	li $t6, 20
	beq $v1, $t6, change0

	li $t6, 21
	beq $v1, $t6, change1	

	li $t6, 22
	beq $v1, $t6, change2

	li $t6, 23
	beq $v1, $t6, change3

	li $t6, 24
	beq $v1, $t6, change4

	li $t6, 25
	beq $v1, $t6, change5

	li $t6, 26
	beq $v1, $t6, change6

	li $t6, 27
	beq $v1, $t6, change7

	li $t6, 28
	beq $v1, $t6, change8


change0:
	sb $zero, 0($t4)	# reveal the current pos and reveal around by calling getNeighbor

	
	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount	# revealed bomb counter
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	### start of the recursion part of the reveal###
        addi  $a0, $s0, -1	#[-1, -1]
        addi  $a1, $s1, -1
        jal   getReveal

        
        addi  $a0, $s0, 0	#[0, -1]
        addi  $a1, $s1, -1
        jal   getReveal

       
        addi  $a0, $s0, 1	 #[+1, -1]
        addi  $a1, $s1, -1
        jal   getReveal

        
        addi  $a0, $s0, -1	#[-1, 0]
        addi  $a1, $s1, 0
        jal   getReveal

       
        addi  $a0, $s0, 1	 #[+1, 0]
        addi  $a1, $s1, 0
        jal   getReveal

        
        addi  $a0, $s0, -1	#[-1, +1]
        addi  $a1, $s1, 1
        jal   getReveal

        
        addi  $a0, $s0, 0	#[0, +1]
        addi  $a1, $s1, 1
        jal   getReveal

       
        addi  $a0, $s0, 1	 #[+1, +1]
        addi  $a1, $s1, 1
        jal   getReveal

	

	j doneGetReveal

change1:
	li $t6, 1
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change2:
	li $t6, 2
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change3:
	li $t6, 3
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change4:
	li $t6, 4
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change5:
	li $t6, 5
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal


change6:
	li $t6, 6
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change7:
	li $t6, 7
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal

change8:
	li $t6, 8
	sb $t6, 0($t4)

	move $a0, $s0	# current row value as arg
	move $a1, $s1	# current  col value as arg

	jal printTile

	la $t0, revealCount
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)

	j doneGetReveal



showBomb:
	li $t6, 9
	sb $t6, 0($t4)		# change it to a revealbomb

	li $t6, 1
	la $t7, loseFlag	# flag to display lose message
	sb $t6, 0($t7)

	j doneGetReveal
	



doneGetReveal:
	
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s7 32($sp)
	addi $sp $sp 36

	jr $ra


#####################################################



####################################################
# check all 8 tiles around given tile( also check if the neighbor tile is out of range)
# 0 - 8 : revealed(no neighboring bomb to all have bomb)
# 9 : revealbomb
# 10: mark bomb
# 11: mark clear
# 12: unreveal bomb
# 13: unreavel clear
# 14: count bomb signal
# 20 -28 : unrevealed with number


# t0 = row#
# t1 = col#
# t2 = max row#
# t3 = max col#
# t4 = content of the tile
# t5 = bomb counter
# t6 = offset for the gameBoard
# s2 = bomb counter
# s6 = rowstart + row off
# s7 = colstart + col off

.text
getTile:
	addi $sp $sp -36
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)
	sw $s4 20($sp)
	sw $s5 24($sp)
	sw $s6 28($sp)
	sw $s7 32($sp)


	move $t0, $a0	# row#
	move $t1, $a1	# col#
	
	la $t2, gameRows
	lw $t2, 0($t2)

	la $t3, gameCols
	lw $t3, 0($t3)
	
	# t0 rows I have to skip for calculation
	mult $t0, $t3	# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t5
	add $t6, $t5, $t1	# add the bits I'm skipping to the the col# to get to the tile I need to check = final offset
				
	
	la $s0, gameBoard
	add $s0, $s0, $t6	# add the offset to address
	lb $t4, 0($s0)		# load the content at that tile
	
	li $s1, 13
	beq $t4, $s1, unrevealClear
	
	li $s1, 12
	beq $t4, $s1, unrevealBomb

	li $s1, 10
	beq $t4, $s1, markBomb

	li $s1, 11
	beq $t4, $s1, markClear

	li $s1, 9
	beq $t4, $s1, revealbomb
	
	li $s1, 14
	beq $t4, $s1, countBomb

	li $s1, 0
	beq $t4, $s1, zero

	li $s1, 1
	beq $t4, $s1, one

	li $s1, 2
	beq $t4, $s1, two

	li $s1, 3
	beq $t4, $s1, three
	
	li $s1, 4
	beq $t4, $s1, four

	li $s1, 5
	beq $t4, $s1, five

	li $s1, 6
	beq $t4, $s1, six

	li $s1, 7
	beq $t4, $s1, seven

	li $s1, 8
	beq $t4, $s1, eight



countBomb:
	li $t5, 0    # bomb counter
	li $t6, -1    # rowoff
	li $t7, -1    # coloff
	li $t9, 1
	li $t8, 2
rowLoop:
	bge $t6, $t8, decide	# if rowoff is more than or equal to 2, finish
	li $t7, -1		# reinitialize coloff
	add $s6, $t0, $t6		# s6 = rowstart + row off 
	blt $s6, $zero, incrementRow	# (rowstart + rowoff < 0) increment
	bge $s6, $t2, incrementRow	# (rowstart + rowoff >= gameRow)

	j colLoop


	colLoop:
		bge $t7, $t8, incrementRow	# if coloff is more than or equal to 2, increment rowLoop
		add $s7, $t1, $t7		# s7 = colstart + col off 
		bne $t6, $zero, continue
		
		beq $t7, $zero, incrementCol	#(xoff == 0 && yoff == 0) increment

		continue:
		blt $s7, $zero, incrementCol	# (colstart + coloff < 0) increment
		bge $s7, $t3, incrementCol	#(colstart + coloff >= gameCol)
		
		move $a0, $s6	#rowstart + row off as arg
		move $a1, $s7	#colstart + col off as arg
		
		addi $sp $sp -16
		sw $t0 0($sp)
		sw $t1 4($sp)
		sw $t2 8($sp)
		sw $t3 12($sp)

		jal hasBomb

		lw $t0 0($sp)
		lw $t1 4($sp)
		lw $t2 8($sp)
		lw $t3 12($sp)
		addi $sp $sp 16
		
		beqz $v0, changeRow	# if no bomb, changeRow

		addi $t5, $t5, 1	# increment bomb counter
		j changeRow		# changeRow

		changeRow:
		beq $t7, $t9, incrementRow
	

	incrementCol:
		addi $t7, $t7, 1
		j colLoop


incrementRow:
	addi $t6, $t6, 1
	j rowLoop


decide:
	
	beqz $t5, twenty
	
	li $s1, 1
	beq $t5, $s1, twenty1

	li $s1, 2
	beq $t5, $s1, twenty2

	li $s1, 3
	beq $t5, $s1, twenty3

	li $s1, 4
	beq $t5, $s1, twenty4

	li $s1, 5
	beq $t5, $s1, twenty5

	li $s1, 6
	beq $t5, $s1, twenty6

	li $s1, 7
	beq $t5, $s1, twenty7

	li $s1, 8
	beq $t5, $s1, twenty8




zero: 
	la $v0, has0
	li $v1, 0
	j doneGetTile

one:
	la $v0, has1
	li $v1, 1
	j doneGetTile

two:
	la $v0, has2
	li $v1, 2
	j doneGetTile

three:
	la $v0, has3
	li $v1, 3
	j doneGetTile

four:
	la $v0, has4
	li $v1, 4
	j doneGetTile
five:
	la $v0, has5
	li $v1, 5
	j doneGetTile

six: 
	la $v0, has6
	li $v1, 6
	j doneGetTile

seven:
	la $v0, has7
	li $v1, 7
	j doneGetTile
eight:
	la $v0, has8
	li $v1, 8
	j doneGetTile
revealbomb:
	la $v0, bomb
	li $v1, 9
	j doneGetTile
markBomb:
	la $v0, marked
	li $v1, 10
	j doneGetTile

markClear:
	la $v0, marked
	li $v1, 11
	j doneGetTile

unrevealBomb:
	la $v0, tile
	li $v1, 12
	j doneGetTile

unrevealClear:
	la $v0, tile
	li $v1, 13
	j doneGetTile


twenty: 
	la $v0, tile
	li $v1, 20
	j doneGetTile

twenty1:
	la $v0, tile
	li $v1, 21
	j doneGetTile

twenty2:
	la $v0, tile
	li $v1, 22
	j doneGetTile

twenty3:
	la $v0, tile
	li $v1, 23
	j doneGetTile

twenty4:
	la $v0, tile
	li $v1, 24
	j doneGetTile
twenty5:
	la $v0, tile
	li $v1, 25
	j doneGetTile

twenty6: 
	la $v0, tile
	li $v1, 26
	j doneGetTile

twenty7:
	la $v0, tile
	li $v1, 27
	j doneGetTile

twenty8:
	la $v0, tile
	li $v1, 28
	j doneGetTile


doneGetTile:
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	lw $s4 20($sp)
	lw $s5 24($sp)
	lw $s6 28($sp)
	lw $s7 32($sp)
	addi $sp $sp 36
		
	jr $ra

	
####################################################
# s0 = total input row#
# s1 = total input col#
# t0 = row#
# t1 = col#
# s2 = the tile I need to check(offset)
.text
hasBomb:
	addi $sp $sp -20
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $s3 16($sp)

	la $s0, gameRows
	lw $s0, 0($s0)		# get the input row

	la $s1, gameCols
	lw $s1, 0($s1)		# get the input col

	move $t0, $a0	# row
	move $t1, $a1	# col
	
	# t0 is rows I have to skip for calculation
	mult $t0, $s1	# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t2
	add $s2, $t2, $t1	# add the bits I m skipping to the the col# to get to the tile I need to check = final offset
				
	
	la $t3, gameBoard
	add $t3, $t3, $s2	# add the offset to address
	lb $t4, 0($t3)		# load the content at that tile

	li $s3, 12
	bne $s3, $t4, noBomb
	li $v0 ,1
	
	j doneHasBomb

noBomb:
	li $v0, 0

doneHasBomb:
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $s3 16($sp)
	addi $sp $sp 20
	
	jr $ra
	

####################################################
# s0 = total input row#
# s1 = total input col#
# t0 = row#
# t1 = col#
# s2 = the tile I need to set
# t4 = 12 for unrevealed bomb

.text
setBomb:
	addi $sp $sp -16
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)

	la $s0, gameRows	# get the input row
	lw $s0, 0($s0)

	la $s1, gameCols	# get the input col
	lw $s1, 0($s1)

	move $t0, $a0	# row
	move $t1, $a1	# col
	
	# t0 rows I have to skip for calculation
	mult $t0, $s1	# multiply total col # with the row # for calculation( how many bits I have to skip to get to row)
	mflo $t2
	add $s2, $t2, $t1	# add the bits I m skipping to the the col# to get to the tile I need to set = final offset
				
	
	la $t3, gameBoard
	add $t3, $t3, $s2	# add the offset to address
	li $t4, 12		# bomb symbol
	sb $t4, 0($t3)		# set that tile to 12 for unrevealbomb

doneSetBomb:
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	addi $sp $sp 16
	
	jr $ra

####################################################
# if I do the check neibouring tile in gettile this is empty 
# s2 = size of gameBoard
# t4 = length counter
.text
prepareBoard:
	addi $sp $sp -16
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)


	la $s0, gameRows
	lw $s0, 0($s0)
        la $s1, gameCols
	lw $s1, 0($s1)
	mult $s0, $s1  
	mflo $s2	# size of gameBoard array

	la $t0, gameBoard

	li $t1, 12
	li $t3, 13
	li $t4, 0	# counter
	
loop:
	beq $t4, $s2, endprepareBoard
	lb $t2, 0($t0)			# load content
	beq $t2, $t1, increment		# if has unreveal bomb, increment
	sb $t3, 0($t0)			# if not, store 13 (unrevealed clear)
	
increment:
	addi $t0, $t0, 1	
	addi $t4, $t4, 1	# size of gameBoard counter
	j loop
	
endprepareBoard:
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	addi $sp $sp 16

	jr $ra



####################################################
# calls for the gettile function to determine the symbol for that given tile
.text
printTile:
	
	addi $sp $sp -12
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)

	move $s0, $a0	# row
	move $s1, $a1	# col
	
	move $a0, $s0	# row as arg
	move $a1, $s1	# col as arg
	
	jal getTile


	move $a0, $v0	# arg a0 = address of the symbol to print
	move $a1, $s0	# arg row for printstring
	move $a2, $s1	# arg col for printstring


	jal printString
	

	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $ra 0($sp)
	addi $sp $sp 12


	jr $ra


































