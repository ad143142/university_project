
`timescale 1 ns / 1 ps

	module axis_fifo_my #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32,

		// Total number of input data.
		parameter FIFO_SIZE  = 16,
		// bit_num gives the minimum number of bits needed to address 'FIFO_SIZE' size of FIFO.
		parameter bit_num  = clogb2(FIFO_SIZE-1)
		// Define the states of state machine
		// The control state machine oversees the writing of input streaming data to the FIFO,
		// and outputs the streaming data from the FIFO
	)
	(
		// Users to add ports here
        output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] data_out,
        input wire read_want,
		output reg out_valid,
		
		output wire fifo_full,
		output wire fifo_empty,
		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction
	
	// Total number of input data.
	// localparam FIFO_SIZE  = 16;
	// bit_num gives the minimum number of bits needed to address 'FIFO_SIZE' size of FIFO.
	// localparam bit_num  = clogb2(FIFO_SIZE-1);
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	
	integer idx;
	
	reg [C_S_AXIS_TDATA_WIDTH-1:0] fifo [0:FIFO_SIZE-1];

	reg [bit_num:0] fifo_cnt;
	reg [bit_num-1:0] fifo_write_ptr;
	reg [bit_num-1:0] fifo_read_ptr;
	
	wire write_en;
	wire read_en;

	assign fifo_full=(fifo_cnt==FIFO_SIZE);
	assign fifo_empty=(fifo_cnt==0);

	assign S_AXIS_TREADY=~fifo_full;

	// assign write_en=S_AXIS_TVALID & S_AXIS_TREADY ;	
	assign write_en=S_AXIS_TVALID & ((~fifo_full) | read_want);
	assign read_en=read_want & ~fifo_empty;

	assign data_out=fifo[fifo_read_ptr];

	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
		if(!S_AXIS_ARESETN) begin
			for(idx=0;idx<FIFO_SIZE;idx=idx+1)
			begin
				fifo[idx]<=32'd0;
			end			
		end
		else begin
			if(write_en) begin
				fifo[fifo_write_ptr]<=S_AXIS_TDATA;
			end
		end
	end
	
	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
		if(!S_AXIS_ARESETN) begin
			fifo_cnt<=0;
		end
		else begin
			if(read_en & write_en) begin
				fifo_cnt<=fifo_cnt;
			end
			else if(write_en) begin
				fifo_cnt<=fifo_cnt+1;
			end
			else if(read_en) begin
				fifo_cnt<=fifo_cnt-1;
			end 
			else begin
				fifo_cnt<=fifo_cnt;
			end
		end
	end

	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
		if(!S_AXIS_ARESETN) begin
			fifo_write_ptr<=0;
		end
		else begin
			if(write_en) begin
				fifo_write_ptr<=fifo_write_ptr+1;
			end
		end
	end

	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
		if(!S_AXIS_ARESETN) begin
			fifo_read_ptr<=0;
		end
		else begin
			if(read_en) begin
				fifo_read_ptr<=fifo_read_ptr+1;
			end
		end
	end

	// always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
	// 	if(!S_AXIS_ARESETN) begin
	// 		data_out<=0;
	// 	end
	// 	else begin
	// 		if(read_en) begin
	// 			data_out<=fifo[fifo_read_ptr];
	// 		end
	// 		else begin
	// 			data_out<=data_out;
	// 		end
	// 	end
	// end

	always @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
		if(!S_AXIS_ARESETN) begin
			out_valid<=0;
		end
		else begin
			out_valid<=read_en?1:0;
		end
	end


endmodule
