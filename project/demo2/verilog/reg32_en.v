module reg32_en(q,d,clk,rst,en);
   input[31:0] d;
   input clk,rst,en;
   output[31:0] q;

   reg16_en iReg0(.q(q[15:0]), .d(d[15:0]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg1(.q(q[31:16]), .d(d[31:16]), .clk(clk), .rst(rst), .en(en));
			
endmodule
