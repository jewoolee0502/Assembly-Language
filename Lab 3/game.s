.global _start

.equ BACKGROUND_COLOR, 0x0
.equ GRID_COLOR, 0xf000

.equ GRID_SIZE, 207
.equ LINE_THICKNESS, 5
.equ BOX_SIZE, 64

.equ PLAYER_SIZE, 55
.equ PLAYER_COLOR, 0xffff
.equ PLAYER_THICKNESS, 3

.equ PIXEL_BUFFER_MEMORY, 0xc8000000
.equ CHAR_BUFFER_MEMORY, 0xc9000000
.equ PS2_MEMORY, 0xff200100

_start:
	PUSH {LR}
	BL VGA_fill_ASM
	BL draw_grid_ASM
	
	MOV R0, #1
	BL Player_turn_ASM
	bl result_ASM
	
	mov r0, #62
	mov r1, #20
	//bl draw_plus_ASM
	bl draw_square_ASM
	
	bl clear
	
	mov r0, #0
	bl Player_turn_ASM
	bl result_ASM
	
	mov r0, #62
	mov r1, #90
	bl draw_plus_ASM
	POP {LR}

end: b end
	
clear:
	PUSH {LR}
	BL VGA_fill_ASM
	POP {LR}
	
	PUSH {LR}
	BL draw_grid_ASM
	POP {LR}

result_ASM:
	PUSH {R0-R3, LR}
	MOV R3, R0	//copying the input (0 or 1)
	MOV R1, #58	//y-position
	
	CMP R0, #0
	
	//draw
	MOVLT R0, #38
	MOVLT R2, #68
	BLLT VGA_write_char_ASM
	MOVLT R0, #39
	MOVLT R2, #82
	BLLT VGA_write_char_ASM
	MOVLT R0, #40
	MOVLT R2, #65
	BLLT VGA_write_char_ASM
	MOVLT R0, #41
	MOVLT R2, #87
	BLLT VGA_write_char_ASM
	BLT result_end
	
	//player-1/2 wins
	MOV R0, #33
	MOV R2, #80
	BL VGA_write_char_ASM
	MOV R0, #34
	MOV R2, #76
	BL VGA_write_char_ASM
	MOV R0, #35
	MOV R2, #65
	BL VGA_write_char_ASM
	MOV R0, #36
	MOV R2, #89
	BL VGA_write_char_ASM
	MOV R0, #37
	MOV R2, #69
	BL VGA_write_char_ASM
	MOV R0, #38
	MOV R2, #82
	BL VGA_write_char_ASM
	MOV R0, #39
	MOV R2, #45
	BL VGA_write_char_ASM
	MOV R0, #40
	ADD R2, R3, #49
	BL VGA_write_char_ASM
	
	MOV R0, #41
	MOV R2, #32
	BL VGA_write_char_ASM
	
	MOV R0, #42
	MOV R2, #87
	BL VGA_write_char_ASM
	MOV R0, #43
	MOV R2, #73
	BL VGA_write_char_ASM
	MOV R0, #44
	MOV R2, #78
	BL VGA_write_char_ASM
	MOV R0, #45
	MOV R2, #83
	BL VGA_write_char_ASM
	
	B result_end

	result_end:
		POP {R0-R3, LR}
		BX LR

Player_turn_ASM:
	PUSH {R0-R2, LR}
	MOV R1, #3	//y-position
	
	CMP R0, #0
	BEQ Player1_turn
	B Player2_turn
	
	Player1_turn:
		MOV R0, #36	//x-position
		MOV R2, #80
		BL VGA_write_char_ASM
		MOV R0, #37
		MOV R2, #76
		BL VGA_write_char_ASM
		MOV R0, #38
		MOV R2, #65
		BL VGA_write_char_ASM
		MOV R0, #39
		MOV R2, #89
		BL VGA_write_char_ASM
		MOV R0, #40
		MOV R2, #69
		BL VGA_write_char_ASM
		MOV R0, #41
		MOV R2, #82
		BL VGA_write_char_ASM
		MOV R0, #42
		MOV R2, #45
		BL VGA_write_char_ASM
		MOV R0, #43
		MOV R2, #49
		BL VGA_write_char_ASM
		B Player_turn_end
	
	Player2_turn:
		MOV R0, #36	//x-position
		MOV R2, #80
		BL VGA_write_char_ASM
		MOV R0, #37
		MOV R2, #76
		BL VGA_write_char_ASM
		MOV R0, #38
		MOV R2, #65
		BL VGA_write_char_ASM
		MOV R0, #39
		MOV R2, #89
		BL VGA_write_char_ASM
		MOV R0, #40
		MOV R2, #69
		BL VGA_write_char_ASM
		MOV R0, #41
		MOV R2, #82
		BL VGA_write_char_ASM
		MOV R0, #42
		MOV R2, #45
		BL VGA_write_char_ASM
		MOV R0, #43
		MOV R2, #50
		BL VGA_write_char_ASM
		B Player_turn_end
	
	Player_turn_end:
		POP {R0-R2, LR}
		BX LR

