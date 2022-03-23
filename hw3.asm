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
		lw $t2 0($sp)                                  # Load char from stack
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
		lw $t2 0($sp)                                  # Load char from stack
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
		lw $t2 0($sp)                                  # Load char from stack
		li $t0 0x0A                         	       # LF
		beq $t2 $t0 initloop3	
		li $t0 0x0D         	                       # CR
		beq $t2 $t0 initloop3
		lw $t3 0($sp)                                  # Loads char from stack into s3
		addi $t3 $t3 -48                               # Converts to usable number
		sw $t3 0($s1)                                  # Saves s3 char into Buffer
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
	
	lw $t1 0($s2)                                  # Loads first number
	move $s4 $t1                                   # Number of Rows save into $s4
	addi $t1 $t1 48                                # Converts to ascii
	sw $t1 0($sp)                                   # Temporarily saves char onto stack
	move $a0 $s1
	move $a1 $sp
	li $a2 1
	li $v0 15
	syscall                                        # Writes char into file.
	li $t0 0x0A                                    # newline
	sw $t0 0($sp)                                  # Saves newline as temp buffer
	li $v0 15
	syscall                                        # Writes char into file.
	addi $s2 $s2 4                                 # Increment buffer pointer
	#######################
	lw $t1 0($s2)                                  # Loads second number
	move $s0 $t1                                   # Number of Columns save into $s0
	addi $t1 $t1 48                                # Converts to ascii
	sw $t1 0($sp)                                  # Temporarily saves char onto stack
	move $a0 $s1
	move $a1 $sp
	li $a2 1
	li $v0 15
	syscall                                        # Writes char into file.
	addi $s2 $s2 4                                 # Increment buffer pointer
	move $t3 $s0                                   # Makes a copy of column counter
	
	writeloop: #Writeloop
		beqz $s4 endwrite
		li $t0 0x0A                                    # newline
		sw $t0 0($sp)                                  # Saves newline as temp buffer
		li $v0 15
		syscall                                        # Writes char into file.
		columnloop: #Columnloop
			beqz $t3 endcolumns
			lw $t1 0($s2)                                  # Loads number from buffer
			addi $t1 $t1 48                                # Converts to ascii
			sw $t1 0($sp)                                  # Temporarily saves char onto stack
			move $a0 $s1
			move $a1 $sp
			li $a2 1
			li $v0 15
			syscall                                        # Writes char into file.
			addi $s2 $s2 4                                 # Increment buffer pointer 
			addi $t3 $t3 -1
			j columnloop
		endcolumns: #Endcolumns
			addi $s4 $s4 -1                                # Decrement row counter
			move $t3 $s0                                   # Reset column counter
			j writeloop
	
	endwrite: #Endwrite
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
rotate_clkws_90:
 jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
 jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
 jr $ra

.globl mirror
mirror:
 jr $ra

.globl duplicate
duplicate:
 jr $ra
