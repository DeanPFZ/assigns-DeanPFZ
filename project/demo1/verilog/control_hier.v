/*
   CS/ECE 552, Spring '19
   Homework #6, Problem #1
  
   Wrapper module around global control logic.

   YOU SHALL NOT EDIT THIS FILE. ANY CHANGES TO THIS FILE WILL
   RESULT IN ZERO FOR THIS PROBLEM.
*/
module control_hier (/*AUTOARG*/
                     // Outputs
                     err, 
                     RegDst,
                     SESel,
                     RegWrite,
                     DMemWrite,
                     DMemEn,
                     ALUSrc2,
                     PCImm,
                     MemToReg,
                     DMemDump,
                     Jump,
					 Set,
					 SetOp,
					 Branch,
					 BranchOp,
					 disp,
					 HaltPC,
	   				 BTR,
					 SLBI,
					 LBI,
					 link,
                     // Inputs
                     OpCode,
                     Funct
                     );

   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   
   // outputs
   output       err;
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2, 
                PCImm, MemToReg, DMemDump, Jump, Set, Branch, disp, HaltPC,
				BTR, SLBI, LBI, link;
   output [1:0] RegDst, SetOp, BranchOp;
   output [2:0] SESel;

   wire         clk, rst, errClkRst;

   // Ignore errClkRst for now
   clkrst clk_generator(.clk(clk), .rst(rst), .err(errClkRst) );
   control c0(
              // Outputs
                    .err                          (err),
                    .RegDst                       (RegDst),
                    .SESel                        (SESel),
                    .RegWrite                     (RegWrite),
                    .DMemWrite                    (DMemWrite),
                    .DMemEn                       (DMemEn),
                    .ALUSrc2                      (ALUSrc2),
                    .PCImm                        (PCImm),
                    .MemToReg                     (MemToReg),
                    .DMemDump                     (DMemDump),
                    .Jump                         (Jump),
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
                    .OpCode                       (OpCode),
                    .Funct                        (Funct));

endmodule
