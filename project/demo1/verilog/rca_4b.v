/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    Author: Hele Sha
    a 4-bit RCA module
*/
module rca_4b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;
	
	wire[2:0] carry;
	
    fullAdder_1b addBit0(.A(A[0]), .B(B[0]), .C_in(C_in), .S(S[0]), .C_out(carry[0]));
	fullAdder_1b addBit1(.A(A[1]), .B(B[1]), .C_in(carry[0]), .S(S[1]), .C_out(carry[1]));
	fullAdder_1b addBit2(.A(A[2]), .B(B[2]), .C_in(carry[1]), .S(S[2]), .C_out(carry[2]));
	fullAdder_1b addBit3(.A(A[3]), .B(B[3]), .C_in(carry[2]), .S(S[3]), .C_out(C_out));
	
endmodule
