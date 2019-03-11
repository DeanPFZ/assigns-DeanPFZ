/*
   CS/ECE 552, Spring '19
   Homework #6, Problem #1
   Author: Hele Sha, Pengfei Zhu, Adam Czech
   This module determines all of the control logic for the processor.
*/
module control (/*AUTOARG*/
                // Outputs
                err,
                RegDst,
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
                OpCode
                );

   // inputs
   input [4:0]  OpCode;

   // outputs
   output       err;
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2,
                PCImm, MemToReg, DMemDump, Jump, Set, Branch, disp, HaltPC,
				BTR, SLBI, LBI, link;
   output [1:0] RegDst;
   output [1:0] SetOp, BranchOp;

   assign BTR = OpCode[4]&OpCode[3]&~OpCode[2]&~OpCode[1]&OpCode[0];
   assign SLBI = OpCode[4]&~OpCode[3]&~OpCode[2]&OpCode[1]&~OpCode[0];
   assign LBI = OpCode[4]&OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];
   assign link = (OpCode[4:0] == 5'b00110)? 0 : ~OpCode[4]&~OpCode[3]&OpCode[2]&OpCode[1];
   assign SetOp = OpCode[1:0];
   assign BranchOp = OpCode[1:0];
   assign HaltPC = DMemDump;
   assign Set = OpCode[4]&OpCode[3]&OpCode[2];
   assign Branch = ~OpCode[4]&OpCode[3]&OpCode[2];
   assign disp = ~OpCode[4]&~OpCode[3]&OpCode[2]&~OpCode[0];
   /*
   assign SESel[2] = OpCode[2] | (OpCode[4]&OpCode[3]);
   assign SESel[1] = OpCode[4]&OpCode[0] | ~OpCode[4]&~OpCode[2]&~OpCode[1] | ~OpCode[3]&~OpCode[2]&~OpCode[1] | ~OpCode[4]&~OpCode[3]&~OpCode[0];
   assign SESel[0] = ~OpCode[3];
   */
   assign Jump = ~OpCode[4]&~OpCode[3]&OpCode[2]&OpCode[0];
   assign PCImm = ~OpCode[4]&~OpCode[3]&OpCode[2]&~OpCode[0];
   assign DMemDump = ~OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];
   assign MemToReg = OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&OpCode[0];
   //assign PCSrc = ~OpCode[4]&OpCode[2] | ~OpCode[4]&~OpCode[3];
   assign ALUSrc2 = ~(OpCode[3]&OpCode[2] | OpCode[4]&OpCode[3]&OpCode[0] | OpCode[4]&OpCode[3]&OpCode[1]);
   assign DMemEn = OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1] | OpCode[4]&~OpCode[3]&~OpCode[2]&OpCode[0];
   assign DMemWrite = OpCode[4]&~OpCode[3]&~OpCode[2]&OpCode[1]&OpCode[0] | OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];
   assign RegDst[1] = (~OpCode[4] & ~OpCode[3])
					| (~OpCode[3] & ~OpCode[2] & OpCode[1] & ~OpCode[0])
	   				| (OpCode[4] & OpCode[3] & ~OpCode[2] & ~OpCode[1] & ~OpCode[0]);
   assign RegDst[0] = ~OpCode[4] | (~OpCode[3] & ~OpCode[1]) | (~OpCode[3] & OpCode[2]);

   // OpCode[4:0] = 5'bABCDE
   // y = BC' + AE + AD + AC + B'CD
   assign RegWrite = (OpCode[3] & ~OpCode[2])
					| (OpCode[4] & OpCode[0])
					| (OpCode[4] & OpCode[1])
					| (OpCode[4] & OpCode[2])
					| (~OpCode[3] & OpCode[2] & OpCode[1]);

   assign err = (^OpCode===1'bx);
endmodule
