/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
    // Outputs
    err,
    // Inputs
    clk, rst
    );

    input clk;
    input rst;

    output err;

    // None of the above lines can be modified

    // OR all the err ouputs for every sub-module and assign it as this
    // err output

    // As desribed in the homeworks, use the err signal to trap corner
    // cases that you think are illegal in your statemachines
    wire [15:0] pre_PC;
    wire [15:0] post_PC;
    wire HaltPC;
    wire [15:0] PC2;
    wire [15:0] PC2_after;
    wire [15:0] PC2_back;


    wire [15:0] instruction;
    wire [4:0] OpCode;
    wire [1:0] Funct;
    wire [2:0] Rs;
    wire [2:0] Rt;
    wire [4:0] Imm5;
    wire [7:0] Imm8;
    wire [10:0] ImmDis;

    //control (OpCode and Funct are inputs)
    wire RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc,
    PCImm, MemToReg, DMemDump, Jump;
    wire [1:0] RegDst;
    wire [2:0] SESel;

	wire link, disp, Branch;


    //register file
    wire [2:0]  readReg1Sel;
    wire [2:0]  readReg2Sel;
    wire [2:0]  writeRegSel;
    wire [15:0] writeData;
    wire        writeEn;

    wire [15:0] readData1;
    wire [15:0] readData2;

    //alu
    wire [15:0] A;
    wire [15:0] B;
    wire Cin;
    wire [2:0] Op;
    wire invA;
    wire invB;
    wire sign;


    wire [15:0] Out;
    wire Ofl;
    wire Zero;


    //memory (enable is DMemWrite, wr is DMemEn, addr is Addr[15:0])
    wire [15:0] Datain;
    wire Createdump;
	wire [15:0] Addr;

    wire [15:0] Dataout;




    assign OpCode[4:0] = instruction[15:11];
    assign Funct[1:0] = instruction[1:0];
    assign Rs[2:0] = instruction[10:8];
    assign Rt[2:0] = instruction[7:5];
    assign Imm5[4:0] = instruction[4:0];
    assign Imm8[7:0] = instruction[7:0];
    assign ImmDis[10:0] = instruction[10:0];

    //pc logic
    reg16 regPC(.q(pre_PC[15:0]), .d(post_PC[15:0]), .clk(clk), .rst(rst));
    wire CO_temp1, CO_temp2;
    rca_16b add1(.A(post_PC[15:0]), .B(15'b010), .C_in(0),.S(PC2), .C_out(CO_temp1));
    assign PC2_after[15:0] = (link)? readData1[15:0] : PC2[15:0];
    wire [15:0] after_disp;
    wire [15:0] added;
    rca_16b add2(.A(after_disp[15:0]), .B(PC2_after[15:0]), .C_in(0),.S(added[15:0]), .C_out(CO_temp2));
    assign PC2_back[15:0] = PCSrc? added[15:0] : PC2_after[15:0];
    assign after_disp[15:0] = disp? {{4{ImmDis[10]}},ImmDis[10:0]} : {{7{Imm8}},Imm8[7:0]};
    assign pre_PC[15:0] = HaltPC? post_PC : PC2_back;

    //rf
 	assign writeRegSel[1:0] =
 			(RegDst[1:0] == 2'b00)? Rs:
 			(RegDst[1:0] == 2'b01)? Rt:
 			(RegDst[1:0] == 2'b10)? instruction[4:2]:
 			(RegDst[1:0] == 2'b11)? 3'b111 : 3'b000; //3'b000 should never happen
 	assign readReg1Sel[2:0] = Rs[2:0];
 	assign readReg2Sel[2:0] = Rt[2:0];
 	assign writeData = MemToReg? Dataout[15:0] : Out[15:0];
 	assign writeEn = RegWrite;

 	//alu
   	wire rorSel;
 	wire [15:0] before_ROR;
 	wire [15:0] after_ROR;
 	wire [15:0] after_Branch;
 	wire CO_temp3;
 	rca_16b add3(.A(16'h0010), .B(~{{11{1'b0}},readData2[3:0]}), .C_in(1), .S(before_ROR[15:0]), .C_out(CO_temp3));

 	assign after_ROR[15:0] = rorSel? before_ROR[15:0] : readData2[15:0];
 	assign after_Branch[15:0] = Branch? readData1[15:0] : after_ROR[15:0];
 	assign B[15:0] = ALUSrc2? {{11{Imm5[4]}}, Imm5[4:0]} : after_Branch;
 	assign A[15:0] = readData1[15:0];

 	//data memory
 	assign Datain[15:0] = readData2[15:0];
 	assign Addr[15:0] = Out[15:0];//Out is ALU output
 	assign Createdump = (HaltPC);




    /* your code here */
    control c0(
               // Outputs
				.err                          (err),
				.RegDst                       (RegDst),
				.RegWrite                     (RegWrite),
				.DMemWrite                    (DMemWrite),
				.DMemEn                       (DMemEn),
				.ALUSrc2                      (ALUSrc2),
				.PCImm                        (PCImm),
				.MemToReg                     (MemToReg),
				.DMemDump                     (DMemDump),
				.Jump                         (Jump),
				//our implementation
				.Set						  (Set),
				.SetOp						  (SetOp),
				.Branch						  (Branch),
				.BranchOp					  (BranchOp),
				.disp						  (disp),
				.HaltPC						  (HaltPC),
				.BTR						  (BTR),
				.SLBI						  (SLBI),
				.LBI						  (LBI),
				.link						  (link),
				// Inputs
				.OpCode                       (OpCode)
 			  );
 	alu_cntrl alu_c0(
			//inputs
           .opCode							(OpCode),
 		   .funct							(Funct),
		   //outputs
     	   .aluOp							(Op),
           .invA							(invA),
           .invB							(invB),
           .Cin								(Cin),
           .sign							(sign),
           .rorSel							(rorSel)
		  );
	output_ctrl ooutput_ctrl(
			.BTR							(BTR),
			.Carry							(Carry),
			.Ofl							(Ofl),
			.Zero							(Zero),
			.Neg							(Neg),
			.Set							(Set),
			.SetOp							(SetOp),
			.link							(link),
			.SLBI							(SLBI),
			.LBI							(LBI),
			.OutSel							(OutSel)
			);
 	rf rf0(
           // Outputs
           .readData1                    (readData1[15:0]),
           .readData2                    (readData2[15:0]),
           .err                          (err),
           // Inputs
           .clk                          (clk),
           .rst                          (rst),
           .readReg1Sel                  (readReg1Sel[2:0]),
           .readReg2Sel                  (readReg2Sel[2:0]),
           .writeRegSel                  (writeRegSel[2:0]),
           .writeData                    (writeData[15:0]),
           .writeEn                      (writeEn)
 		  );
 	alu a0(
           // Outputs
           .Out                          (Out[15:0]),
           .Ofl                          (Ofl),
           .Zero                         (Zero),
           // Inputs
           .A                            (A[15:0]),
           .B                            (B[15:0]),
           .Cin                          (Cin),
           .Op                           (Op[2:0]),
           .invA                         (invA),
           .invB                         (invB),
           .sign                         (sign)
          );

 	memory2c instruction_memory(
 		//Output
 		.data_out						(instruction[15:0]),
 		//Inputs
 		.data_in						(16'b0),
 		.addr							(post_PC[15:0]),
 		.enable							(0),
 		.wr								(1),
 		.createdump						(0),
 		.clk							(clk),
 		.rst							(rst));
 	memory2c data_memory(
 		//Output
 		.data_out						(Dataout[15:0]),
 		//Inputs
 		.data_in						(Datain[15:0]),
 		.addr							(Addr[15:0]),
 		.enable							(DMemWrite),
 		.wr								(DMemEn),
 		.createdump						(Createdump),
 		.clk							(clk),
 		.rst							(rst));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
