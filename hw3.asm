######### Kevin Tao ##########
######### 170154879 ##########
######### ktao ##########

######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########

.text
.globl initialize
initialize: #a0 = filename, a1 = buffer
	addi $sp $sp -20                               # Allocate space on stack
	sw $s0 4($sp)                                  # Save s0 on stack
	sw $s1 8($sp)                                  # Save s1 on stack
	sw $s2 12($sp)                                 # Save s2 on stack
	sw $s3 16($sp)                                 # Save s3 on stack
	move $s0 $a0                                   # Saves filename 
	move $s1 $a1                                   # Saves buffer pointer
	move $a2 $0                                    # Ignored arg
	move $a1 $0                                    # Mode: read
	li $v0 13
	syscall                                        # Syscall 13 to open file
	move $s2 $v0                                   # Saves file descriptor
	move $a0 $s2                            	   # Arg1: Descriptor
	move $a1 $sp                                   # Arg2: Stack
	li $a2 1                            	       # Arg3: Num Chars to Read
	li $s3 2                                       # Loop counter for first
	initloop:
		beqz $s3 initloop2
		li $v0 14                           	       # Read file
		syscall	
		lbu $t2 0($sp)                                  # Load char from stack
		li $t0 0x0A                         	       # LF
		beq $t2 $t0 initloop	
		li $t0 0x0D         	                       # CR
		beq $t2 $t0 initloop
		li $t0 '1'
		slt $t1 $t2 $t0
		bnez $t1 initerror                             # Checks for valid character
		li $t0 '9'
		slt $t1 $t0 $t2
		bnez $t1 initerror
		addi $s3 $s3 -1
		j initloop
	initloop2:
		li $v0 14                           	       # Read file
		syscall	
		beqz $v0 exitinit 
		lbu $t2 0($sp)                                  # Load char from stack
		li $t0 0x0A                         	       # LF
		beq $t2 $t0 initloop2	
		li $t0 0x0D         	                       # CR
		beq $t2 $t0 initloop2
		li $t0 '0'
		slt $t1 $t2 $t0
		bnez $t1 initerror                             # Checks for valid character
		li $t0 '9'
		slt $t1 $t0 $t2
		bnez $t1 initerror
		j initloop2
	
	exitinit:
		move $a0 $s2
		li $v0 16
		syscall
		move $a0 $s0
		move $a2 $0                                    # Ignored arg
		move $a1 $0                                    # Mode: read
		li $v0 13
		syscall 
		move $a0 $s2                            	   # Arg1: Descriptor
		move $a1 $sp                                   # Arg2: Stack
		li $a2 1                            	       # Arg3: Num Chars to Read
	
	initloop3:
		li $v0 14                           	       # Read file
		syscall	
		beqz $v0 exitinit2 
		lbu $t2 0($sp)                                  # Load char from stack
		li $t0 0x0A                         	       # LF
		beq $t2 $t0 initloop3	
		li $t0 0x0D         	                       # CR
		beq $t2 $t0 initloop3
		lbu $t3 0($sp)                                  # Loads char from stack into s3
		addi $t3 $t3 -48                               # Converts to usable number
		sb $t3 0($s1)                                  # Saves s3 char into Buffer
		addi $s1 $s1 4                                 # Increment Buffer Pointer
		j initloop3
	
	exitinit2:
		move $a0 $s2
		li $v0 16
		syscall
		lw $s0 4($sp)                                  # Load s0 on stack
		lw $s1 8($sp)                                  # Load s1 on stack
		lw $s2 12($sp)                                 # Load s2 on stack
		lw $s3 16($sp)                                 # Load s3 on stack
		addi $sp $sp 20                                # DeAllocate space on stack
		li $v0 1
		jr $ra
	
	initerror:
		move $a0 $s2
		li $v0 16
		syscall
		lw $s0 4($sp)                                  # Load s0 on stack
		lw $s1 8($sp)                                  # Load s1 on stack
		lw $s2 12($sp)                                 # Load s2 on stack
		lw $s3 16($sp)                                 # Load s3 on stack
		addi $sp $sp 20                                # DeAllocate space on stack
		li $v0 -1
 		jr $ra

