/*
    CS/ECE 552 Spring '19
    Homework #4, Problem 1

    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the Op() value that is passed in (2 bit number).  It uses these
    shifts to shift the value any number of bits between 0 and 15 bits.
 */
module barrelShifter (In, Cnt, Op, Out);

   // declare constant for size of inputs, outputs (N) and # bits to shift (C)
   parameter   N = 16;
   parameter   C = 4;
   parameter   O = 2;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   input [O-1:0]   Op;
   output [N-1:0]  Out;

   wire [N-1:0] cntlvl_0, cntlvl_1, cntlvl_2, cntlvl_3, oplvl_1;

																					// If Cnt[0] = 1, do following to In for 1 bit
   assign cntlvl_0 = Cnt[0]?(Op[1]?(Op[0]?{1'b0,In[N-1:1]}							// Op=11, srl
										 :{In[N-1],In[N-1:1]})						// Op=10, shift right arithmetic
								  :(Op[0]?{In[N-2:0],1'b0}							// Op=01, shift left
										 :{In[N-2:0],In[N-1]}))						// Op=00, rotate left
						   :In;														// No-op if Cnt[0] = 0

																					// If Cnt[1] = 1, do following to cntlvl_0 for 2 bit
   assign cntlvl_1 = Cnt[1]?(Op[1]?(Op[0]?{2'b00,cntlvl_0[N-1:2]}					// Op=11, srl
										 :{{2{cntlvl_0[N-1]}},cntlvl_0[N-1:2]})		// Op=10, shift right arithmetic
								  :(Op[0]?{cntlvl_0[N-3:0],2'b00}					// Op=01, shift left
									     :{cntlvl_0[N-3:0],cntlvl_0[N-1:N-2]}))		// Op=00, rotate left
						   :cntlvl_0;												// No-op if Cnt[1] = 0

																					// If Cnt[2] = 1, do following to cntlvl_1 for 4 bit
   assign cntlvl_2 = Cnt[2]?(Op[1]?(Op[0]?{4'h0,cntlvl_1[N-1:4]}					// Op=11, srl
										 :{{4{cntlvl_1[N-1]}},cntlvl_1[N-1:4]})		// Op=10, shift right arithmetic
								  :(Op[0]?{cntlvl_1[N-5:0],4'h0}					// Op=01, shift left
										 :{cntlvl_1[N-5:0],cntlvl_1[N-1:N-4]}))		// Op=00, rotate left
						   :cntlvl_1;												// No-op if Cnt[2] = 0

																					// If Cnt[3] = 1, do following to cntlvl_2 for 8 bit
   assign cntlvl_3 = Cnt[3]?(Op[1]?(Op[0]?{8'h00,cntlvl_2[N-1:8]}					// Op=11, srl
										 :{{8{cntlvl_2[N-1]}},cntlvl_2[N-1:8]})		// Op=10, shift right arithmetic
								  :(Op[0]?{cntlvl_2[N-9:0],8'h00}					// Op=01, shift left
									     :{cntlvl_2[N-9:0],cntlvl_2[N-1:N-8]}))		// Op=00, rotate left
						   :cntlvl_2;												// No-op if Cnt[3] = 0
   assign Out = cntlvl_3;

endmodule
