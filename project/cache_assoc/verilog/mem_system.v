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

	//
	// Internal signals
	//
	wire evict_sel;
	wire vict_in, vict_out;

	// generalized cache signals for fsm
    wire cache_enable, cache_comp, cache_wr, cache_valid_in; 
    wire cache_dirty, cache_valid, cache_hit, cache_err;
	wire [15:0] cache_data_out;
	wire [15:0] cache_data_in;
	wire [4:0] cache_tag_in;
	wire [4:0] cache_tag_out;
	wire [7:0] cache_index;
	wire [2:0] cache_offset;
	// mem & fsm signals
	wire [15:0] mem_data_in, mem_data_out, mem_addr;
    wire mem_wr, mem_rd, mem_stall, mem_err;
	wire [3:0]  mem_busy;
    wire fsm_err, fsm_stall, fsm_done, fsm_hit;
	wire [4:0] fsm_state;

	// Cache 0 signals
	wire [4:0] cache_tag_out_0;
	wire [15:0] cache_data_out_0;
	wire cache_hit_0;
	wire cache_dirty_0;
	wire cache_valid_0;
	wire cache_err_0;
	wire cache_wr_0;

	// Cache 1 signals
	wire [4:0] cache_tag_out_1;
	wire [15:0] cache_data_out_1;
	wire cache_hit_1;
	wire cache_dirty_1;
	wire cache_valid_1;
	wire cache_err_1;
	wire cache_wr_1;

	//
	// Victimway flipflop 
	//
	dff victimway(.q(vict_out), .d(vict_in), .clk(clk), .rst(rst));
	assign vict_in = (Rd | Wr) ? ~vict_out : vict_out;


	// TODO: Assign outputs




   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out            	(cache_tag_out_0),
                          .data_out           	(cache_data_out_0),
                          .hit                	(cache_hit_0),
                          .dirty              	(cache_dirty_0),
                          .valid              	(cache_valid_0),
                          .err                	(cache_err_0),
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
                          .write              	(cache_wr_0),
                          .valid_in             (cache_valid_in));
						  
   cache #(2 + memtype) c1(// Outputs
                          .tag_out            	(cache_tag_out_1),
                          .data_out           	(cache_data_out_1),
                          .hit                	(cache_hit_1),
                          .dirty              	(cache_dirty_1),
                          .valid              	(cache_valid_1),
                          .err                	(cache_err_1),
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
                          .write              	(cache_wr_1),
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
					.state              (fsm_state),
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


    assign cache_err = cache_err_0 | cache_err_1;
	assign cache_data_out = cache_hit_0 ? cache_data_out_0 : cache_data_out_1;
	assign DataOut = cache_data_out;
	assign Done = fsm_done;	
	assign CacheHit = fsm_hit;
	assign Stall = fsm_stall|mem_stall;
    assign err = (Addr[0]==1'b1)|fsm_err|cache_err|mem_err;

	assign cache_hit = (cache_tag_in == cache_tag_out_0) ? cache_hit_0 : cache_hit_1;

	// TODO: figure out what variable name Lemar gave to the "curr_state" of the FSM
	// REPLY from Lemar: No worries, I've figured that out.
	assign cache_valid = (fsm_state == 5'b00001) ? // CHECK_HIT state
					((cache_tag_in == cache_tag_out_0) ? cache_valid_0 : cache_valid_1) :
					((evict_sel) ? cache_valid_1: cache_valid_0);

	assign cache_dirty = evict_sel ? cache_dirty_1 : cache_dirty_0;
	assign cache_tag_out = evict_sel ? cache_tag_out_1 : cache_tag_out_0;

	assign evict_sel = (~cache_valid_0) ? 1'b0 :
						(~cache_valid_1) ? 1'b1 : vict_out;

	assign cache_wr_0 = cache_wr ? (cache_hit_0 | (~evict_sel)) : 1'b0;
	assign cache_wr_1 = cache_wr ? (cache_hit_1 | (~evict_sel)) : 1'b0;
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
