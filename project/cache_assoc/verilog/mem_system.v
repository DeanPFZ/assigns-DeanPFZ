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
	wire hit, valid, dirty, evict_sel, cache_wr_0, cach_wr_1; 
	wire vict_in, vict_out;

	// Cache shared signals
	wire cache_enable;
	wire [15:0] cache_data_in;
	wire cache_comp;
	wire cache_valid_in;

	// Cache 0 signals
	wire [4:0] cache_tag_out_0;
	wire [15:0] cache_data_out_0;
	wire cache_hit_0;
	wire cache_dirty_0;
	wire cache_valid_0;
	wire cache_err_0;
	wire cache_write_0;

	// Cache 1 signals
	wire [4:0] cache_tag_out_1;
	wire [15:0] cache_data_out_1;
	wire cache_hit_1;
	wire cache_dirty_1;
	wire cache_valid_1;
	wire cache_err_1;
	wire cache_write_1;

	//
	// Victimway flipflop 
	//
	dff victimway(.q(vict_out), .d(vict_in), .clk(clk), .rst(rst));
	assign vict_in = (Rd | Wr) ? ~vict_in : vict_in;


	// TODO: Assign outputs
	assign DataOut = (cache_hit_0) ? cache_data_out_0 : cache_data_out_1;
	assign Done = 1'bz;
	assign Stall = 1'bz;
	assign err = (Addr_reg[0] == 1) | fsm_err | cache_erro_0 | cache_err_1;



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
                          .tag_in               (Addr_reg[15:11]),
                          .index                (Addr_reg[10:3]),
                          .offset               (Addr_reg[2:0]),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write              	(cache_write_0),
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
                          .tag_in               (Addr_reg[15:11]),
                          .index                (Addr_reg[10:3]),
                          .offset               (Addr_reg[2:0]),
                          .data_in              (cache_data_in),
                          .comp                 (cache_comp),
                          .write              	(cache_write_1),
                          .valid_in             (cache_valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (),
                     .stall             (),
                     .busy              (),
                     .err               (),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (),
                     .data_in           (),
                     .wr                (),
                     .rd                ());
   
   // your code here
	assign hit = (tag_in == cache_tag_out_0) ? cache_hit_0 : cache_hit_1;

	// TODO: figure out what variable name Lemar gave to the "curr_state" of the FSM
	assign valid = (curr_state == "CHECK_HIT") ?
					((tag_in == cache_tag_out_0) ? cache_valid_0 : cache_valid_1) :
					((evict_sel) ? cache_valid_1: cache_valid_0);

	assign dirty = evict_sel ? cache_dirty_1 : cache_dirty_0;

	assign evict_sel = (~cache_valid_0) ? 1'b0 :
						(~cache_valid_1) ? 1'b1 : vict_out;

	assign cache_wr_0 = cache_write ? (cache_hit_0 | (~evict_sel)) : 1'b0;
	assign cache_wr_1 = cache_write ? (cache_hit_1 | (~evict_sel)) : 1'b0;
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
