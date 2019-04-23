/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    Author: Hele Sha
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

	wire AB_n, AC_n, BC_n;
	
    xor3 ixor(.in1(A), .in2(B), .in3(C_in), .out(S)); 
	nand2 nandAB(.in1(A), .in2(B), .out(AB_n));
	nand2 nandAC(.in1(A), .in2(C_in), .out(AC_n));
	nand2 nandBC(.in1(B), .in2(C_in), .out(BC_n));
	nand3 inand(.in1(AB_n), .in2(AC_n), .in3(BC_n), .out(C_out));
	
endmodule
