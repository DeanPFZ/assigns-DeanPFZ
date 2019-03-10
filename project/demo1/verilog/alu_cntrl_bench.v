/*

	ALU Control Testbench

	This testbench runs each opcode through the control logic and checks the ALU
	signals are what we expect.

*/
module alu_cntrl_bench(/*AUTOARG*/);

   	wire		clk;
   	wire  		rst;
   	wire  		err;
   	reg[4:0]	opCode;
   	reg[1:0]	funct;
   	wire[2:0]	aluOp;
   	wire		invA;
   	wire		invB;
   	wire		Cin;
   	wire		sign;
   	wire		rorSel;
   
   	integer counter;

   	// stimulus in register
	reg [14:0] stim;

	// stimulus memory
	reg [14:0] stimMem [0:38];


	// Modules
	clkrst CLK (.clk(clk), .rst(rst), .err(err));
	alu_cntrl iDUT(.opCode(opCode), .funct(funct), .aluOp(aluOp), .invA(invA), 
					.invB(invB), .Cin(Cin), .sign(sign), .rorSel(rorSel));

   
	initial begin 	
		$readmemb("./alu_cntrl_stim.bin", stimMem);
		
		for (counter = 0; counter < 38; counter = counter + 1) begin
			stim = stimMem[counter];
			// Set the inputs
			opCode = stim[14:10];
			funct = stim[9:8];
			@(posedge clk);
			#1;
			
			// Check the output
			if ({opCode, funct, aluOp, invA, invB, Cin, sign, rorSel} != stim) begin
				$display("Failure: stim: %b, resp: %b, counter: %d",
							stim, {opCode, funct, aluOp, invA, invB, Cin, sign, rorSel}, counter);
				$finish();
			end else begin
				$display("Success: stim: %b, resp: %b, counter: %d",
							stim, {opCode, funct, aluOp, invA, invB, Cin, sign, rorSel}, counter);
			end
		end
		$display("Test Passed!");
		$finish();
		
	end
	

endmodule // alu_cntrl_bench
