module reg64_en(q,d,clk,rst,en);
   input[63:0] d;
   input clk,rst,en;
   output[63:0] q;

   reg16_en iReg0(.q(q[15:0]), .d(d[15:0]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg1(.q(q[31:16]), .d(d[31:16]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg2(.q(q[47:32]), .d(d[47:32]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg3(.q(q[63:48]), .d(d[63:48]), .clk(clk), .rst(rst), .en(en));
			
endmodule
