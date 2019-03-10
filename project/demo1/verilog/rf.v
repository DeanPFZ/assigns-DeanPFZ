/*
   CS/ECE 552, Spring '19
   Homework #5, Problem #1
   Authors: Hele Sha, Pengfei Zhu, Adam Czech
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module rf (
           // Outputs
           readData1, readData2, err,
           // Inputs
           clk, rst, readReg1Sel, readReg2Sel, writeRegSel, writeData, writeEn
           );
   
   input        clk, rst;
   input [2:0]  readReg1Sel;
   input [2:0]  readReg2Sel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] readData1;
   output [15:0] readData2;
   output        err;
	
   wire [15:0] q0,q1,q2,q3,q4,q5,q6,q7,d0,d1,d2,d3,d4,d5,d6,d7;
   // decode write select and choose whether to update or recirculate
   assign d0 = writeEn?((writeRegSel==3'h00)?writeData:q0):q0;
   assign d1 = writeEn?((writeRegSel==3'h01)?writeData:q1):q1;
   assign d2 = writeEn?((writeRegSel==3'h02)?writeData:q2):q2;
   assign d3 = writeEn?((writeRegSel==3'h03)?writeData:q3):q3;
   assign d4 = writeEn?((writeRegSel==3'h04)?writeData:q4):q4;
   assign d5 = writeEn?((writeRegSel==3'h05)?writeData:q5):q5;
   assign d6 = writeEn?((writeRegSel==3'h06)?writeData:q6):q6;
   assign d7 = writeEn?((writeRegSel==3'h07)?writeData:q7):q7;
   // select the output
   assign readData1 = (readReg1Sel==3'h0)?q0:
					  (readReg1Sel==3'h1)?q1:
   					  (readReg1Sel==3'h2)?q2:
					  (readReg1Sel==3'h3)?q3:
					  (readReg1Sel==3'h4)?q4:
					  (readReg1Sel==3'h5)?q5:
					  (readReg1Sel==3'h6)?q6:
					  (readReg1Sel==3'h7)?q7:
					  16'h0000;	// this should never be assigned
					  
   assign readData2 = (readReg2Sel==3'h0)?q0:
					  (readReg2Sel==3'h1)?q1:
   					  (readReg2Sel==3'h2)?q2:
					  (readReg2Sel==3'h3)?q3:
					  (readReg2Sel==3'h4)?q4:
					  (readReg2Sel==3'h5)?q5:
					  (readReg2Sel==3'h6)?q6:
					  (readReg2Sel==3'h7)?q7:
					  16'h0000; // this should never be assigned
   // if any of the input has unknown values, assert err
   assign err = (^writeData===1'bx)|(^writeRegSel===1'bx)|(^readReg1Sel===1'bx)
				|(^readReg2Sel===1'bx)|(writeEn===1'bx)|(clk===1'bx)|(rst===1'bx);
   // instantiate registers			
   reg16 r0(.q(q0), .d(d0), .clk(clk), .rst(rst));
   reg16 r1(.q(q1), .d(d1), .clk(clk), .rst(rst));
   reg16 r2(.q(q2), .d(d2), .clk(clk), .rst(rst));
   reg16 r3(.q(q3), .d(d3), .clk(clk), .rst(rst));
   reg16 r4(.q(q4), .d(d4), .clk(clk), .rst(rst));
   reg16 r5(.q(q5), .d(d5), .clk(clk), .rst(rst));
   reg16 r6(.q(q6), .d(d6), .clk(clk), .rst(rst));
   reg16 r7(.q(q7), .d(d7), .clk(clk), .rst(rst));

endmodule
