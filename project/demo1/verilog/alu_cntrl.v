/*
 * ALU Control
 *
 * This module implements the logic for ALU operations
 *
 */
module alu_cntrl (opCode, funct, aluOp, invA, invB, Cin, sign, rorSel);

   	// declare constant for size of inputs, outputs (N),
   	// and operations (O)
  	parameter	N = 16;
   
	// Input
   	input [4:0] 	opCode;
   	input [1:0] 	funct;
	
	// Output
   	output [2:0] 	aluOp;
   	output			invA;
   	output       	invB;
   	output       	Cin;
   	output       	sign;
   	output       	rorSel;


	assign invA = (opCode == 5'b01000) ? 1 : 0; // SUBI

	assign invB = (opCode[4:2] == 3'b111 && opCode[4:0] != 5'b11111) ? 1 :		// Sets
					(opCode[4:2] == 3'b100) ? 1 :								// ST LD STU
					(opCode[4:0] == 5'b01010) ? 1 :								// ANDNI
					(opCode[4:0] == 5'b11011 && funct[1:0] == 2'b11) ? 1 : 0;	// ANDN

	assign Cin = (opCode[4:2] == 3'b111 && opCode[4:0] != 5'b11111) ? 1 :		// Sets
					(opCode[4:2] == 3'b100) ? 1 :								// ST LD STU
					(opCode[4:0] == 5'b01000) ? 1 : 0;							// SUBI

	assign sign = (opCode[4:2] == 3'b111 && opCode[4:0] != 5'b11111) ? 1 :		// Sets
					(opCode[4:0] == 5'b11011 && funct[1:0] == 2'b00) ? 1 :		// ADD
					(opCode[4:0] == 5'b11011 && funct[1:0] == 2'b01) ? 1 :		// SUB
					(opCode[4:1] == 4'b0100) ? 1 :								// ANDI/SUBI
					(opCode[4:2] == 3'b100) ? 1 : 0;							// ST LD STU

	// Select on 0 NOT 1
	assign aluOp[2] = (opCode[4:2] == 5'b101) ? 0 :
						(opCode[4:0] == 5'b11010) ? 0 : 1;

	assign aluOp[1] = (opCode[4:0] == 5'b01011) ? 1 :
						(opCode[4:0] == 5'b10111) ? 1 :
						(opCode[4:0] == 5'b11010 && funct[1:0] == 2'b11) ? 1 :
						(opCode[4:0] == 5'b11011 && funct[1:0] == 2'b10) ? 1 : 0;

	assign aluOp[0] = (opCode[4:1] == 5'b0101) ? 1 :
						(opCode[4:0] == 5'b10101) ? 1 :
						(opCode[4:0] == 5'b10110) ? 1 :
						(opCode[4:0] == 5'b10111) ? 1 :
						(opCode[4:0] == 5'b11010 && funct[0] == 1) ? 1 :
						(opCode[4:0] == 5'b11010 && funct[0] == 1) ? 1 :
						(opCode[4:0] == 5'b11011 && funct[1] == 1) ? 1 :
						(opCode[4:0] == 5'b11011 && funct[1] == 1) ? 1 : 0;

	assign rorSel = (opCode[4:0] == 5'b10110) ? 1 :
					(opCode[4:0] == 5'b11010 && funct[1:0] == 2'b10) ? 1 : 0;
	
endmodule
