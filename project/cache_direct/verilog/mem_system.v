/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;
   
   wire [15:0] Addr_reg, DataIn_reg;
   wire [15:0] Addr_reg_in, DataIn_reg_in;
   wire Rd_reg, Wr_reg;
   wire Rd_reg_in, Wr_reg_in;
   reg cache_data_in, cache_enable, cache_tag_in, cache_index
       cache_offset, cache_comp, cache_wr, cache_valid_in; 
   wire cache_dirty, cache_valid, cache_hit,  
        cache_err, cache_data_out, cache_tag_out;
   reg mem_data_in, mem_wr, mem_rd, mem_addr, 
   wire mem_data_out, mem_stall, 
        mem_busy, mem_err;
   reg fsm_err, fsm_stall, fsm_data_out, fsm_done;
   reg [3:0] state, nxt_state;
   
   localparam IDLE = 4'b0000;
   localparam CHECK_HIT = 4'b0001;
   localparam GET_MEM_DATA = 4'b0010;
   localparam GET_MEM_WAIT = 4'b0011;
   localparam MEM_DATA_READY = 4'b0100;
   localparam WRITE_CACHE_WRITE = 4'b0101;
   localparam WRITE_BACK_MEM_WAIT_1 = 4'b0110;
   localparam WRITE_BACK_MEM_WAIT_2 = 4'b0111;
   localparam WRITE_BACK_MEM_WAIT_3 = 4'b1000;
   localparam WRITE_BACK_MEM_DONE = 4'b1001;
   
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cache_tag_out),
                          .data_out             (cache_data_out),
                          .hit                  (cache_hit),
                          .dirty                (cache_dirty),
                          .valid                (cache_valid),
                          .err                  (cache_err),
                          // Inputs
                          .enable               (cache_enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cache_tag_in),
                          .index                (cache_index),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write                (cache_wr),
                          .valid_in             (cache_valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (mem_busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (mem_data_in),
                     .wr                (mem_wr),
                     .rd                (mem_rd));

   
   // your code here
   assign DataOut = fsm_data_out;
   assign Done = fsm_done;
   assign Stall = fsm_stall|mem_stall;
   assign CacheHit = cache_hit;
   assign err = (Addr_reg[0]==1'b1)|fsm_err|cache_err|mem_err;
   
   always begin
      nxt_state = IDLE;
	  cache_enable = 1'b0;
	  cache_comp = 1'b0;
	  cache_wr = 1'b0;
	  cache_valid_in = 1'b1;
	  cache_data_in = DataIn_reg;
	  cache_tag_in = Addr_reg[15:11];
	  cache_index = Addr_reg[10:3];
	  cache_offset = Addr_reg[2:0];
	  mem_addr = Addr_reg;
	  mem_data_in = data_in;
	  mem_wr = 1'b0;
	  mem_rd = 1'b0;
	  fsm_err = 1'b0;
	  fsm_stall = 1'b0;
	  fsm_data_out = cache_data_out;
	  fsm_done = 1'b0;
      case(state)
	   IDLE: begin
	    fsm_err = Rd&Wr;
		cache_enable = Rd^Wr;
		cache_comp = Rd^Wr;
		cache_wr = ~Rd&Wr;
		nxt_state = (Rd^Wr)?CHECK_HIT:IDLE;
	   end
	   CHECK_HIT: begin
	    fsm_done = cache_hit & cache_valid;
		mem_data_in = (~cache_hit & cache_valid & cache_dirty)?cache_data_out:data_in;
		mem_wr = ~cache_hit & cache_valid & cache_dirty;
		mem_addr = (~cache_hit & cache_valid & cache_dirty)?{cache_tag_out,cache_index,cache_offset}:Addr_reg;
	   end
	  endcase
   end
  
   reg16 reg_Addr(.q(Addr_reg), .d(Addr_reg_in), .clk(clk), .rst(rst));
   reg16 reg_DataIn(.q(DataIn_reg), .d(DataIn_reg_in), .clk(clk), .rst(rst));
   dff reg_Rd(.q(Rd_reg), .d(Rd_reg_in), .clk(clk), .rst(rst));
   dff reg_Wr(.q(Wr_reg), .d(Wr_reg_in), .clk(clk), .rst(rst));
   reg4 reg_state(.q(state), .d(nxt_state), .clk(clk), .rst(rst));
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