.globl write_file
write_file: #a0: filename, a1: buffer
	addi $sp $sp -24                                # Allocate space on stack
	sw $s0 4($sp)                                  # Save s0 on stack
	sw $s1 8($sp)                                  # Save s1 on stack
	sw $s2 12($sp)                                 # Save s2 on stack
	sw $s3 16($sp)                                 # Save s3 on stack
	sw $s4 20($sp)                                 # Save s3 on stack
	move $s2 $a1                                   # Preserves a1 buffer address
	move $s3 $a0                                   # Preserves a0 filename
	move $a2 $0                                    # Ignored arg
	li $a1 1                                       # Mode: write
	li $v0 13
	syscall    
	move $s1 $v0                                   # Saves string descriptor into s1
	move $a1 $s2                                   # Restores a1 buffer address
	
	lbu $t1 0($s2)                                  # Loads first number
	move $s4 $t1                                   # Number of Rows save into $s4
	addi $t1 $t1 48                                # Converts to ascii
	sb $t1 0($sp)                                   # Temporarily saves char onto stack
	move $a0 $s1
	move $a1 $sp
	li $a2 1
	li $v0 15
	syscall                                        # Writes char into file.
	li $t0 0x0A                                    # newline
	sb $t0 0($sp)                                  # Saves newline as temp buffer
	li $v0 15
	syscall                                        # Writes char into file.
	addi $s2 $s2 4                                 # Increment buffer pointer
	#######################
	lbu $t1 0($s2)                                  # Loads second number
	move $s0 $t1                                   # Number of Columns save into $s0
	addi $t1 $t1 48                                # Converts to ascii
	sb $t1 0($sp)                                  # Temporarily saves char onto stack
	move $a0 $s1
	move $a1 $sp
	li $a2 1
	li $v0 15
	syscall                                        # Writes char into file.
	addi $s2 $s2 4                                 # Increment buffer pointer
	move $t3 $s0                                   # Makes a copy of column counter
	
	writeloop:
		beqz $s4 endwrite
		li $t0 0x0A                                    # newline
		sb $t0 0($sp)                                  # Saves newline as temp buffer
		li $v0 15
		syscall                                        # Writes char into file.
		columnloop:
			beqz $t3 endcolumns
			lbu $t1 0($s2)                                  # Loads number from buffer
			addi $t1 $t1 48                                # Converts to ascii
			sb $t1 0($sp)                                  # Temporarily saves char onto stack
			move $a0 $s1
			move $a1 $sp
			li $a2 1
			li $v0 15
			syscall                                        # Writes char into file.
			addi $s2 $s2 4                                 # Increment buffer pointer 
			addi $t3 $t3 -1
			j columnloop
		endcolumns:
			addi $s4 $s4 -1                                # Decrement row counter
			move $t3 $s0                                   # Reset column counter
			j writeloop
	
	endwrite:
		move $a0 $s1
		li $v0 16
		syscall
		lw $s0 4($sp)                                  # Load s0 on stack
		lw $s1 8($sp)                                  # Load s1 on stack
		lw $s2 12($sp)                                 # Load s2 on stack
		lw $s3 16($sp)                                 # Load s3 on stack
		lw $s4 20($sp)                                 # Load s3 on stack
		addi $sp $sp 24                                # DeAllocate space on stack
		jr $ra
	

