.global _start

	.equ	LAST_RAM_WORD,	0x007FFFFC
.equ	JTAG_UART_BASE,	0x10001000
.equ	DATA_OFFSET,	0
.equ	STATUS_OFFSET,	4
.equ	WSPACE_MASK,	0xFFFF
.equ	SPACE_MASK,		0x8000

.text
.global _start
.org	0x00000000

_start:
	movia 	r2, MSG6
    call 	PrintString
	call 	GetDecimal99
	mov 	r3, r2
	movia	r2,' '
	call 	PrintChar
	call 	GetDecimal99
	mov 	r4, r2
	movia	r2, '='
	call 	PrintChar
	call 	Max
	call	PrintDecimal99
	
    
_end:
br _end
# returns biggest in R2, A is in r3 and B is in r4 
Max:
	mov r2,r3	# move one into r2
    blt r4,r3, Max_End	#if the other one is smaller, then we return this one 
    mov r2,r4			#otherwise the other one goes into r2 
Max_End:
	ret					#return






GetChar:
	subi	sp, sp, 8
	stw 	r3, 4(sp)
	stw 	r4, 0(sp)
	movia	r3, JTAG_UART_BASE
gc_loop:
	ldwio 	r2, DATA_OFFSET(r3)
	andi	r4, r2, SPACE_MASK
	beq 	r4, r0, gc_loop
gc_endloop:
	andi 	r2, r2, 0xFF
	ldw 	r4, 0(sp)
	ldw 	r3, 4(sp)
	addi	sp, sp, 8
	ret

GetDecimal99:
	subi 	sp, sp, 16 
	stw 	ra, 12(sp)
	stw 	r3, 8(sp)
	stw 	r4, 4(sp)
	stw 	r5, 0(sp)

	mov		r3, r0

gd_loopone:

	call	GetChar						# Desiered value will be stored in r2 in GetChar.
	movia	r5, '0'
	blt		r2, r5, gd_loopone 	
	movia	r5, '9'
	bgt		r2, r5, gd_loopone	
gd_endloopone:
	call	PrintChar					# Character to be printed will already be in register r2
	subi	r3, r2, '0'
	muli	r3, r3, 10
gd_looptwo:
	call	GetChar						# Desiered value will be stored in r2 in GetChar.
	movia	r5, '0'
	blt		r2, r5, gd_looptwo 
	movia	r5, '9' 	
	bgt		r2, r5, gd_loopone		
gd_endlooptwo:
	call	PrintChar					# Character to be printed will already be in register r2
	subi	r4, r2, '0'
	add 	r2, r3, r4
	ldw 	r5, 0(sp)
	ldw 	r4, 4(sp)
	ldw 	r3, 8(sp)
	ldw 	ra, 12(sp)
	addi	sp, sp, 16
	ret

PrintDecimal99:
	subi 	sp, sp, 16 
	stw 	ra, 12(sp)
	stw 	r3, 8(sp)
	stw 	r4, 4(sp)
	stw 	r5, 0(sp)

	movi 	r4, 10
	div		r3, r2, r4	 				
	muli 	r4, r3, 10
	sub 	r5, r2, r4 
	addi	r2, r3, '0'
	call	PrintChar
	addi	r2, r5, '0'
	call	PrintChar

	ldw 	r5, 0(sp)
	ldw 	r4, 4(sp)
	ldw 	r3, 8(sp)
	ldw 	ra, 12(sp)
	addi	sp, sp, 16
	ret
    
PrintChar:
    subi sp, sp, 8
    stw r3, 4(sp)
    stw r4, 0(sp)
    movia r3, JTAG_UART_BASE
pc_loop:
    ldwio r4, STATUS_OFFSET(r3)
    andhi r4, r4, WSPACE_MASK
    beq r4, r0, pc_loop
    stwio r2, DATA_OFFSET(r3)
    ldw r3, 4(sp)
    ldw r4, 0(sp)
    addi sp, sp, 8
    ret
    
