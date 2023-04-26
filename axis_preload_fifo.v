module axis_preload_fifo #(
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32,
    parameter integer MAC_NUM = 256,
    parameter integer AXIS_PRELOAD_FIFO_DEPTH = 4,
    parameter integer bit_num  = clogb2(AXIS_PRELOAD_FIFO_DEPTH-1)
)
(
    //global
    input wire clk,
    input wire rst_n,

    //data
    input wire [C_S_AXIS_TDATA_WIDTH-1:0] ifmaps_from_axis,
    output wire [5*MAC_NUM-1:0] ifmaps_out,

    //control in
    input wire [11:0] input_channel_size,
    input wire load_axis_preload,
    input wire fifo_read,
    input wire axis_clear,

    //control out
    output reg [bit_num:0] fifo_cnt,
    output wire fifo_empty,
    output wire fifo_full,

    output wire wait_weight_preload
);
    //由axis進入的32bit將他擺放成MAC要使用的5*MAC_NUM寬度
    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction
    
    integer idx;

    reg [5*MAC_NUM-1:0] preload_fifo [0:AXIS_PRELOAD_FIFO_DEPTH-1];

    reg [bit_num-1:0] fifo_write_ptr;
    reg [8:0] fifo_write_cnt;
    reg [bit_num-1:0] fifo_read_ptr;

    

    wire write_en;
    wire read_en;
    wire write_ptr_add;

    assign write_ptr_add=((fifo_write_cnt+6)>input_channel_size);
    // assign wait_weight_preload = ~write_ptr_add;
    assign wait_weight_preload = ~fifo_empty;
    assign ifmaps_out=preload_fifo[fifo_read_ptr];

    assign fifo_empty=(fifo_cnt==0);
    assign fifo_full=(fifo_cnt==AXIS_PRELOAD_FIFO_DEPTH);

	assign write_en=load_axis_preload & ((~fifo_full) | read_en);
    assign read_en=~fifo_empty & fifo_read;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(idx=0;idx<AXIS_PRELOAD_FIFO_DEPTH;idx=idx+1) begin
                preload_fifo[idx]<=0;
            end
        end
        else begin
            if(write_en) begin
                preload_fifo[fifo_write_ptr][(fifo_write_cnt*5)+29 -:30]<=ifmaps_from_axis[29:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_write_ptr<=0;
        end
        else begin
            if(axis_clear) begin
                fifo_write_ptr<=0;
            end
            else if(write_en && write_ptr_add) begin
                fifo_write_ptr<=fifo_write_ptr+1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_write_cnt<=0;
        end
        else begin
            if(axis_clear) begin
                fifo_write_cnt<=0;
            end
            else if(write_en) begin
                fifo_write_cnt<=write_ptr_add? 0:fifo_write_cnt+6;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_read_ptr<=0;
        end
        else begin
            if(axis_clear) begin
                fifo_read_ptr<=0;
            end
            else if(read_en) begin
                fifo_read_ptr<=fifo_read_ptr+1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_cnt<=0;
        end
        else begin
            if(axis_clear) begin
                fifo_cnt<=0;
            end
			else if(read_en & write_en && fifo_write_cnt==0) begin
				fifo_cnt<=fifo_cnt;
			end
			else if(write_en && fifo_write_cnt==0) begin
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

    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n) begin
    //         wait_weight_preload<=0;
    //     end
    //     else begin
    //         wait_weight_preload<=write_ptr_add;
	// 	end
    // end

    

endmodule