.globl rotate_clkws_90
rotate_clkws_90: #a0: buffer, a1: filename | Transpose, then reverse rows
	addi $sp $sp -24                               # Allocate space on stack
	sw $ra 0($sp)                                  # save return addr on stack
	sw $s0 4($sp)                                  # Save s0 on stack
	sw $s1 8($sp)                                  # Save s1 on stack
	sw $s2 12($sp)                                 # Save s2 on stack
	sw $s3 16($sp)                                 # Save s3 on stack
	sw $s4 20($sp)                                 # Save s3 on stack
	move $s0 $a0                                   # Make a copy of buffer pointer
	lbu $s2 0($s0)                                  # s2 = rows => new columns
	lbu $s3 4($s0)                                  # s3 = columns => new rows
	addi $s0 $s0 8
	mul $t2 $s2 $s3                                # Get total needed space, t2 = buffer space
	addi $t0 $t2 2                                 # +2 for row/col ints
	li $t1 4
	mul $t0 $t0 $t1                                # x4 for words
	sub $sp $sp $t0                                # Allocate stack space for buffer copy
	sb $s3 0($sp)
	sb $s2 4($sp)
	addi $sp $sp 8
	li $t3 0                                       # Buffer pointer counter (Tracks index)
	transposeloop:
		# Divide index by row length (num of cols) to get row index of value
		# Modulo index by row length (num of cols) to get col index.
		# Swap row/col to get new location, and decode into index = row*(numcols)+col
		beqz $t2 transposeend
		lbu $t5 0($s0)                  # Load object in buffer
		div $t3 $s3                    # Get row index
		mflo $t8                       # Store in t8 = ROW => new COL
		mfhi $t9                       # Store in t9 = COL => new ROW
		mul $t4 $t9 $s2                # row*numcols
		add $t4 $t4 $t8                # +col
		mul $t4 $t4 $t1
		add $t6 $t4 $sp                # go to index in stack
		sb $t5 0($t6)                  # Save into stack
		addi $s0 $s0 4                 # Increment buffer pointer
		addi $t3 $t3 1                 # Increment index counter
		addi $t2 $t2 -1
		j transposeloop
	
	transposeend:
		move $t2 $sp                    # Copy of base pointer
		
	mirrorloop:
		beqz $s3 mirrordone
		move $t8 $t2                    # t8 = first int of row
		mul $t6 $s2 $t1                 # x4
		add $t9 $t2 $t6                 # t9 = last int of row + 1
		addi $t9 $t9 -4                 # last int of row
		mirrorinner:
			beq $t8 $t9 innerdone
			blt $t9 $t8 innerdone
			lbu $s1 0($t8)               # s1 = lower int
			lbu $s4 0($t9)               # s4 = higher int
			move $t4 $s1
			move $s1 $s4                # Swap values
			move $s4 $t4
			sb $s1 0($t8)               # reload values back into stack
			sb $s4 0($t9)               #
			addi $t8 $t8 4
			addi $t9 $t9 -4
			j mirrorinner
		innerdone:	
			add $t2 $t2 $t6                 # Jump to next row
			addi $s3 $s3 -1                 # Decrement rows remaining counter
			j mirrorloop		
	mirrordone:
		addi $sp $sp -8
		move $s0 $t0
		move $a0 $a1
		move $a1 $sp
		jal write_file
		move $t0 $s0
		add $sp $sp $t0                      # Deallocate stack
		lw $ra 0($sp)                                  # load return addr on stack
		lw $s0 4($sp)                                  # load s0 on stack
		lw $s1 8($sp)                                  # load s1 on stack
		lw $s2 12($sp)                                 # load s2 on stack
		lw $s3 16($sp)                                 # load s3 on stack
		lw $s4 20($sp)                                 # load s3 on stack
		addi $sp $sp 24
		jr $ra

.globl rotate_clkws_180
rotate_clkws_180: #a0 = buffer, a1 = output filename
	addi $sp $sp -16                          # Allocate stack
	sw $ra 0($sp)                            # Save ra on stack
	sw $s0 4($sp)                            # Save ra on stack
	sw $s1 8($sp)                            # Save ra on stack
	sw $s2 12($sp)                            # Save ra on stack
	move $s0 $a0
	move $s1 $a1
	jal rotate_clkws_90
	move $a1 $s0 
	move $a0 $s1
	jal initialize
	move $a0 $s0 
	move $a1 $s1
	jal rotate_clkws_90
	lw $ra 0($sp)                            # Load ra on stack
	lw $s0 4($sp)                            # Load ra on stack
	lw $s1 8($sp)                            # Load ra on stack
	lw $s2 12($sp)                            # Load ra on stack
	addi $sp $sp 16                          # DeAllocate stack
 	jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
	addi $sp $sp -16                          # Allocate stack
	sw $ra 0($sp)                            # Save ra on stack
	sw $s0 4($sp)                            # Save ra on stack
	sw $s1 8($sp)                            # Save ra on stack
	sw $s2 12($sp)                            # Save ra on stack
	move $s0 $a0
	move $s1 $a1
	jal rotate_clkws_90
	move $a1 $s0 
	move $a0 $s1
	jal initialize
	move $a0 $s0 
	move $a1 $s1
	jal rotate_clkws_90
	move $a1 $s0 
	move $a0 $s1
	jal initialize
	move $a0 $s0 
	move $a1 $s1
	jal rotate_clkws_90
	lw $ra 0($sp)                            # Load ra on stack
	lw $s0 4($sp)                            # Load ra on stack
	lw $s1 8($sp)                            # Load ra on stack
	lw $s2 12($sp)                            # Load ra on stack
	addi $sp $sp 16                          # DeAllocate stack
 	jr $ra
 jr $ra

