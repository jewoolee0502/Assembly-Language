.global _start

/* The EQU directive gives a symbolic name to a numeric constant,
a register-relative value or a PC-relative value. */
.equ LED_MEMORY, 0xFF200000
.equ HEXDISPLAY0_3, 0xFF200020
.equ HEXDISPLAY4_5, 0xFF200030
.equ SW_MEMORY, 0xFF200040
.equ PB_DATA, 0xFF200050
.equ PB_MASK, 0xFF200058
.equ PB_EDGE, 0xFF20005C


_start:

/*
	MOV R0, #0b110111
	MOV R1, #15
	PUSH {LR}
	//BL  HEX_flood_ASM
	//BL HEX_clear_ASM
	BL HEX_write_ASM
	POP {LR}
	B END
*/

	MOV R0, #0b111111
	PUSH {LR}
	BL HEX_flood_ASM
	POP {LR}
	
	PUSH {LR}
	BL HEX_clear_ASM
	POP {LR}

APPLICATION:
	MOV R0, #0b110000
	PUSH {LR}
	BL HEX_flood_ASM
	POP {LR}
	
LOOP:
	PUSH {LR}
	BL read_slider_switches_ASM
	POP {LR}
	
	MOV R2, R0
	PUSH {R2, LR}
	BL write_LEDs_ASM
	POP {R2, LR}
	
	TST R2, #0b1000000000
	MOVNE R0, #0b001111
	
	PUSH {LR}
	BLNE HEX_clear_ASM
	POP {LR}
	
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0
	MOV R1, R2
	PUSH {LR}
	BLGT HEX_write_ASM
	POP {LR}
	
	PUSH {LR}
	BL PB_clear_edgecp_ASM
	POP {LR}

	B LOOP


/*
HEX0 = 0x00000001
HEX1 = 0x00000002
HEX2 = 0x00000004
HEX3 = 0x00000008
HEX4 = 0x00000010
HEX5 = 0x00000020
*/

//clears all the segments in the chosen HEX display 
HEX_clear_ASM:
	PUSH {R1-R4, LR}
	LDR R1, =HEXDISPLAY0_3
	LDR R2, =HEXDISPLAY4_5
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000001
	ANDNE R3, R3, #0xFFFFFF00
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000002
	ANDNE R3, R3, #0xFFFF00FF
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000004
	ANDNE R3, R3, #0xFF00FFFF
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000008
	ANDNE R3, R3, #0x00FFFFFF
	STRNE R3, [R1]
	
	LDR R3, [R2]
	ANDS R4, R0, #0x00000010
	ANDNE R3, R3, #0xFFFFFF00
	STRNE R3, [R2]
	
	LDR R3, [R2]
	ANDS R4, R0, #0x00000020
	ANDNE R3, R3, #0xFFFF00FF
	STRNE R3, [R2]
	
	POP {R1-R4, LR}
	BX LR
	

//turn on all the segments in the HEX display
HEX_flood_ASM:
	PUSH {R1-R4, LR}
	LDR R1, =HEXDISPLAY0_3
	LDR R2, =HEXDISPLAY4_5
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000001
	ORRNE R3, R3, #0x000000FF
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000002
	ORRNE R3, R3, #0x0000FF00
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000004
	ORRNE R3, R3, #0x00FF0000
	STRNE R3, [R1]
	
	LDR R3, [R1]
	ANDS R4, R0, #0x00000008
	ORRNE R3, R3, #0xFF000000
	STRNE R3, [R1]
	
	LDR R3, [R2]
	ANDS R4, R0, #0x00000010
	ORRNE R3, R3, #0x000000FF
	STRNE R3, [R2]
	
	LDR R3, [R2]
	ANDS R4, R0, #0x00000020
	ORRNE R3, R3, #0x0000FF00
	STRNE R3, [R2]
	
	POP {R1-R4, LR}
	BX LR

		
