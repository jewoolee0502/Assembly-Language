.global _start
.equ PIXEL_BUFFER_MEMORY, 0xc8000000
.equ CHAR_BUFFER_MEMORY, 0xc9000000
.equ PS2_MEMORY, 0xff200100

_start:
        bl      input_loop
end:
        b       end

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


@ TODO: insert PS/2 driver here.
read_PS2_data_ASM:
	PUSH {R1-R3, LR}
	LDR R1, =PS2_MEMORY
	LDR R2, [R1]
	LSR R3, R2, #15
	
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


write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
