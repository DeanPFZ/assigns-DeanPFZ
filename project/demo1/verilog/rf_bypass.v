/*
   CS/ECE 552, Spring '19
   Homework #5, Problem #2
   Authors: Hele Sha, Pengfei Zhu, Adam Czech
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module rf_bypass (
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

   wire [15:0] rfOut1,rfOut2;
   // if reading and writing to the same register at the same time while writing is enabled, forward the data to be written to the 
   // corresponding output
   assign readData1 = writeEn?((readReg1Sel==writeRegSel)?writeData:rfOut1):rfOut1;
   assign readData2 = writeEn?((readReg2Sel==writeRegSel)?writeData:rfOut2):rfOut2;
   
   rf regFile(.readData1(rfOut1), .readData2(rfOut2), .err(err), .clk(clk), .rst(rst), .readReg1Sel(readReg1Sel), .readReg2Sel(readReg2Sel), .writeRegSel(writeRegSel), .writeData(writeData), .writeEn(writeEn));

endmodule
