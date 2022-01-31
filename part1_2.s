.global _start

n: .word 14		//nth fibonacci

_start:
	LDR R1, n	//loading the value n into R1
	BL FIB		//subroutine to Fib
	B END		//branch to end
	
FIB:
	PUSH {R2, R3, LR}	//pushing R1, R2, R3, and LR to save the address
	MOV R2, R1		//copying the R1 value into R2
	CMP R2, #1		//comparing R2 and 1 (R2-1)
	BLE FIB_END		//branch to FIB_END if R2<=1
	
	SUB R1, R2, #1	//n-1
	BL FIB			//recursive call --> f(n-1)
	
	MOV R3, R0		//copying the output R0 into R3
	SUB R1, R2, #2	//n-2
	BL FIB			//recursive call --> f(n-2)
	
	ADD R0, R0, R3	//f(n) = f(n-1) + f(n-2)
	POP {R2, R3, LR}	//popping all the saved addresses
	
	BX LR		//return to calling code
	
FIB_END:
	MOV R0, R2	//copying the value of R2 (n) into R0
	POP {R2, R3, LR}	//popping all the saved addresses
	BX LR		//returning to calling code
	
END:
	B END	//infinite loop to end
	