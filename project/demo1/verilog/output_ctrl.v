module output_ctrl(BTR, Carry, Ofl, Zero, Neg, Set, SetOp, link, SLBI, LBI, OutSel);

	input BTR, Carry, Ofl, Zero, Neg, Set, link, SLBI, LBI;
	// 00: SEQ; 01: SLT; 10: SLE; 11: SCO;
	input[1:0] SetOp;
	output[2:0] OutSel;
	
	wire take_set;
	
	assign take_set = Set?
						  (SetOp==2'b00)?Zero:
						  (SetOp==2'b01)?(Neg!=Ofl):
						  (SetOp==2'b10)?(Zero|(Neg!=Ofl)):
						  (SetOp==2'b11)?Carry:
						  1'b0
						 :1'b0;
	assign OutSel = BTR?3'h0:
					take_set?3'h1:
					~take_set?3'h2:
					link?3'h3:
					LBI?3'h4:
					SLBI?3'h5:
					3'h6;
endmodule