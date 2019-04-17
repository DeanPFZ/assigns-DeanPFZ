
module cache_fsm(
	//Output
	fsm_done, cache_data_in, cache_comp, cache_enable, cache_wr, cache_valid_in, 
	fsm_stall, fsm_err, cache_tag_in, cache_index, cache_offset, mem_addr, mem_wr,
	mem_rd, mem_data_in, fsm_hit,
	
	// Input
	DataIn, cache_data_out, cache_hit, cache_dirty, cache_valid, Addr, Rd, Wr, clk, rst,
	cache_tag_out, mem_DataOut
	);

   	localparam IDLE = 					5'b00000;
   	localparam CHECK_HIT = 				5'b00001;
   	localparam WRITE_BACK_MEM_WAIT =	5'b00010;
   	localparam WRITE_BACK_MEM_WAIT_1 = 	5'b00011;
   	localparam WRITE_BACK_MEM_WAIT_2 = 	5'b00100;
   	localparam WRITE_BACK_MEM_WAIT_3 = 	5'b00101;
   	localparam WRITE_BACK_MEM_WAIT_4 = 	5'b00110;
   	localparam WRITE_BACK_MEM_WAIT_5 = 	5'b00111;
   	localparam WRITE_BACK_MEM_WAIT_6 = 	5'b01000;
   	localparam WRITE_BACK_MEM_DONE = 	5'b01001;
   	localparam GET_MEM_DATA_1 = 		5'b01010;
   	localparam GET_MEM_DATA_2 = 		5'b01011;
   	localparam GET_MEM_DATA_3 = 		5'b01100;
   	localparam GET_MEM_DATA_4 = 		5'b01101;
   	localparam GET_MEM_DATA_5 = 		5'b01110;
   	localparam REDO_REQUEST =			5'b01111;
   	localparam REDO_DONE = 				5'b10000;
	
	input [15:0] DataIn, Addr, cache_data_out, mem_DataOut;
	input cache_hit, cache_dirty, cache_valid, Rd, Wr, clk, rst;
	input [4:0] cache_tag_out;

	output reg fsm_done, cache_comp, cache_enable, cache_wr, cache_valid_in,
				fsm_stall, fsm_err, mem_wr, mem_rd, fsm_hit;
	output reg [4:0] cache_tag_in;
	output reg [7:0] cache_index;
	output reg [2:0] cache_offset;
	output reg [15:0] cache_data_in, mem_addr, mem_data_in;
	
   	wire [4:0] state;
	reg [4:0] nxt_state;
	reg5 reg_state(.q(state), .d(nxt_state), .clk(clk), .rst(rst));

	wire [15:0] Addr_reg,DataIn_reg;
   	wire [15:0] Addr_reg_in, DataIn_reg_in;
   	wire Rd_reg, Wr_reg;
   	wire Rd_reg_in, Wr_reg_in;

   	assign Addr_reg_in = (fsm_stall) ? Addr_reg : Addr;
    assign DataIn_reg_in = (fsm_stall) ? DataIn_reg : DataIn;
    assign Rd_reg_in = (fsm_stall) ? Rd_reg : Rd;
    assign Wr_reg_in = (fsm_stall) ? Wr_reg : Wr;

   	reg16 reg_Addr(.q(Addr_reg), .d(Addr_reg_in), .clk(clk), .rst(rst));
   	reg16 reg_DataIn(.q(DataIn_reg), .d(DataIn_reg_in), .clk(clk), .rst(rst));
   	dff reg_Rd(.q(Rd_reg), .d(Rd_reg_in), .clk(clk), .rst(rst));
   	dff reg_Wr(.q(Wr_reg), .d(Wr_reg_in), .clk(clk), .rst(rst));
	

   	//assign DataOut = fsm_data_out;

   	always @(*) begin
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
			cache_data_in = DataIn;
      		cache_tag_in = Addr[15:11];
      		cache_index = Addr[10:3];
      		cache_offset = Addr[2:0];
			fsm_stall = 1'b0;
        	nxt_state = (Rd^Wr)?CHECK_HIT:IDLE;
      	end
       	CHECK_HIT: begin
        	fsm_done = cache_hit & cache_valid;
        	fsm_hit = cache_hit & cache_valid;
        	mem_data_in = (~cache_hit & cache_valid & cache_dirty)?cache_data_out:DataIn_reg;
        	mem_addr = (~cache_hit & cache_valid & cache_dirty)?{cache_tag_out,cache_index,3'b000}:
						((cache_hit & ~cache_valid) | (~cache_hit & ~cache_dirty))?
						{cache_tag_in,cache_index, 3'b000} : Addr_reg;
			cache_offset = (~cache_hit & cache_valid & cache_dirty) ? 3'b000 : Addr_reg[2:0];
			cache_enable = 1'b1;
			mem_wr = (~cache_hit & cache_valid & cache_dirty) ? 1'b1 : 1'b0;
			mem_rd = ((cache_hit & ~cache_valid) | (~cache_hit & ~cache_dirty))? 1'b1 : 1'b0;
			nxt_state = ((cache_hit & ~cache_valid) | (~cache_hit & ~cache_dirty))
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
			nxt_state = REDO_REQUEST;
		end
		// Now that the memory data is in the cache, redo the read instruction 
		// This read should always hit
		REDO_REQUEST: begin
        	fsm_err = Rd_reg&Wr_reg;
        	cache_enable = Rd_reg^Wr_reg;
        	cache_comp = Rd_reg^Wr_reg;
        	cache_wr = (~Rd_reg)&Wr_reg;
        	nxt_state = REDO_DONE;
		end
		REDO_DONE: begin
			fsm_stall = 1'b1;
        	cache_enable = 1'b1;
			fsm_done = 1'b1;	
        	nxt_state = IDLE;
		end
		//
		// END OF MEMORY TO CACHE WRITE
		//

		//
		// START CACHE TO MEM WRITE
		//
		//
		WRITE_BACK_MEM_WAIT_1: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b010;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b010};
			nxt_state = WRITE_BACK_MEM_WAIT_2;
		end
		WRITE_BACK_MEM_WAIT_2: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b100;
			mem_wr = 1'b1;
        	mem_addr = {cache_tag_out,cache_index,3'b100};
			nxt_state = WRITE_BACK_MEM_WAIT_3;
		end
		WRITE_BACK_MEM_WAIT_3: begin
			cache_enable = 1'b1;
			cache_wr = 1'b0;
			cache_comp = 1'b0;
			cache_offset = 3'b110;
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
