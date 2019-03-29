/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
	// Outputs
	err,
	// Inputs
	clk, rst
	);

	//
	// Inputs
	//
	input clk;
	input rst;

	//
	// Outputs
	//
	output err;


	wire cntrlErr, rfErr;
	wire Carry, Neg;

	assign err = cntrlErr | rfErr;
	// None of the above lines can be modified

	// OR all the err ouputs for every sub-module and assign it as this
	// err output

	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines

	//
	// Fetch Signals
	//
	wire [15:0] pre_PC;
	wire [15:0] post_PC;
	wire HaltPC;
	wire [15:0] PC2_after;
	wire [15:0] PC2_back;
	wire CO_temp1, CO_temp2;


	wire [15:0] ftch_instruction;
	wire [15:0] ftch_PC2;
	wire [4:0] OpCode;
	wire [1:0] Funct;
	wire [2:0] Rs;
	wire [2:0] Rt;
	wire [4:0] dec_Imm5;
	wire [7:0] dec_Imm8;
	wire [10:0] dec_ImmDis;

	//control (OpCode and Funct are inputs)
	wire RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc,
	PCImm, MemToReg, DMemDump, Jump;
	wire [1:0] RegDst;
	wire link, disp, Branch;

	//
	// Fetch/Decode Pipeline Reg Signals
	//
	wire [31:0] ftchOut;
	wire [31:0] decIn;
	wire ftchDecEn; 

	//
	// Decode Signals
	//
	wire [15:0] dec_instruction;
	wire [15:0] dec_PC2;
	wire [15:0] exe_PC2;

	//register file
	wire [2:0]  readReg1Sel;
	wire [2:0]  readReg2Sel;
	wire [2:0]  writeRegSel;
	wire [15:0] writeData;
	wire        writeEn;
	wire [15:0] dec_readData1;
	wire [15:0] dec_readData2;

	//
	// Execute Signals
	//

	wire [15:0] exe_readData1;
	wire [15:0] exe_readData2;

	wire [15:0] A;
	wire [15:0] B;
	wire Cin;
	wire [2:0] Op;
	wire invA;
	wire invB;
	wire sign;

	wire [15:0] Out;
	wire [15:0] aluOut;
	wire Ofl;
	wire Zero;
	wire subtraction;
	wire [2:0]OutSel;
	wire [15:0] mirr_rd1;

	wire rorSel;
	wire [15:0] before_ROR;
	wire [15:0] after_ROR;
	wire [15:0] after_Branch;
	wire [15:0] negReadData2;
	wire ror_with_reg;
	wire [15:0] ShiftLeftValue;
	wire CO_temp3, CO_temp4, CO_temp5;

	// PC
	wire [15:0] after_disp;
	wire [15:0] added;

	//
	// Memory Signals
	//
	//memory (enable is DMemWrite, wr is DMemEn, addr is Addr[15:0])
	wire [15:0] Datain;
	wire Createdump;

	wire [15:0] Dataout;

	wire [1:0] SetOp;
	wire [1:0] BranchOp;
	wire BTR;


	//
	// Fetch Logic
	//
	assign pre_PC[15:0] = HaltPC? post_PC : PC2_back;

	//PC Reg
	reg16 regPC(.q(post_PC[15:0]), .d(pre_PC[15:0]), .clk(clk), .rst(rst));

	// PC + 4 adder
	rca_16b add1(.A(post_PC[15:0]), .B(16'h0002), .C_in(1'b0),.S(ftch_PC2), .C_out(CO_temp1));


	//
	// Fetch/Decode Pipeline Reg
	//
 
	// TODO: Assign the enable signal
	assign ftchDecEn = 1'bz; 
 
	assign ftchOut = {ftch_instruction[15:0], ftch_PC2[15:0]};
	reg32_en fet_dec(.q(decIn), .d(ftchOut), .clk(clk), .rst(rst), .en(ftchDecEn));
	assign dec_P2C = decIn[15:0];
	assign dec_instruction = decIn[31:16];


	//
	// Decode Logic
	//
	assign OpCode[4:0] = dec_instruction[15:11];
	assign Funct[1:0] = dec_instruction[1:0];
	assign Rs[2:0] = dec_instruction[10:8];
	assign Rt[2:0] = dec_instruction[7:5];
	assign dec_Imm5[4:0] = dec_instruction[4:0];
	assign dec_Imm8[7:0] = dec_instruction[7:0];
	assign dec_ImmDis[10:0] = dec_instruction[10:0];

	//rf
	assign writeRegSel[2:0] = (OpCode[4:0] == 5'b10011)? dec_instruction[10:8] :
								(RegDst[1:0] == 2'b00)? dec_instruction[4:2]:
								(RegDst[1:0] == 2'b01)? dec_instruction[7:5]:
								(RegDst[1:0] == 2'b10)? dec_instruction[10:8]:
								(RegDst[1:0] == 2'b11)? 3'b111 : 3'b000; //3'b000 should never happen
	assign readReg1Sel[2:0] = subtraction? Rt[2:0] : Rs[2:0];
	assign readReg2Sel[2:0] = subtraction? Rs[2:0] : Rt[2:0];
	assign writeEn = RegWrite;


	//
	// Decode/Execute Pipeline Reg
	//
	// TODO: need to pipeline dec_PC2 to exe_PC2
	wire [31:0] dec_rf_out;
	wire [63:0] dec_cntrl_out;
	wire [31:0] dec_sign_ext_out;
	wire [31:0] exe_rf_in;
	wire [63:0] exe_cntrl_in;
	wire [31:0] exe_sign_ext_in;
	wire [4:0] exe_Imm5;
	wire [7:0] exe_Imm8;
	wire [10:0] exe_ImmDis;

	// TODO: Assign the enable signal
	assign decExeEn = 1'bz; 

	// Register File Pipeline Reg
	assign dec_rf_out = {dec_readData1[15:0], dec_readData2[15:0]};
	reg32_en dec_rf(.q(exe_rf_in), .d(dec_rf_out), .clk(clk), .rst(rst), .en(decExeEn));
	assign exe_readData1 = exe_rf_in[31:16];
	assign exe_readData2 = exe_rf_in[15:0];

	// Sign-ext Pipeline Reg
	assign dec_sign_ext_out = {dec_Imm5[4:0], dec_Imm8[7:0], dec_ImmDis[10:0]};
	reg32_en dec_sign_ext(.q(exe_sign_ext_in), .d(dec_sign_ext_out), .clk(clk), .rst(rst), .en(decExeEn));
	assign exe_Imm5 = exe_sign_ext_in[23:19];
	assign exe_Imm8 = exe_sign_ext_in[18:11];
	assign exe_ImmDis = exe_sign_ext_in[10:0];

	// TODO: Control Signal Pipeline Regs


	//
	// Execute Logic
	//
	rca_16b add3(.A(16'h0010), .B(~{{12{1'b0}},exe_Imm5[3:0]}), .C_in(1'b1), .S(before_ROR[15:0]), .C_out(CO_temp3));

	assign after_ROR[15:0] = rorSel? before_ROR[15:0] : exe_readData2[15:0];
	assign after_Branch[15:0] = Branch? exe_readData1[15:0] : after_ROR[15:0];

	rca_16b add4(.A(~exe_readData2[15:0]), .B(16'b0), .C_in(1'b1),.S(negReadData2[15:0]), .C_out(CO_temp4));

	assign subtraction = OpCode[4]&OpCode[3]&~OpCode[2]&OpCode[1]&OpCode[0]&~Funct[1]&Funct[0];
	assign ror_with_reg = ~rorSel? 0 : OpCode[4]&OpCode[3]&~OpCode[2]&OpCode[1]&~OpCode[0]&Funct[1]&~Funct[0];

	rca_16b add5(.A(16'h0010), .B(~{{12{1'b0}},exe_readData2[3:0]}), .C_in(1'b1), .S(ShiftLeftValue[15:0]), .C_out(CO_temp5));

	// B input to the ALU Module
	assign B[15:0] = (OpCode[4:0] == 5'b01010) ? {{11{1'b0}}, exe_Imm5[4:0]} :
						(OpCode[4:0] == 5'b01011) ? {{11{1'b0}}, exe_Imm5[4:0]} :
						(subtraction)? negReadData2 :
						(ror_with_reg) ? ShiftLeftValue :
						(rorSel) ? after_Branch :
						(ALUSrc2) ? {{11{exe_Imm5[4]}}, exe_Imm5[4:0]} : after_Branch;

	// A input to the ALU Module
	assign A[15:0] = exe_readData1[15:0];

	assign mirr_rd1 = {{exe_readData1[0]},{exe_readData1[1]},{exe_readData1[2]},
						{exe_readData1[3]},{exe_readData1[4]},{exe_readData1[5]},{exe_readData1[6]},{exe_readData1[7]},
						{exe_readData1[8]},{exe_readData1[9]},{exe_readData1[10]},{exe_readData1[11]},
						{exe_readData1[12]},{exe_readData1[13]},{exe_readData1[14]},{exe_readData1[15]}};

	assign Out = (OutSel == 3'b000) ? mirr_rd1 :
					(OutSel == 3'b001) ? 16'h0001 :
					(OutSel == 3'b010) ? 16'h0000 :
					(OutSel == 3'b011) ? exe_PC2:
					(OutSel == 3'b100) ? {{8{exe_Imm8[7]}}, exe_Imm8} :
					(OutSel == 3'b101) ? {exe_readData1[7:0], exe_Imm8} : aluOut;

	// PC logic
	assign PC2_after[15:0] = (link)? exe_readData1[15:0] : exe_PC2[15:0];

	// displacement amount
	assign after_disp[15:0] = disp? {{5{exe_ImmDis[10]}},exe_ImmDis[10:0]} : {{8{exe_Imm8[7]}},exe_Imm8[7:0]};

	// Add the displacement to the PC
	rca_16b add2(.A(after_disp[15:0]), .B(PC2_after[15:0]), .C_in(1'b0),.S(added[15:0]), .C_out(CO_temp2));

	// Wire to update the PC
	assign PC2_back[15:0] = PCSrc? added[15:0] : PC2_after[15:0];


	//
	// Memory Logic
	//
	assign Datain[15:0] = exe_readData2[15:0];
	assign Createdump = (HaltPC);


	//
	// Write Back Logic
	//
	assign writeData = (OpCode[4:0] == 5'b00110)? exe_PC2 :
						(OpCode[4:0] == 5'b00111)? exe_PC2 :
						(MemToReg) ? Dataout[15:0] : Out[15:0];

	//
	// Fetch Modules
	//
	memory2c instruction_memory(
		//Output
		.data_out				(ftch_instruction[15:0]),
		//Inputs
		.data_in				(16'b0),
		.addr					(post_PC[15:0]),
		.enable					(1'b1),
		.wr					(1'b0),
		.createdump				(1'b0),
		.clk					(clk),
		.rst					(rst)
		);

	//
	// Decode Modules
	//
	rf rf0(
		// Outputs
		.readData1				(dec_readData1[15:0]),
		.readData2				(dec_readData2[15:0]),
		.err					(rfErr),
		// Inputs
		.clk					(clk),
		.rst					(rst),
		.readReg1Sel			(readReg1Sel[2:0]),
		.readReg2Sel			(readReg2Sel[2:0]),
		.writeRegSel			(writeRegSel[2:0]),
		.writeData				(writeData[15:0]),
		.writeEn				(writeEn)
		);

	control c0(
		// Outputs
		.err					(cntrlErr),
		.RegDst					(RegDst),
		.RegWrite				(RegWrite),
		.DMemWrite				(DMemWrite),
		.DMemEn					(DMemEn),
		.ALUSrc2				(ALUSrc2),
		.PCImm					(PCImm),
		.MemToReg				(MemToReg),
		.DMemDump				(DMemDump),
		.Jump					(Jump),
		//our implementation
		.Set					(Set),
		.SetOp					(SetOp),
		.Branch					(Branch),
		.BranchOp				(BranchOp),
		.disp					(disp),
		.HaltPC					(HaltPC),
		.BTR					(BTR),
		.SLBI					(SLBI),
		.LBI					(LBI),
		.link					(link),
		// Inputs
		.OpCode					(OpCode)
		);

	branch_ctrl b0(
		.Rs						(dec_readData1),
		.BranchOp				(BranchOp),
		.Branch					(Branch),
		.PCImm					(PCImm),
		.Jump					(Jump),
		.PCSrc					(PCSrc)
		);

	alu_cntrl alu_c0(
		//inputs
		.opCode					(OpCode),
		.funct					(Funct),
		//outputs
		.aluOp					(Op),
		.invA					(invA),
		.invB					(invB),
		.Cin					(Cin),
		.sign					(sign),
		.rorSel					(rorSel)
		);

	//
	// Execute Modules
	//
	output_ctrl ooutput_ctrl(
		//inputs
		.BTR					(BTR),
		.Carry					(Carry),
		.Ofl					(Ofl),
		.Zero					(Zero),
		.Neg					(Neg),
		.Set					(Set),
		.SetOp					(SetOp),
		.link					(link),
		.SLBI					(SLBI),
		.LBI					(LBI),
		//output
		.OutSel					(OutSel)
		);

	alu a0(
		// Outputs
		.Out					(aluOut[15:0]),
		.Ofl					(Ofl),
		.Zero					(Zero),
		// Inputs
		.A						(A[15:0]),
		.B						(B[15:0]),
		.Cin					(Cin),
		.Op						(Op[2:0]),
		.invA					(invA),
		.invB					(invB),
		.sign					(sign),
		.Carry					(Carry),
		.Neg					(Neg)
		);

	//
	// Memory Modules
	//
	memory2c data_memory(
		//Output
		.data_out				(Dataout[15:0]),
		//Inputs
		.data_in				(Datain[15:0]),
		.addr					(Out[15:0]),
		.enable					(DMemEn),
		.wr						(DMemWrite),
		.createdump				(Createdump),
		.clk					(clk),
		.rst					(rst)
		);

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
