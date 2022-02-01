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

.equ ARMA9_LOAD, 0xFFFEC600
.equ ARMA9_CONTROL, 0xFFFEC608
.equ ARMA9_INTERRUPT, 0xFFFEC60C 
.equ FREQUENCY, 0x0BEBC200	//clock frequency of 200MHz
.equ FREQUENCY2, 0x01E8480	//time it takes for 0.01 sec (10 mili sec) to make a full cycle


_start:
	MOV R0, #0b111111	
	PUSH {LR}
	BL HEX_clear_ASM	//to make sure nothing is on the hexadecimal
	POP {LR}
	
	LDR R0, =FREQUENCY2
	MOV R1, #0b0111
	
	PUSH {LR}
	BL ARM_TIM_config_ASM
	POP {LR}
	
	MOV R0, #0b111111
	MOV R1, #0
	
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0
	
PRE_TIMER:
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0001
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ TIMER
	
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0010
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ PRE_TIMER
	
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0100
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ RESET

	B PRE_TIMER
	
TIMER:
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0001
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ TIMER
	
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0010
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ PRE_TIMER
	
	PUSH {LR}
	BL read_PB_edgecp_ASM
	POP {LR}
	
	CMP R0, #0b0100
	PUSH {LR}
	BLEQ PB_clear_edgecp_ASM
	POP {LR}
	
	BEQ RESET
	
	MOV R7, R1
	
	MOV R0, #0b000001
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0b000010
	MOV R1, R2
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0b000100
	MOV R1, R3
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0b001000
	MOV R1, R4
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0b010000
	MOV R1, R5
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0b100000
	MOV R1, R6
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R1, R7
	MOV R8, R3
	
	PUSH {LR}
	BL ARM_TIM_read_INT_ASM
	POP {LR}
	
	TST R3, #1	//checking the interrupt status is 1
	MOV R3, R8
	
	BEQ TIMER
	
INCREMENT:
	ADD R1, #1
	CMP R1, #9
	SUBGT R1, #10
	ADDGT R2, #1
	
	CMP R2, #9
	SUBGT R2, #10
	ADDGT R3, #1
	
	CMP R3, #9
	SUBGT R3, #10
	ADDGT R4, #1
	
	CMP R4, #5
	SUBGT R4, #6
	ADDGT R5, #1
	
	CMP R5, #9
	SUBGT R5, #10
	ADDGT R6, #1
	
	CMP R6, #5
	SUBGT R6, #6
	
	PUSH {LR}
	BL ARM_TIM_clear_INT_ASM
	POP {LR}
	
	B TIMER

RESET:
	MOV R0, #0b111111
	MOV R1, #0
	
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0
	
	PUSH {LR}
	BL PB_clear_edgecp_ASM
	POP {LR}
	
	B PRE_TIMER

ARM_TIM_config_ASM:
	PUSH {R2, R3, LR}
	
	LDR R2, =ARMA9_LOAD
	STR R0, [R2]
	
	LDR R3, =ARMA9_CONTROL
	STR R1, [R3]
	
	POP {R2, R3, LR}
	BX LR

ARM_TIM_read_INT_ASM:
	PUSH {R2, LR}
	
	LDR R2, =ARMA9_INTERRUPT
	LDR R3, [R2]	//output 
	
	POP {R2, LR}
	BX LR

ARM_TIM_clear_INT_ASM:
	PUSH {R2, R3, LR}
	
	LDR R2, =ARMA9_INTERRUPT
	MOV R3, #0x00000001
	STR R3, [R2]
	
	POP {R2, R3, LR}
	BX LR


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