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
   
   wire cache_enable, cache_comp, cache_wr, cache_valid_in; 
   wire cache_dirty, cache_valid, cache_hit, cache_err;
	wire [15:0] cache_data_out;
	wire [15:0] cache_data_in;
	wire [4:0] cache_tag_in;
	wire [4:0] cache_tag_out;
	wire [7:0] cache_index;
	wire [2:0] cache_offset;
	wire [15:0] mem_data_in, mem_data_out, mem_addr;
   wire mem_wr, mem_rd, mem_stall, mem_err;
	wire [3:0]  mem_busy;
   wire fsm_err, fsm_stall, fsm_done, fsm_hit;
   
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

	cache_fsm fsm(// Output
					.fsm_done			(fsm_done),
					.cache_data_in		(cache_data_in),
					.cache_comp			(cache_comp),
					.cache_enable		(cache_enable),
					.cache_wr			(cache_wr),
					.cache_valid_in		(cache_valid_in),
					.fsm_stall			(fsm_stall),
					.fsm_err			(fsm_err),
					.cache_tag_in		(cache_tag_in),
					.cache_index		(cache_index),
					.cache_offset		(cache_offset),
					.mem_addr			(mem_addr),
					.mem_wr				(mem_wr),
					.mem_rd				(mem_rd),
					.mem_data_in		(mem_data_in),
					.fsm_hit			(fsm_hit),
					// Input
					.DataIn				(DataIn),
					.cache_data_out		(cache_data_out),
					.cache_hit			(cache_hit),
					.cache_dirty		(cache_dirty),
					.cache_valid		(cache_valid),
					.Addr				(Addr),
					.Rd					(Rd),
					.Wr					(Wr),
					.clk				(clk),
					.rst				(rst),
					.cache_tag_out		(cache_tag_out),
					.mem_DataOut		(mem_data_out));


   
	assign DataOut = cache_data_out;
	assign Done = fsm_done;	
	assign CacheHit = fsm_hit;
	assign Stall = fsm_stall|mem_stall;
    assign err = (Addr[0]==1'b1)|fsm_err|cache_err|mem_err;

endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