draw_plus_ASM:
	PUSH {R0-R5, LR}
	LDR R3, =PLAYER_COLOR
	PUSH {R3}
	
	MOV R4, R0	//copy x position
	MOV R5, R1	//copy y position
	
	LDR R3, =PLAYER_SIZE
	LDR R2, =PLAYER_THICKNESS
	MOV R1, R5	//y
	ADD R0, R4, #27	//x
	BL draw_rectangle	//plus vertical
	
	LDR R3, =PLAYER_THICKNESS
	LDR R2, =PLAYER_SIZE
	ADD R1, R5, #27	//y
	MOV R0, R4	//x
	BL draw_rectangle	//plus horizontal
	
	POP {R3}
	POP {R0-R5, LR}
	BX LR
	
draw_square_ASM:
	PUSH {R0-R7, LR}
	LDR R3, =PLAYER_COLOR
	PUSH {R3}
	
	MOV R6, R0	//copy x-position
	MOV R7, R1	//copy y-position
	
	LDR R3, =PLAYER_SIZE		//height
	LDR R2, =PLAYER_THICKNESS	//width
	MOV R1, R7	//y
	MOV R0, R6	//x
	BL draw_rectangle	//left wall
	
	LDR R3, =PLAYER_THICKNESS	//height
	LDR R2, =PLAYER_SIZE		//width
	MOV R1, R7	//y
	MOV R0, R6	//x
	BL draw_rectangle	//top wall
	
	LDR R3, =PLAYER_SIZE		//height
	LDR R2, =PLAYER_THICKNESS	//width
	MOV R1, R7	//y
	SUB R4, R3, R2
	ADD R0, R6, R4	//x
	BL draw_rectangle	//right wall
	
	LDR R3, =PLAYER_THICKNESS	//height
	LDR R2, =PLAYER_SIZE		//width
	SUB R5, R2, R3
	ADD R1, R7, R5	//y
	MOV R0, R6	//x
	BL draw_rectangle	//bottom wall
	
	POP {R3}
	POP {R0-R7, LR}
	BX LR

draw_grid_ASM:
	PUSH {R0-R4, LR}
	LDR R3, =GRID_COLOR // white
	PUSH {R3}
	
	LDR R4, =BOX_SIZE
	LDR R3, =GRID_SIZE	//height
	LDR R2, =LINE_THICKNESS	//width
	MOV R1, #17	//(240-207)/2 --> y-position
	MOV R0, #57	//(320-207)/2
	ADD R0, R0, R4	//first vertical line --> x-position
	BL draw_rectangle
	
	LDR R4, =BOX_SIZE
	LDR R3, =GRID_SIZE	//height
	LDR R2, =LINE_THICKNESS	//width
	MOV R1, #17	//(240-207)/2 --> y-position
	MOV R0, #57	//(320-207)/2
	ADD R0, R0, R4
	ADD R0, R0, R2
	ADD R0, R0, R4	//second vertical line --> x-position
	BL draw_rectangle
	
	LDR R4, =BOX_SIZE
	LDR R3, =LINE_THICKNESS	//height
	LDR R2, =GRID_SIZE	//width
	MOV R1, #17	//(240-207)/2 
	ADD R1, R1, R4	//first horizontal line --> y-position
	MOV R0, #57	//(320-207)/2 --> x-position
	BL draw_rectangle
	
	LDR R4, =BOX_SIZE
	LDR R3, =LINE_THICKNESS	//height
	LDR R2, =GRID_SIZE	//width
	MOV R1, #17	//(240-207)/2
	ADD R1, R1, R4
	ADD R1, R1, R3
	ADD R1, R1, R4	//second horizontal line --> y-position
	MOV R0, #57	//(320-207)/2 --> x-position
	BL draw_rectangle
	
	POP {R3}
	
	POP {R0-R4, LR}
	BX LR

