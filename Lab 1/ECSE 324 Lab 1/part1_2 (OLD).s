.global _start

n: .word 14	//initializing the parameter

//the output/result will be stored in R0
_start:
	LDR R0, n	//loading the value of n into R0
	BL FIB	//subroutine to FIB and updating LR
	B END
	
FIB:
	PUSH {LR}	//push LR to save the address
	CMP R0, #1	//comparing R0 and immediate value 1 (R0-1)
	BGT ELSE	//branch to ELSE if (R0-1)>0
	
	MOV R1, #0	//copying the value of f(0) in R1 --> n-2
	MOV R2, #1	//copying the value of f(1) in R2 --> n-1
	
	POP {LR}	//popping LR 
	BX LR		
	
ELSE:
	SUB R0, R0, #1	//subtracting 1 from R0 (n-1)
	BL FIB	//recursion fib(n-1)
	
	ADD R0, R0, R1	//f(n+1) = f(n) + f(n-1)
	
	//post update
	MOV R1, R2	//copying the value of f(n-1) into R1
	MOV R2, R0	//copying the value of f(n) into R2
	
	POP {LR}	//popping LR
	BX LR
	
END:
	B END
	