//Based on R1, it will display the corresponding hexadecimal digit
HEX_write_ASM:
	PUSH {R2-R8, LR}
	LDR R2, =HEXDISPLAY0_3
	LDR R3, =HEXDISPLAY4_5
	
	CMP R1, #0
	MOVEQ R5, #0b00111111
	BEQ W_LOOP
	
	CMP R1, #1
	MOVEQ R5, #0b00000110
	BEQ W_LOOP
	
	CMP R1, #2
	MOVEQ R5, #0b01011011
	BEQ W_LOOP
	
	CMP R1, #3
	MOVEQ R5, #0b01001111
	BEQ W_LOOP
	
	CMP R1, #4
	MOVEQ R5, #0b01100110
	BEQ W_LOOP
	
	CMP R1, #5
	MOVEQ R5, #0b01101101
	BEQ W_LOOP
	
	CMP R1, #6
	MOVEQ R5, #0b01111101
	BEQ W_LOOP
	
	CMP R1, #7
	MOVEQ R5, #0b00000111
	BEQ W_LOOP
	
	CMP R1, #8
	MOVEQ R5, #0b01111111
	BEQ W_LOOP
	
	CMP R1, #9
	MOVEQ R5, #0b01100111
	BEQ W_LOOP
	
	CMP R1, #10
	MOVEQ R5, #0b01110111
	BEQ W_LOOP
	
	CMP R1, #11
	MOVEQ R5, #0b01111100
	BEQ W_LOOP
	
	CMP R1, #12
	MOVEQ R5, #0b00111001
	BEQ W_LOOP
	
	CMP R1, #13
	MOVEQ R5, #0b01011110
	BEQ W_LOOP
	
	CMP R1, #14
	MOVEQ R5, #0b01111001
	BEQ W_LOOP
	
	CMP R1, #15
	MOVEQ R5, #0b01110001
	B W_LOOP
	
	W_LOOP:
		LDR R6, [R2]
		ANDS R7, R0, #0x00000001
		ANDNE R6, R6, #0xFFFFFF00
		ORRNE R6, R6, R5
		STRNE R6, [R2]
		
		LDR R6, [R2]
		ANDS R7, R0, #0x00000002
		ANDNE R6, R6, #0xFFFF00FF
		LSL R8, R5, #8
		ORRNE R6, R6, R8
		STRNE R6, [R2]
		
		LDR R6, [R2]
		ANDS R7, R0, #0x00000004
		ANDNE R6, R6, #0xFF00FFFF
		LSL R8, R5, #16
		ORRNE R6, R6, R8
		STRNE R6, [R2]
		
		LDR R6, [R2]
		ANDS R7, R0, #0x00000008
		ANDNE R6, R6, #0x00FFFFFF
		LSL R8, R5, #24
		ORRNE R6, R6, R8
		STRNE R6, [R2]
		
		LDR R6, [R3]
		ANDS R7, R0, #0x00000010
		ANDNE R6, R6, #0xFFFFFF00
		ORRNE R6, R6, R5
		STRNE R6, [R3]
		
		LDR R6, [R3]
		ANDS R7, R0, #0x00000020
		ANDNE R6, R6, #0xFFFF00FF
		LSL R8, R5, #8
		ORRNE R6, R6, R8
		STRNE R6, [R3]
		
		POP {R2-R8, LR}
		BX LR



/*
PB0 = 0x00000001
PB1 = 0x00000002
PB2 = 0x00000004
PB3 = 0x00000008
*/


read_PB_data_ASM:
	PUSH {R1, LR}
	LDR R1, =PB_DATA
	LDR R0, [R1]
	POP {R1, LR}
	BX LR

read_PB_edgecp_ASM:
	PUSH {R1, LR}
	LDR R1, =PB_EDGE
	LDR R0, [R1]
	POP {R1, LR}
	BX LR

PB_clear_edgecp_ASM:
	PUSH {R0, R1, LR}
	LDR R1, =PB_EDGE
	STR R0, [R1]
	POP {R0, R1, LR}
	BX LR

enable_PB_INT_ASM:
	PUSH {R1, LR}
	LDR R1, =PB_MASK
	STR R0, [R1]
	POP {R1, LR}
	BX LR

disable_PB_INT_ASM:
	PUSH {R0, R1, LR}
	LDR R1, =PB_MASK
	EOR R0, R0, #0b00001111
	STR R0, [R1]
	POP {R0, R1, LR}
	BX LR


// Sider Switches Driver
// returns the state of slider switches in R0
read_slider_switches_ASM:
    LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX  LR
	
// LEDs Driver
// writes the state of LEDs (On/Off state) in R0 to the LEDs memory location
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR
	
END:
	B END