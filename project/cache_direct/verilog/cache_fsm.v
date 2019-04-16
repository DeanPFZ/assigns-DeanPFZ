
module cache_fsm(
	//Output
	fsm_done, cache_data_in, cache_comp, cache_enable, cache_wr, cache_valid_in, 
	fsm_stall, fsm_err, cache_tag_in, cache_index, cache_offset, mem_addr, mem_wr,
	mem_rd, mem_data_in, fsm_hit,
	
	// Input
	DataIn_reg, cache_data_out, cache_hit, cache_dirty, cache_valid, Addr, Rd, Wr, clk, rst,
	cache_tag_out, mem_DataOut
	);

   	localparam IDLE = 					4'b0000;
   	localparam CHECK_HIT = 				4'b0001;
   	localparam WRITE_BACK_MEM_WAIT =	4'b0010;
   	localparam WRITE_BACK_MEM_WAIT_1 = 	4'b0011;
   	localparam WRITE_BACK_MEM_WAIT_2 = 	4'b0100;
   	localparam WRITE_BACK_MEM_WAIT_3 = 	4'b0101;
   	localparam WRITE_BACK_MEM_WAIT_4 = 	4'b0110;
   	localparam WRITE_BACK_MEM_WAIT_5 = 	4'b0111;
   	localparam WRITE_BACK_MEM_WAIT_6 = 	4'b1000;
   	localparam WRITE_BACK_MEM_DONE = 	4'b1001;
   	localparam GET_MEM_DATA_1 = 		4'b1010;
   	localparam GET_MEM_DATA_2 = 		4'b1011;
   	localparam GET_MEM_DATA_3 = 		4'b1100;
   	localparam GET_MEM_DATA_4 = 		4'b1101;
   	localparam GET_MEM_DATA_5 = 		4'b1110;
   	localparam REDO_READ = 				4'b1111;
	
	input [15:0] DataIn_reg, Addr, cache_data_out, mem_DataOut;
	input cache_hit, cache_dirty, cache_valid, Rd, Wr, clk, rst;
	input [4:0] cache_tag_out;

	output reg fsm_done, cache_comp, cache_enable, cache_wr, cache_valid_in,
				fsm_stall, fsm_err, mem_wr, mem_rd, fsm_hit;
	output reg [4:0] cache_tag_in;
	output reg [7:0] cache_index;
	output reg [2:0] cache_offset;
	output reg [15:0] cache_data_in, mem_addr, mem_data_in;
	
   	wire [3:0] state;
	reg [3:0] nxt_state;
	reg4 reg_state(.q(state), .d(nxt_state), .clk(clk), .rst(rst));

   	//assign DataOut = fsm_data_out;

   	always @(*) begin
      nxt_state = IDLE;
      cache_enable = 1'b0;
      cache_comp = 1'b0;
      cache_wr = 1'b0;
      cache_valid_in = 1'b1;
      cache_data_in = DataIn_reg;
      cache_tag_in = Addr[15:11];
      cache_index = Addr[10:3];
      cache_offset = Addr[2:0];
      mem_addr = Addr;
      mem_data_in = cache_data_out;
      mem_wr = 1'b0;
      mem_rd = 1'b0;
      fsm_err = 1'b0;
      fsm_stall = 1'b1;
      fsm_hit = 1'b0;
     //fsm_data_out = cache_data_out;
      fsm_done = 1'b0;
      case(state)
     	IDLE: begin
        	fsm_err = Rd&Wr;
        	cache_enable = Rd^Wr;
        	cache_comp = Rd^Wr;
        	cache_wr = (~Rd)&Wr;
			fsm_stall = 1'b0;
        	nxt_state = (Rd^Wr)?CHECK_HIT:IDLE;
      	end
       	CHECK_HIT: begin
        	fsm_done = cache_hit & cache_valid;
        	fsm_hit = cache_hit & cache_valid;
        	mem_data_in = (~cache_hit & cache_valid & cache_dirty)?cache_data_out:DataIn_reg;
        	mem_addr = (~cache_hit & cache_valid & cache_dirty)?{cache_tag_out,cache_index,3'b000}:
						((cache_hit & ~cache_valid & Rd) | (~cache_hit & ~cache_dirty & Rd))?
						{cache_tag_in,cache_index, 3'b000} : Addr;
			cache_tag_in = cache_tag_out;
			cache_offset = 3'b000;
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			fsm_stall = (cache_hit & cache_valid) ? 1'b0 : 1'b1;
			mem_rd = ((cache_hit & ~cache_valid & Rd) | (~cache_hit & ~cache_dirty & Rd))? 1'b1 : 1'b0;
			nxt_state = ((cache_hit & ~cache_valid & Rd) | (~cache_hit & ~cache_dirty & Rd))
						? GET_MEM_DATA_1:
						((~cache_hit & cache_valid & cache_dirty) ? WRITE_BACK_MEM_WAIT_1 : IDLE);
       	end

		//
		// START OF MEM TO CACHE WRITE
		//
		// - Actually started in CHECK_HIT
		// - Get 4 words of data from memory and write it to the cache
		//
		GET_MEM_DATA_1: begin
			mem_rd = 1'b1;
			mem_addr = {cache_tag_in, cache_index, 3'b010};
			nxt_state = GET_MEM_DATA_2;
		end
		// This is the first cycle that memory data is available to write to the cache
		GET_MEM_DATA_2: begin
			mem_rd = 1'b1;
			mem_addr = {cache_tag_in, cache_index, 3'b100};
			cache_offset = 3'b000;
			cache_enable = 1'b1;
			cache_comp = 1'b0;
			cache_wr = 1'b1;
			cache_valid_in = 1'b1;
			cache_data_in = mem_DataOut;
			nxt_state = GET_MEM_DATA_3;
		end
		GET_MEM_DATA_3: begin
			mem_rd = 1'b1;
			mem_addr = {cache_tag_in, cache_index, 3'b110};
			cache_offset = 3'b010;
			cache_enable = 1'b1;
			cache_comp = 1'b0;
			cache_wr = 1'b1;
			cache_valid_in = 1'b1;
			cache_data_in = mem_DataOut;
			nxt_state = GET_MEM_DATA_4;
		end
		GET_MEM_DATA_4: begin
			cache_offset = 3'b100;
			cache_enable = 1'b1;
			cache_comp = 1'b0;
			cache_wr = 1'b1;
			cache_valid_in = 1'b1;
			cache_data_in = mem_DataOut;
			nxt_state = GET_MEM_DATA_5;
		end
		GET_MEM_DATA_5: begin
			cache_offset = 3'b110;
			cache_enable = 1'b1;
			cache_comp = 1'b0;
			cache_wr = 1'b1;
			cache_valid_in = 1'b1;
			cache_data_in = mem_DataOut;
			nxt_state = REDO_READ;
		end
		// Now that the memory data is in the cache, redo the read instruction 
		// This read should always hit
		REDO_READ: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b1;
			nxt_state = CHECK_HIT;
		end

		// TODO Add state that checks the REDO_READ Hit but does not assert hit
		
		//
		// END OF MEMORY TO CACHE WRITE
		//

		//
		// START CACHE TO MEM WRITE
		//
		// - Actually started in CHECK_HIT
		// - Get 4 words of data from memory and write it to the cache
		//
		WRITE_BACK_MEM_WAIT: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b010;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b000};
			nxt_state = WRITE_BACK_MEM_WAIT_1;
		end
		WRITE_BACK_MEM_WAIT_1: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b100;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b010};
			nxt_state = WRITE_BACK_MEM_WAIT_2;
		end
		WRITE_BACK_MEM_WAIT_2: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b110;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b100};
			nxt_state = WRITE_BACK_MEM_WAIT_3;
		end
		WRITE_BACK_MEM_WAIT_3: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b110};
			nxt_state = WRITE_BACK_MEM_WAIT_4;
		end
		WRITE_BACK_MEM_WAIT_4: begin
			nxt_state = WRITE_BACK_MEM_WAIT_5;
		end
		WRITE_BACK_MEM_WAIT_5: begin
			nxt_state = WRITE_BACK_MEM_WAIT_6;
		end
		// Last write (index = 2'b11) will finish the cycle after this state
		// so we can start the memory to cache write now
		WRITE_BACK_MEM_WAIT_6: begin
        	mem_addr = {cache_tag_in,cache_index, 3'b000};
			mem_rd = 1'b1;
			nxt_state = GET_MEM_DATA_1;
		end
		//
		// END CACHE TO MEM WRITE
		//
		// TODO add default state
      endcase
   end

endmodule // cache_fsm
