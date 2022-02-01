.global _start

SIZE: .word 5	//size of the array
ARRAY: .word -1, 23, 0, 12, -7	//integer array that I will bubble sort

_start:
	LDR R0, SIZE	//R0 = SIZE
	SUB R0, R0, #1	//R0 = size - 1
	MOV R1, #0	//R1 = step = 0
	
//bubble sort algorithm
LOOP:
	CMP R1, R0	//comparing step(R1) and size-1(R0), if R1<R0, continue
	BGE END		//branch to end when condition is not met (R1-R0)>=0
	
	LDR R2, =ARRAY	//initialized R2 to point at the start of the ARRAY (*ptr = &array[0])
	
	SUB R3, R0, R1	//R3=R0-R1 --> R3 = (size) - (step - 1) = (size - 1) - (step)
	MOV R4, #0	//R4 = i = 0
	B LOOP2

STEP_INC:
	ADD R1, R1, #1	//step++
	B LOOP		//branching back to LOOP(the first for loop)

LOOP2:
	CMP R4, R3	//comparing R4 and R3, if(R4<R3), continue
	BGE STEP_INC	//branch to STEP_INC when the condition is met (R3-R4)>=0
		
	LDR R5, [R2]	//load the value *(ptr + i) that is stored in the address R2 into R5 
	LDR R6, [R2, #4]!	//load the value *(ptr + i + 1) that is stored in the address R0+4 into R6. Also updating the address of R2
	
	IF:
		CMP R5, R6	//comparing R5 and R6, if(R5>R6), continue
		BLE I_INC	//branch to I_INC when the condition is met (R5-R6<=0)
	
		//swapping
		STR R5, [R2]		//storing the value *(ptr + i) in *(ptr + i + 1)
		STR R6, [R2, #-4]	//storing the value *(ptr + i + 1) in *(ptr + i)
		B I_INC	//branch to I_INC
	
I_INC:
	ADD R4, R4, #1	//i++
	B LOOP2		//branching back to LOOP2(the nested for loop)

END:
	B END	//infinite loop to END 
	