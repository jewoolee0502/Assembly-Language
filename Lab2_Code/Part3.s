.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

PB_int_flag:
    .word 0x0
	
tim_int_flag:
    .word 0x0

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

.text
.global _start

_start:
	MOV R0, #0b111111	
	PUSH {LR}
	BL HEX_clear_ASM	//to make sure nothing is on the hexadecimal
	POP {LR}

	/* Set up stack pointers for IRQ and SVC processor modes */
    MOV R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR CPSR_c, R1           // change to IRQ mode
    LDR SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR CPSR, R1             // change to supervisor mode
    LDR SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL CONFIG_GIC           // configure the ARM GIC
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
	PUSH {LR}
	BL enable_PB_INT_ASM
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
	
   	LDR R0, =0xFF200050      // pushbutton KEY base address
    MOV R1, #0xF            // set interrupt mask bits
    STR R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV R0, #0b01010011      // IRQ unmasked, MODE = SVC
    MSR CPSR_c, R0
	
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0


IDLE:
	LDR R7, =PB_int_flag
	LDR R7, [R7]
	
	CMP R7, #0b0001
	BEQ TIMER
	
	CMP R7, #0b0010
	BEQ IDLE
	
	CMP R7, #0b0100
	BEQ RESET
	
	B IDLE
	
TIMER:
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
	
	LDR R8, =tim_int_flag
	LDR R8, [R8]
	TST R8, #1
	BEQ IDLE
	
	
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
	
	LDR R0, =tim_int_flag	
	MOV R9, #0
	STR R9, [R0]	//clearing the tim_int_flag (reset)
	
	B TIMER

RESET:
	MOV R0, #0b111111
	MOV R1, #0
	
	PUSH {LR}
	BL HEX_write_ASM
	POP {LR}
	
	MOV R0, #0
	LDR R1, =PB_int_flag
	STR R0, [R1]		//clearing the PB_int_flag (reset)
	
	MOV R1, #0
	MOV R2, #0
	MOV R3, #0
	MOV R4, #0
	MOV R5, #0
	MOV R6, #0
	
	B IDLE

/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
    PUSH {R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR

/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
Check_timer:
	CMP R5, #29
	BNE Pushbutton_check	
	
	PUSH {LR}
	BL ARM_TIM_ISR
	POP {LR}
	
	B EXIT_IRQ

Pushbutton_check:
    CMP R5, #73
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
    BL KEY_ISR
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
    B SERVICE_FIQ
	
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

	MOV R0, #29				//Interrupt ID = 29
	MOV R1, #1
	PUSH {LR}
	BL CONFIG_INTERRUPT
	POP {LR}

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
	
KEY_ISR:
	PUSH {R0-R2, LR}
	
	LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
   	MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
	
	LDR R2, =PB_int_flag
	STR R1, [R2]
	PUSH {LR}
	BL PB_clear_edgecp_ASM
	POP {LR}
	
	POP {R0-R2, LR}
	BX LR

ARM_TIM_ISR:
	PUSH {R0-R2, LR}
	
	PUSH {LR}
	BL ARM_TIM_read_INT_ASM
	POP {LR}
	
	PUSH {LR}
	BL ARM_TIM_clear_INT_ASM
	POP {LR}
	
	LDR R1, =tim_int_flag
	STR R0, [R1]
	
	POP {R0-R2, LR}
	BX LR
	
/////////////////////////////////////////////////////////////////////////////////////

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