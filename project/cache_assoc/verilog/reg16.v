module reg16(q,d,clk,rst);
	
   input[15:0] d;
   input clk,rst;
   output[15:0] q;
   
   dff bit0(.q(q[0]), .d(d[0]), .clk(clk), .rst(rst));
   dff bit1(.q(q[1]), .d(d[1]), .clk(clk), .rst(rst));
   dff bit2(.q(q[2]), .d(d[2]), .clk(clk), .rst(rst));
   dff bit3(.q(q[3]), .d(d[3]), .clk(clk), .rst(rst));
   dff bit4(.q(q[4]), .d(d[4]), .clk(clk), .rst(rst));
   dff bit5(.q(q[5]), .d(d[5]), .clk(clk), .rst(rst));
   dff bit6(.q(q[6]), .d(d[6]), .clk(clk), .rst(rst));
   dff bit7(.q(q[7]), .d(d[7]), .clk(clk), .rst(rst));
   dff bit8(.q(q[8]), .d(d[8]), .clk(clk), .rst(rst));
   dff bit9(.q(q[9]), .d(d[9]), .clk(clk), .rst(rst));
   dff bit10(.q(q[10]), .d(d[10]), .clk(clk), .rst(rst));
   dff bit11(.q(q[11]), .d(d[11]), .clk(clk), .rst(rst));
   dff bit12(.q(q[12]), .d(d[12]), .clk(clk), .rst(rst));
   dff bit13(.q(q[13]), .d(d[13]), .clk(clk), .rst(rst));
   dff bit14(.q(q[14]), .d(d[14]), .clk(clk), .rst(rst));
   dff bit15(.q(q[15]), .d(d[15]), .clk(clk), .rst(rst));
  
endmodule