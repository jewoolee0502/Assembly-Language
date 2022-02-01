.global _start
.equ n, 8
F: .space 4*(n+2)

//R0 contains the nth fibonacci number

_start:
	LDR R6, =F	//setting R6 to have the base address of F
	MOV	R1, #0	//initializing the value R1 = 0 --> f(0) = 0
	STR R1, [R6]	//Storing R1 value into the address of R6
	
	MOV R1, #1	//initializing the value R1 = 1 --> f(1) = 1
	STR R1, [R6, #4]	//storing the new value of R1 into the address of R6+4
	
	MOV R2, #2	//temporary variable for i
	MOV R3, #n	//temporary variable for n
	
	CMP R3, #0	//comparing R3(n) with 0
	MOVEQ R0, R3	//copying the value 0 into R0 if n = 0 (special case)
	BEQ END		//branch to end if the condition is met
	
	CMP R3, #1	//comparing R3(n) with 1
	MOVEQ R0, R3	//copying the value 1 into R0 if n = 1 (special case)
	BEQ END		//branch to end if the condition is met
	
	SUB R7, R2, #1	//temporary variable for (i-1)
	SUB R8, R2, #2	//temporary variable for (i-2)
	
FIB: 
	CMP R2, R3	//comparing R2 and R3 (R2-R3)
	BGT END		//if R2-R3 > 0, go to END
	
	LDR R4, [R6, R7, LSL #2]	//loading the value from f[i-1]
	LDR R5, [R6, R8, LSL #2]	//loading the value from f[i-2]
	ADD R0, R4, R5				//adding f[i-1] and f[i-2] together and storing the value in R0
	STR R0, [R6, R2, LSL #2] 	//storing f[i] into the address of R6+4*i
	
	ADD R2, R2, #1	//i++
	ADD R7, R7, #1	//(i-1)++
	ADD R8, R8, #1	//(i-2_++
	B FIB		//branch back to Fib (loop)

END:
	B END	//endless loop