.globl mirror
mirror:
	addi $sp $sp -24                               # Allocate space on stack
	sw $ra 0($sp)                                  # save return addr on stack
	sw $s0 4($sp)                                  # Save s0 on stack
	sw $s1 8($sp)                                  # Save s1 on stack
	sw $s2 12($sp)                                 # Save s2 on stack
	sw $s3 16($sp)                                 # Save s3 on stack
	sw $s4 20($sp)                                 # Save s3 on stack
	move $s0 $a0                                   # Make a copy of buffer pointer
	lbu $s2 0($s0)                                  # s2 = rows
	lbu $s3 4($s0)                                  # s3 = columns
	addi $s0 $s0 8
	mul $t2 $s2 $s3                                # Get total needed space, t2 = buffer space
	addi $t0 $t2 2                                 # +2 for row/col ints
	li $t1 4
	mul $t0 $t0 $t1                                # x4 for words
	sub $sp $sp $t0                                # Allocate stack space for buffer copy
	sb $s2 0($sp)
	sb $s3 4($sp)
	addi $sp $sp 8
	li $t3 0                                       # Buffer pointer counter (Tracks index)
	copyloop:
		beqz $t2 copyend
		lbu $t5 0($s0)                  # Load object in buffer
		div $t3 $s3                    # Get row index
		mflo $t8                       # Store in t8 = ROW
		mfhi $t9                       # Store in t9 = COL
		mul $t4 $t8 $s3                # row*numcols
		add $t4 $t4 $t9                # +col
		mul $t4 $t4 $t1
		add $t6 $t4 $sp                # go to index in stack
		sb $t5 0($t6)                  # Save into stack
		addi $s0 $s0 4                 # Increment buffer pointer
		addi $t3 $t3 1                 # Increment index counter
		addi $t2 $t2 -1
		j copyloop
	
	copyend:
		move $t2 $sp                    # Copy of base pointer
		
	mmirrorloop:
		beqz $s2 mmirrordone
		move $t8 $t2                    # t8 = first int of row
		mul $t6 $s3 $t1                 # x4
		add $t9 $t2 $t6                 # t9 = last int of row + 1
		addi $t9 $t9 -4                 # last int of row
		mmirrorinner:
			beq $t8 $t9 minnerdone
			blt $t9 $t8 minnerdone
			lbu $s1 0($t8)               # s1 = lower int
			lbu $s4 0($t9)               # s4 = higher int
			move $t4 $s1
			move $s1 $s4                # Swap values
			move $s4 $t4
			sb $s1 0($t8)               # reload values back into stack
			sb $s4 0($t9)               #
			addi $t8 $t8 4
			addi $t9 $t9 -4
			j mmirrorinner
		minnerdone:	
			add $t2 $t2 $t6                 # Jump to next row
			addi $s2 $s2 -1                 # Decrement rows remaining counter
			j mmirrorloop		
	mmirrordone:
		addi $sp $sp -8
		move $s0 $t0
		move $a0 $a1
		move $a1 $sp
		jal write_file
		move $t0 $s0
		add $sp $sp $t0                      # Deallocate stack
		lw $ra 0($sp)                                  # load return addr on stack
		lw $s0 4($sp)                                  # load s0 on stack
		lw $s1 8($sp)                                  # load s1 on stack
		lw $s2 12($sp)                                 # load s2 on stack
		lw $s3 16($sp)                                 # load s3 on stack
		lw $s4 20($sp)                                 # load s3 on stack
		addi $sp $sp 24
		jr $ra

