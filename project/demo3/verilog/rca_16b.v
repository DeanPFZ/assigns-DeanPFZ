/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    Author: Hele Sha
    a 16-bit RCA module
*/
module rca_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;

	wire[2:0] carry;

  rca_4b addBit0_3(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .S(S[3:0]), .C_out(carry[0]));
	rca_4b addBit4_7(.A(A[7:4]), .B(B[7:4]), .C_in(carry[0]), .S(S[7:4]), .C_out(carry[1]));
	rca_4b addBit8_11(.A(A[11:8]), .B(B[11:8]), .C_in(carry[1]), .S(S[11:8]), .C_out(carry[2]));
	rca_4b addBit12_15(.A(A[15:12]), .B(B[15:12]), .C_in(carry[2]), .S(S[15:12]), .C_out(C_out));

endmodule
