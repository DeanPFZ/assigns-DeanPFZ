module reg64_en(q,d,clk,rst,en);
   input[63:0] d;
   input clk,rst,en;
   output[63:0] q;
   
   wire [63:0] d_tmp; 	

   assign d_tmp = (en) ? d : q;

   reg16_en iReg0(.q(q[15:0]), .d(d_tmp[15:0]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg1(.q(q[31:16]), .d(d_tmp[31:16]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg2(.q(q[47:32]), .d(d_tmp[47:32]), .clk(clk), .rst(rst), .en(en));
   reg16_en iReg3(.q(q[63:48]), .d(d_tmp[63:48]), .clk(clk), .rst(rst), .en(en));
			
endmodule
