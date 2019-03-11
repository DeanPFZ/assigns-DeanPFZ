/*
    CS/ECE 552 Spring '19
    Homework #4, Problem 2
	Author: Hele Sha, Pengfei Zhu, Adams Czech
    A 16-bit ALU module.  It is designed to choose
    the correct operation to perform on 2 16-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the 16-bit result
    of the operation, as well as output a Zero bit and an Overflow
    (OFL) bit.
*/
module alu (A, B, Cin, Op, invA, invB, sign, Out, Zero, Ofl, Carry, Neg);

   // declare constant for size of inputs, outputs (N),
   // and operations (O)
   parameter    N = 16;
   parameter    O = 3;

   input [N-1:0] A;
   input [N-1:0] B;
   input         Cin;
   input [O-1:0] Op;
   input         invA;
   input         invB;
   input         sign;
   output [N-1:0] Out;
   output         Ofl;
   output         Zero;
   output 		  Carry;
   output		  Neg;

   wire Cout, Add, And, Or, Xor, Shift;
   wire [N-1:0] OpA, OpB, shifter_out, adder_out;

   // Produce inverted signals upon invA/invB assertion
   assign OpA = invA?~A:A;
   assign OpB = invB?~B:B;

   // Decode the Opcode
   assign Shift = ~Op[O-1];
   assign Add = Op[O-1]?(~Op[O-2])&(~Op[O-3]):1'b0;
   assign And = Op[O-1]?(~Op[O-2])&Op[O-3]:1'b0;
   assign Or = Op[O-1]?Op[O-2]&(~Op[O-3]):1'b0;
   assign Xor = Op[O-1]?Op[O-2]&Op[O-3]:1'b0;

   // initialize barrelShifter (from Problem 1) and ripple carry adder (from HW3)
   barrelShifter shifter(.In(OpA), .Cnt(OpB[3:0]), .Op(Op[1:0]), .Out(shifter_out));
   rca_16b adder(.A(OpA), .B(OpB), .C_in(Cin), .S(adder_out), .C_out(Cout));

   assign Out = Shift?shifter_out:				// if it is a shift operation, the output will come from the shifter
				Add?adder_out:					// if it is an addition, the output will come from the RCA
				And?OpA&OpB:					// bitwise AND
				Or?OpA|OpB:						// bitwise OR
				Xor?OpA^OpB:					// bitwise XOR
				16'h0000;						// default, should never reach

	assign Ofl = (Op==3'b100)?(sign?(Out[N-1]&(~OpA[N-1])&(~OpB[N-1]))|(~Out[N-1]&OpA[N-1]&OpB[N-1]):Cout):1'b0; // if not addition, Ofl will stay low
	assign Zero = ~|Out;
	assign Carry = Cout;
	assign Neg = Out[N-1];

endmodule
