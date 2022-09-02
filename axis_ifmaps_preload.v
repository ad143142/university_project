module axis_ifmaps_preload #(
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32,
    parameter integer MAC_NUM = 256,
    parameter integer FIFO_DEPTH = 4
)
(
    //global
    input wire clk,
    input wire rst_n,

    //data
    input wire [C_S_AXIS_TDATA_WIDTH-1:0] ifmaps_from_axis,
    output reg [5*MAC_NUM-1:0] ifmaps_out,

    //control
    input  wire axi_fifo_empty,
    output wire axi_fifo_read,
    input  wire MAC_read,
    output wire fifo_empty,
    output wire fifo_full
);
    //TODO:尚未測試

    //由axis進入的32bit將他擺放成MAC要使用的5*MAC_NUM寬度
    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction
    
    integer idx;

    localparam bit_num  = clogb2(FIFO_DEPTH-1);

    reg [5*MAC_NUM-1:0] preload_fifo [0:bit_num-1];

    reg [bit_num-1:0] fifo_write_ptr;
    reg [5:0] fifo_write_cnt;
    reg [bit_num-1:0] fifo_read_ptr;

    reg [bit_num-1:0] fifo_cnt;

    wire write_en;
    wire read_en;

    assign fifo_empty=(fifo_cnt==0);
    assign fifo_full=(fifo_cnt==FIFO_DEPTH);

    assign write_en=(~axi_fifo_empty) & ((~fifo_full) | MAC_read);
    assign read_en=~fifo_empty & MAC_read;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(idx=0;idx<bit_num;idx=idx+1) begin
                preload_fifo[idx]<=0;
            end
        end
        else begin
            if(write_en) begin
                preload_fifo[fifo_write_ptr][fifo_write_cnt]<=ifmaps_from_axis;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_write_ptr<=0;
        end
        else begin
            if(write_en && fifo_write_cnt==39) begin
                fifo_write_ptr<=fifo_write_ptr+1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_write_cnt<=0;
        end
        else begin
            if(write_en) begin
                fifo_write_cnt<=(write_en==39) ? 0:fifo_write_cnt+1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_read_ptr<=0;
        end
        else begin
            if(read_en) begin
                fifo_read_ptr<=fifo_read_ptr+1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            fifo_cnt<=0;
        end
        else begin
			if(read_en & write_en && fifo_write_cnt==0) begin
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

    

endmodule