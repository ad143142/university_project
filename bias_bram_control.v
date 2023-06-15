module bias_bram_control #(
    parameter integer BRAM_DATA_WIDTH = 32,
    parameter integer BRAM_ADDRESS_WIDTH = 9,
    parameter AXIS_FIFO_SIZE  = 16,
    parameter bit_num  = clogb2(AXIS_FIFO_SIZE-1)
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    input wire [BRAM_DATA_WIDTH-1:0] bias_from_preload,

    input wire [BRAM_DATA_WIDTH-1:0] bias_from_bram_A,

    output reg [BRAM_DATA_WIDTH-1:0] bias_to_bram_A,//
    
    output reg [BRAM_ADDRESS_WIDTH-1:0] bram_address_A,

    output wire [BRAM_DATA_WIDTH-1:0] bias_out,

    output wire bram_A_en,

    output wire bram_A_wen,
    
    //FSM output
    output wire [1:0] read_state_o,
    output wire [2:0] write_state_o,

    //control in
    input wire [11:0] output_channel_size,
    input wire write_en,
    input wire [bit_num:0] axis_fifo_cnt,
    input wire transfer_start,
    input wire bram_control_add,

    input wire wait_input_from_axis,

    input wire layer_finish,
    //control out
    output wire bias_from_bram_valid,
    output wire axis_fifo_read,
    output wire write_bias_finish

);
    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

    localparam RIDLE=2'd0,RS0=2'd1,RS1=2'd2,RVALID=2'd3;
    localparam WIDLE=3'd0,WWAITWEIGHT=3'd1,WS0=3'd2,WVALID1=3'd3;
    
    reg [1:0] read_state;
    reg [2:0] write_state;
    reg [BRAM_ADDRESS_WIDTH-1:0] write_bram_cnt;

    reg bias_valid_buf;

    wire bias_valid;

    assign bias_from_bram_valid = (bias_valid & (~bias_valid_buf));

    assign read_state_o  = read_state;
    assign write_state_o = write_state;

    assign axis_fifo_read=(write_state==WS0);

    assign bram_A_en=1;

    assign bram_A_wen=(write_state==WVALID1);

    assign bias_valid=(read_state==RVALID);
    assign bias_out = bias_from_bram_A;

    assign write_bias_finish=(((write_bram_cnt+1)>=output_channel_size) && (output_channel_size != 12'd0));

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bram_address_A<=0;
        end
        else begin
            if(transfer_start ) begin
                bram_address_A<=0;
            end
            else if(bram_control_add || write_state==WVALID1) begin
                bram_address_A<=bram_address_A+1;
            end
        end
    end
    
    //read FSM
    wire read_FSM_start;
    assign read_FSM_start=(transfer_start && (~write_en));
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            read_state<=RIDLE;
        end
        else if(layer_finish) begin
            read_state<=RIDLE;
        end
        else begin
            case (read_state)
                RIDLE:    read_state<=read_FSM_start ? RS0:RIDLE;
                RS0:      read_state<=RS1;
                RS1:      read_state<=RVALID;
                RVALID:   read_state<=(bram_control_add || read_FSM_start) ? RS0:RVALID;
                
                default:  read_state<=RIDLE;         
            endcase
        end
    end

    //write FSM
    wire write_FSM_start;
    assign write_FSM_start=(transfer_start && (write_en));
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_state<=WIDLE;
        end
        else begin
            case (write_state)
                WIDLE       : write_state <= write_FSM_start ? WWAITWEIGHT :WIDLE;
                WWAITWEIGHT : write_state <= (wait_input_from_axis) ? WS0:WWAITWEIGHT;
                WS0         : write_state <= (!write_en) ? WIDLE:WVALID1;                                   
                WVALID1     : write_state <= (!write_en) ? WIDLE:(write_bias_finish ? WIDLE:WWAITWEIGHT);
                default     : write_state <= WIDLE;         
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bias_to_bram_A<=0;
        end
        else begin
            bias_to_bram_A<=(write_state==WS0 && axis_fifo_cnt!=0) ? bias_from_preload:bias_to_bram_A;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_bram_cnt<=0;
        end
        else begin
            write_bram_cnt <= (write_state==WIDLE)   ? 0:
                              (write_state==WVALID1) ? write_bram_cnt+1:write_bram_cnt;
        end
        
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bias_valid_buf <= 1'd0;
        end
        else begin
            bias_valid_buf <= bias_valid;
        end
        
    end

endmodule