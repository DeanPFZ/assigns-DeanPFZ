module reg16_en(q,d,clk,rst,en);
   input[15:0] d;
   input clk,rst,en;
   output[15:0] q;
   
   wire[15:0] actual_input;
   assign actual_input = en?d:q;
   
   reg16 iReg(.q(q), .d(actual_input), .clk(clk), .rst(rst));
endmodule