.globl duplicate
duplicate: #a0 = buffer pointer
	addi $sp $sp -20                               # Allocate space on stack
	sw $s0 0($sp)                                  # Save s0 on stack
	sw $s1 4($sp)                                  # Save s1 on stack
	sw $s2 8($sp)                                  # Save s2 on stack
	sw $s3 12($sp)                                 # Save s3 on stack
	sw $s4 16($sp)                                 # Save s4 on stack
	move $s0 $a0                                   # Make copy of buffer pointer
	lw $s1 0($a0)                                  # $s1 = num rows
	lw $s2 4($a0)                                  # $s2 = num cols
	addi $s0 $s0 8
	li $t1 4
	mul $t0 $t1 $s1
	sub $sp $sp $t0                                # Allocate more space on stack
	move $t8 $s1                                   # Copy of rows
	move $t9 $s2                                   # Copy of cols
	li $t2 1                                       # t2 = binary multiplier
	addi $t9 $t9 -1
	twomultloop:
		beqz $t9 twomultend
		li $t3 2
		mul $t2 $t2 $t3                            # Multiplies by two for each digit
		addi $t9 $t9 -1
		j twomultloop
	twomultend:
		move $t9 $s2
		move $s4 $t2
		li $s3 0
		li $t7 0
	duploop1: # Rows
		beqz $t8 endduploop1
		duploop2: # Cols
			beqz $t9 endduploop2
			lw $t3 0($s0)        #Load first num
			mul $t3 $t3 $t2      # Mult by binary multiplier
			add $s3 $s3 $t3      # Add it to final
			li $t4 2
			div $t2 $t4          # Divide binary mult by 2
			mflo $t2
			addi $t9 $t9 -1      # Decrement columns remaining
			addi $s0 $s0 4       # Increase buffer pointer
			j duploop2
		endduploop2:
			addi $t8 $t8 -1      # Decrement rows remaining
			add $t6 $t7 $sp      # Adjust where to store number
			sw $s3 0($t6)        # Store binary converted to decimal into the stack
			addi $t7 $t7 4       # Next stack addr
			li $s3 0             # Reset final number
			move $t2 $s4         # Reset binary multiplier
			move $t9 $s2         # Reset columns remaining
			j duploop1
	endduploop1:
		li $t8 0              # Row/Col counters
		li $t7 1              # Row in stack index counter
		move $t5 $sp
		addi $t5 $t5 4
		move $s0 $sp
		li $t2 0
	duploop3: # Matches rows
		beq $t8 $s1 endduploop3
		lw $t4 0($t5)         # Current value
		addi $t1 $t7 -1       # Get number of rows needed to check
		move $t2 $sp
		
		duploop4: # Iterates through previous rows
			beqz $t1 endduploop4
			lw $t3 0($t2)       # Load num
			beq $t3 $t4 dupfound
			addi $t1 $t1 -1       # Decrement rows remaining
			addi $t2 $t2 4        # Increment stack pointer
			j duploop4
			
		endduploop4:
			addi $t8 $t8 1    #Increment row counter
			addi $t7 $t7 1    # Increment row index counter
			addi $t5 $t5 4   # Increment row multiplier
			j duploop3
	
	endduploop3:
		add $sp $sp $t0
		lw $s0 0($sp)                                  # Load s0 on stack
		lw $s1 4($sp)                                  # Load s1 on stack
		lw $s2 8($sp)                                  # Load s2 on stack
		lw $s3 12($sp)                                 # Load s3 on stack
		lw $s4 16($sp)                                 # Load s4 on stack
		addi $sp $sp 20                               # DeAllocate space on stack
		li $v0 -1
		li $v1 0
		jr $ra
	dupfound:
		add $sp $sp $t0
		lw $s0 0($sp)                                  # Load s0 on stack
		lw $s1 4($sp)                                  # Load s1 on stack
		lw $s2 8($sp)                                  # Load s2 on stack
		lw $s3 12($sp)                                 # Load s3 on stack
		lw $s4 16($sp)                                 # Load s4 on stack
		addi $sp $sp 20                               # DeAllocate space on stack
		addi $t7 $t7 1
		move $v1 $t7
		li $v0 1
		jr $ra
