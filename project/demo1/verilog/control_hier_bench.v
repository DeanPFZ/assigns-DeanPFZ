/*
   CS/ECE 552, Spring '19
   Homework #6, Problem #1
   Author: Hele Sha, Pengfei Zhu, Adam Czech
   This module tests the control logic for the processor.
*/
module control_hier_bench(/*AUTOARG*/);
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire       err;
   wire       RegWrite, DMemWrite,              // From top of control_hier.v
              DMemEn, ALUSrc2, PCImm,    // From top of control_hier.v
              MemToReg, DMemDump, Jump, Set, Branch, disp, HaltPC,
			  BTR, SLBI, LBI, link;         // From top of control_hier.v
   wire [1:0] RegDst, SetOp, BranchOp;                           // From top of control_hier.v
   wire [2:0] SESel;                            // From top of control_hier.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [4:0]  OpCode;                           // To top of control_hier.v
   reg [1:0]  Funct;                            // To top of control_hier.v
   // End of automatics

   integer    cycle_count;

   wire       clk;
   wire       rst;

   
   integer counter;
   // stimulus in register
	reg [29:0] stim;

	// stimulus memory
	reg [29:0] stimMem [0:38];

   // Instantiate the module we want to verify

	clkrst CLK (.clk(clk), .rst(rst), .err(err));
   
   control_hier DUT(/*AUTOINST*/
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

   
	initial begin 	
		$readmemb("./stimulus_final.bin", stimMem);
		Funct = 2'b00;
		
		for (counter = 0; counter < 38; counter = counter + 1) begin
			stim = stimMem[counter];
			OpCode = stim[29:25];
			@(posedge clk);
			#1;
			
			if ({OpCode, ALUSrc2, SESel, RegDst, RegWrite, DMemEn, MemToReg, DMemWrite, DMemDump, PCImm, Jump, Set, SetOp, Branch, BranchOp, disp, HaltPC, BTR, SLBI, LBI, link, err} != {stim,1'b0}) begin
				$display("Failure: stim: %b, resp: %b, counter: %d",
							stim, {OpCode, ALUSrc2, SESel, RegDst, RegWrite, DMemEn, MemToReg, DMemWrite, DMemDump, PCImm, Jump, Set, SetOp, Branch, BranchOp, disp, HaltPC, BTR, SLBI, LBI, link}, counter);
				$finish();
			end
		end
		$display("Test Passed!");
		$finish();
		
	end
	

endmodule // control_hier_bench
