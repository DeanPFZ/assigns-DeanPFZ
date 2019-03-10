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
                SESel,
                RegWrite,
                DMemWrite,
                DMemEn,
                ALUSrc2,
                PCSrc,
                PCImm,
                MemToReg,
                DMemDump,
                Jump,
                // Inputs
                OpCode,
                Funct
                );

   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   
   // outputs
   output       err;
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc, 
                PCImm, MemToReg, DMemDump, Jump;
   output [1:0] RegDst;
   output [2:0] SESel;

   assign SESel[2] = OpCode[2] | (OpCode[4]&OpCode[3]);
   assign SESel[1] = OpCode[4]&OpCode[0] | ~OpCode[4]&~OpCode[2]&~OpCode[1] | ~OpCode[3]&~OpCode[2]&~OpCode[1] | ~OpCode[4]&~OpCode[3]&~OpCode[0];
   assign SESel[0] = ~OpCode[3];
   assign Jump = ~OpCode[4]&~OpCode[3]&OpCode[2]&OpCode[0];
   assign PCImm = ~OpCode[4]&~OpCode[3]&OpCode[2]&~OpCode[0];
   assign DMemDump = ~OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];
   assign MemToReg = OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&OpCode[0];
   assign PCSrc = ~OpCode[4]&OpCode[2] | ~OpCode[4]&~OpCode[3];
   assign ALUSrc2 = OpCode[3]&OpCode[2] | OpCode[4]&OpCode[3]&OpCode[0] | OpCode[4]&OpCode[3]&OpCode[1];
   assign DMemEn = OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1] | OpCode[4]&~OpCode[3]&~OpCode[2]&OpCode[0];
   assign DMemWrite = OpCode[4]&~OpCode[3]&~OpCode[2]&OpCode[1]&OpCode[0] | OpCode[4]&~OpCode[3]&~OpCode[2]&~OpCode[1]&~OpCode[0];
   assign RegDst[1] = (~OpCode[4] & ~OpCode[3]) 
					| (~OpCode[3] & ~OpCode[2] & OpCode[1] & ~OpCode[0])
	   				| (OpCode[4] & OpCode[3] & ~OpCode[2] & ~OpCode[1] & ~OpCode[0]);
   assign RegDst[0] = ~OpCode[4] | (~OpCode[3] & ~OpCode[1]) | (~OpCode[3] & OpCode[0]) | (~OpCode[3] & OpCode[2]);

   // OpCode[4:0] = 5'bABCDE
   // y = BC' + AE + AD + AC + B'CD
   assign RegWrite = (OpCode[3] & ~OpCode[2]) 
					| (OpCode[4] & OpCode[0]) 
					| (OpCode[4] & OpCode[1])
					| (OpCode[4] & OpCode[2])
					| (~OpCode[3] & OpCode[2] & OpCode[1]);
	
   assign err = (^OpCode===1'bx)|(^Funct===1'bx);
endmodule
