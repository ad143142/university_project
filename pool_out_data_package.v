
`timescale 1 ns / 1 ps

	module pool_out_data_package #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32
	)
	(
		input wire clk,
    	input wire rst_n,

		input wire layer_finish,
        input wire MAC_o_valid,
        input wire [255:0]MAC_out,

		input wire [11:0] output_channel_size,
		input wire [2:0] stride,

        output wire pooling_finish,
		
        output wire out_valid,
        output wire out_last,
        output reg [C_M_AXIS_TDATA_WIDTH-1:0] out_data

	);
	//=================================================================================

	///////////////////function//////////////////////////
	function integer clogb2 (input integer bit_depth);                                   
	  begin                                                                              
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                                      
	      bit_depth = bit_depth >> 1;                                                    
	  end                                                                                
	endfunction  
	///////////////////localparam////////////////////////
	localparam IDLE 	= 2'd0;
    localparam WAIT_CNT = 2'd1;
    localparam WAIT_FIN = 2'd2;
	
	localparam T_IDLE 	= 2'd0;
	localparam T_OUT   	= 2'd1; 
	localparam T_FIN	= 2'd2;
	///////////////////reg//////////////////////////
	reg [1:0] state;
	reg [1:0] transfer_state;
	reg [3:0] wait_cnt;
	reg [3:0] transfer_cnt;

	reg last_buf;
	///////////////////wire//////////////////////////
	wire busy;
	wire [3:0] transfer_times;
	wire [3:0] wait_cycle;
	/////////////////////assign////////////////////////
	assign transfer_times = (output_channel_size[7:5] + (|output_channel_size[4:0]));
	assign busy =  transfer_times > stride;
	assign wait_cycle = transfer_times - stride;
	///////////////////output//////////////////////////
	assign pooling_finish = (state == WAIT_FIN); 
	assign out_valid      = (transfer_state == T_OUT);
	assign out_last 	  = ((transfer_state == T_OUT) && last_buf && (transfer_cnt + 4'd1 == transfer_times));
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_data <= 32'd0;
        end
        else begin
            out_data <= MAC_out[transfer_cnt*32 +: 32];
        end
    end
	/////////////////////state///////////////////////
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE    : state <= MAC_o_valid ? (busy ? WAIT_CNT : WAIT_FIN) : IDLE;
                WAIT_CNT: state <= (wait_cnt + 4'd1 == wait_cycle) ? WAIT_FIN : WAIT_CNT;
				WAIT_FIN: state <= IDLE;

				default : state <= IDLE;
            endcase
        end
    end
	/////////////////////transfer_state///////////////////////
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            transfer_state <= T_IDLE;
        end
        else begin
            case(transfer_state)
                T_IDLE	: transfer_state <= MAC_o_valid ? T_OUT : T_IDLE;
				T_OUT	: transfer_state <= (transfer_cnt + 4'd1 == transfer_times) ? T_FIN : T_OUT; 
				T_FIN	: transfer_state <= T_IDLE;
            endcase
        end
    end
	/////////////////////wait_cnt///////////////////////
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wait_cnt <= 4'd0;
        end
        else begin
            wait_cnt <= (state == IDLE)     ? 4'd0 :
						(state == WAIT_CNT) ? wait_cnt + 4'd1 : wait_cnt; 
        end
    end
	/////////////////////transfer_cnt///////////////////////
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            transfer_cnt <= 4'd0;
        end
        else begin
            transfer_cnt <= (transfer_state == T_IDLE) ? 4'd0 :
						    (transfer_state == T_OUT)  ? transfer_cnt + 4'd1 : transfer_cnt; 
        end
    end
	/////////////////////last_buf///////////////////////
	always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            last_buf <= 1'd0;
        end
        else begin
            last_buf <= (layer_finish) ? 1'd1 :
						(transfer_state == T_FIN) ? 1'd0 : last_buf;
        end
    end
	//=================================================================================
endmodule