PrintString:
    subi sp, sp, 12
    stw ra, 8(sp)
    stw r3, 4(sp)
    stw r2, 0(sp)
    mov r3, r2
ps_loop:
    ldb r2, 0(r3)
    beq r2, r0, end_ps_loop
    call PrintChar
    addi r3, r3, 1
    br ps_loop
end_ps_loop:
    ldw ra, 8(sp)
    ldw r3, 4(sp)
    ldw r2, 0(sp)
    addi sp, sp, 12
    ret
   
PrintHexDigit:
    subi sp, sp, 16
    stw ra, 12(sp)
    stw r3, 8(sp)
    stw r2, 4(sp)
    stw r4, 0(sp)
    movi r4, 9
IF:
    bgt r2, r4, ELSE
THEN:
    addi r2, r2, '0'
    br END_IF
ELSE:
    subi r2, r2, 10
    addi r2, r2, 'A'
END_IF:
    call PrintChar
    ldw ra, 12(sp)
    ldw r3, 8(sp)
    ldw r2, 4(sp)
    ldw r4, 0(sp)
    addi sp, sp, 16
    ret
    
PrintHexList:
    subi sp, sp, 16
    stw ra, 12(sp)
    stw r6, 8(sp)
    stw r5, 4(sp)
    stw r3, 0(sp)
    mov r3,r2
psh_loop:
    beq r5, r0, end_psh_loop
    ldw r2,0(r3)
    call PrintHexDigit
    subi r5, r5, 1
    addi r3, r3, 4
    movia r2, ','
    call PrintChar
    br psh_loop
end_psh_loop:
    ldw ra, 12(sp)
    ldw r6, 8(sp)
    ldw r5, 4(sp)
    ldw r3, 0(sp)
    addi sp, sp, 16
    ret
	
CountOdd:
    subi sp, sp, 20
    stw ra, 16(sp)
    stw r6, 12(sp)
    stw r5, 8(sp)
    stw r7, 4(sp)
    stw r3, 0(sp)
    mov r3,r2
pshc_loop:
    beq r5, r0, end_pshc_loop
    ldw r2, 0(r3)
    andi r7, r2, 1
    add r6, r6, r7
    subi r5, r5, 1
    addi r3, r3, 4
    br pshc_loop
end_pshc_loop:
    mov r2, r6
    call PrintHexDigit
    ldw ra, 16(sp)
    ldw r6, 12(sp)
    ldw r5, 8(sp)
    ldw r7, 4(sp)
    ldw r3, 0(sp)
    addi sp, sp, 20
    ret
	
DoubleList:
   	subi sp, sp, 16
    stw ra, 12(sp)
   	stw r5, 8(sp)
	stw r3, 4(sp)
	stw r2, 0(sp)
	mov r3,r2
pshca_loop:
   	beq r5, r0, end_pshca_loop
	ldw r2, 0(r3)
	muli r2, r2, 2
	stw r2, 0(r3)
	subi r5, r5, 1
   	addi r3, r3, 4
	br pshca_loop
end_pshca_loop:
    ldw ra, 12(sp)
   	ldw r5, 8(sp)
	ldw r3, 4(sp)
	ldw r2, 0(sp)
    addi sp, sp, 16
    ret
 
	.org	0x1000
        
# place word-sized data first to maintain word alignemnt
	LIST: .word 1, 10, 2, 12, 3, 13
	N: .word 6
# place byte sized data and strings after word sized data

    	MSG1: .asciz "ELEC274 Lab2\n"
        MSG2: .asciz "ELEC274 Lab3\n"
        MSG3: .asciz "Type two decimal digits:"
		MSG4: .asciz "You typed: "
		MSG5: .asciz "Sum of two values\n"
        MSG6: .asciz "Enter two numbers, will print the larger of the two\n"
    .end