VGA_fill_ASM:
	PUSH {R0-R2, LR}
	MOV R0, #0
	LDR R2, =BACKGROUND_COLOR 		//BACKGROUND COLOR
	B X_LOOP
	
	X_LOOP:
		MOV R1, #0
		B Y_LOOP
	
	Y_LOOP:
		PUSH {LR}
		BL VGA_draw_point_ASM
		POP {LR}
		
		ADD R1, #1
		CMP R1, #240
		BLE Y_LOOP
		
		ADD R0, #1
		CMP R0, #320
		BLE X_LOOP
		
		POP {R0-R2, LR}
		BX LR

@ TODO: copy VGA driver here.
VGA_draw_point_ASM:
	PUSH {R0-R3, LR}
	LDR R3, =PIXEL_BUFFER_MEMORY
	LSL R0, #1 		//X-coordinate
	LSL R1, #10		//Y-coordinate
	ADD R1, R0
	ADD R3, R1
	STRH R2, [R3]		//storing color in halfword
	POP {R0-R3, LR}
	BX LR

VGA_clear_pixelbuff_ASM:
	PUSH {R0-R2, LR}
	MOV R0, #0
	MOV R2, #0
	
	PIXEL_LOOP1:
		MOV R1, #0
		CMP R0, #320		//320 pixels wide (x)
		BGE STOP_PIXEL 
	
	PIXEL_LOOP2:
		CMP R1, #240		//240 pixels high (y)
		BLLT VGA_draw_point_ASM
		ADDLT R1, #1 		//y++
		BLT PIXEL_LOOP2
		
		ADDGE R0, #1 		//x++
		BGE PIXEL_LOOP1
	
	STOP_PIXEL:
		POP {R0-R2, LR}
		BX LR

VGA_write_char_ASM:
	PUSH {R0-R3, LR}
	
	CMP R0, #0		//X
	BLT STOP_WRITE_CHAR
	CMP R0, #80
	BGE STOP_WRITE_CHAR
	
	CMP R1, #0		//Y
	BLT STOP_WRITE_CHAR
	CMP R1, #60
	BGE STOP_WRITE_CHAR
	
	LDR R3, =CHAR_BUFFER_MEMORY
	LSL R1, #7
	ADD R1, R0
	ADD R3, R1
	STRB R2, [R3]
	
	STOP_WRITE_CHAR:
		POP {R0-R3, LR}
		BX LR

VGA_clear_charbuff_ASM:
	PUSH {R0-R3, LR}
	MOV R0, #0
	MOV R2, #0
	
	CHAR_LOOP1:
		MOV R1, #0
		CMP R0, #80	
		BGE STOP_CHAR
	
	CHAR_LOOP2:
		CMP R1, #60	
		BLLT VGA_write_char_ASM
		ADDLT R1, #1
		BLT CHAR_LOOP2
		
		ADDGE R0, #1
		BGE CHAR_LOOP1
	
	STOP_CHAR:
		POP {R0-R3, LR}
		BX LR

read_PS2_data_ASM:
	PUSH {R1-R3, LR}
	LDR R1, =PS2_MEMORY
	LDR R2, [R1]
	LSR R3, R1, #15
	
	CMP R3, #1		//check if valid
	BEQ VALID
	
	MOV R0, #0		//output 0 if not valid
	POP {R1-R3, LR}
	BX LR
	
	VALID:
		STRB R2, [R0]	//data stored at pointer argument address
		MOV R0, #1		//output 1 if valid
	
		POP {R1-R3, LR}
		BX LR

draw_rectangle:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        ldr     r7, [sp, #32]
        add     r9, r1, r3
        cmp     r1, r9
        popge   {r4, r5, r6, r7, r8, r9, r10, pc}
        mov     r8, r0
        mov     r5, r1
        add     r6, r0, r2
        b       .line_L2
.line_L5:
        add     r5, r5, #1
        cmp     r5, r9
        popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
.line_L2:
        cmp     r8, r6
        movlt   r4, r8
        bge     .line_L5
.line_L4:
        mov     r2, r7
        mov     r1, r5
        mov     r0, r4
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        cmp     r4, r6
        bne     .line_L4
        b       .line_L5