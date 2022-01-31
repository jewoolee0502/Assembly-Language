.global _start

fx: .word 183, 207, 128, 30, 109, 0, 14, 52, 15, 210, 228, 76, 48, 82, 179, 194, 22, 168, 58, 116, 228, 217, 180, 181, 243, 65, 24, 127, 216, 118, 64, 210, 138, 104, 80, 137, 212, 196, 150, 139, 155, 154, 36, 254, 218, 65, 3, 11, 91, 95, 219, 10, 45, 193, 204, 196, 25, 177, 188, 170, 189, 241, 102, 237, 251, 223, 10, 24, 171, 71, 0, 4, 81, 158, 59, 232, 155, 217, 181, 19, 25, 12, 80, 244, 227, 101, 250, 103, 68, 46, 136, 152, 144, 2, 97, 250, 47, 58, 214, 51

kx: .word 1, 1, 0, -1, -1, 0, 1, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 1, 0, -1, -1, 0, 1, 1

gx: .space 4*(10*10)

i_size: .word 10	//since image width=height
k_size: .word 5		//since kernel width=height
k_stride_size: .word 2		//since kernel width stride=height stride

_start:
	LDR R0, =fx		//loading the address fx (fx[0])
	LDR R1, =kx		//loading the address kx (kx[0])
	LDR R2, =gx		//loading the address gx (gx[0])
	
	LDR R3, i_size	//loading the image width/height into R3
	LDR R4, k_size	//loading the kernel width/height into R4
	LDR R5, k_stride_size	//loading kernel width/height stride into R5
	
	MOV R6, #0	//initializing the value y=0
	
LOOP:
	CMP R6, R3	//comparing R6 and R3 (R6-R3) --> y<ih
	BGE END		//if R6-R3>=0, branch to end
	MOV R7, #0	//initializing the value x=0
	B LOOP2
	
LOOP_INC:
	ADD R6, R6, #1	//y++
	B LOOP
	
LOOP2:
	CMP R7, R3	//comparing R6 and R3 (R6-R3) --> x<iw
	BGE LOOP_INC	//if R7-R3>=0, branch to LOOP_INC
	MOV R10, #0	//sum=0
	MOV R8, #0	//initializing the value i=0
	B LOOP3
	
LOOP2_INC:
	MUL R11, R7, R3		//x*i_size(gx width = fx width)
	ADD R11, R11, R6	//x*i_size(gx width = fx width)+y
	STR R10, [R2, R11, LSL #2]	//(x*i_size + y)*2^2 (because each word is 4 bytes) --> gx[x][y] = sum

	ADD R7, R7, #1	//x++
	B LOOP2

LOOP3:
	CMP R8, R4	//comparing R8 and R4 (R8-R4) --> i<kw
	BGE LOOP2_INC	//if R8-R4>=0, branch to LOOP2_INC
	MOV R9, #0	//initializing the value j=0
	B LOOP4
	
LOOP3_INC:
	ADD R8, R8, #1	//i++
	B LOOP3

LOOP4:
	CMP R9, R4	//comparing R9 and R4 (R9-R4) --> j<kh
	BGE LOOP3_INC	//if R9-R4>=0, branch to LOOP3_INC
	
	ADD R11, R7, R9		//temp1 = x+j
	SUB R11, R11, R5	//temp1 = x+j-ksw
	
	ADD R12, R6, R8		//temp2 = y+i
	SUB R12, R12, R5	//temp2 = y+i-khw
	
	IF_1:
		CMP R11, #0	//temp1>=0
		BGE IF_2	//branch to next condition IF_2
		B LOOP4_INC	//if not, go to LOOP4_INC and increment j

	IF_2:
		CMP R11, #9	//temp1<=9
		BLE IF_3	//branch to next condition IF_3
		B LOOP4_INC	//if not, go to LOOP4_INC and increment j

	IF_3:
		CMP R12, #0	//temp2>=0
		BGE IF_4	//branch to next condition IF_4
		B LOOP4_INC	//if not, go to LOOP4_INC and increment j

	IF_4:
		CMP R12, #9	//temp2<=9
		BLE SUM		//branch to SUM(inside the if statement)
		B LOOP4_INC	//if not, go to LOOP4_INC and increment j
	
	SUM:
		MUL R11, R11, R3	//temp1*i_size
		ADD R11, R11, R12	//temp1*i_size + temp2
		LDR R11, [R0, R11, LSL #2]	//fx[temp1][temp2] (shifting left by 2^2 because each word is 4 bytes)
		
		MUL R12, R9, R4		//j*k_size
		ADD R12, R12, R8	//j*k_size + i
		LDR R12, [R1, R12, LSL #2]	//kx[j][i] (shifting left by 2^2 because each word is 4 bytes)
		
		MUL R11, R11, R12	//kx[j][i] * fx [temp1][temp2] in R11
		ADD R10, R10, R11	//sum = sum + kx[j][i] * fx [temp1][temp2] in R10
		
		B LOOP4_INC
	
LOOP4_INC:
	ADD R9, R9, #1	//j++
	B LOOP4
	
END:
	B END
	