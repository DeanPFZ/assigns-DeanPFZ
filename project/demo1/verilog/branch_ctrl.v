module branch_ctrl(BranchOp, Branch, PCImm, Jump, Carry, Ofl, Zero, Neg, PCSrc);
	// This signal indicates what type of conditional branch will be executed
	// 00: BNEZ; 01: BEQZ; 10: BLTZ; 11: BGEZ;
	input[1:0] BranchOp; 
	
	input Branch, PCImm, Jump, Carry, Ofl, Zero, Neg;
	output PCSrc;
	
	wire take_branch;
	
	assign take_branch = Branch?
								(BranchOp==2'b00)?~Zero:
								(BranchOp==2'b01)?Zero:
								(BranchOp==2'b10)?Neg:
								(BranchOp==2'b11)?~Neg:
								1'b0
						 :1'b0;
	assign PCSrc = PCImm | Jump | take_branch;
	
endmodule