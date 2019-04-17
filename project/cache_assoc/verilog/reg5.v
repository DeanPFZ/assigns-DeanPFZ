module reg5(q,d,clk,rst);
	
   input[4:0] d;
   input clk,rst;
   output[4:0] q;
   
   dff bit0(.q(q[0]), .d(d[0]), .clk(clk), .rst(rst));
   dff bit1(.q(q[1]), .d(d[1]), .clk(clk), .rst(rst));
   dff bit2(.q(q[2]), .d(d[2]), .clk(clk), .rst(rst));
   dff bit3(.q(q[3]), .d(d[3]), .clk(clk), .rst(rst));
   dff bit4(.q(q[4]), .d(d[4]), .clk(clk), .rst(rst));
  
endmodule
