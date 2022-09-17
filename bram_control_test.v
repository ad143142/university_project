module bram_control_test #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12,
    parameter AXIS_PRELOAD_FIFO_DEPTH  = 4,
    parameter bit_num  = clogb2(AXIS_PRELOAD_FIFO_DEPTH-1)
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    //TODO:從AXI寫BRAM的部分還沒有實作
    input wire [5*MAC_NUM-1:0] weight_from_preload,

    input wire [5*MAC_NUM-1:0] weight_from_bram_A,
    input wire [5*MAC_NUM-1:0] weight_from_bram_B,

    output wire [5*MAC_NUM-1:0] weight_out,

    output reg [5*MAC_NUM-1:0] weight_to_bram_A,//
    output reg [5*MAC_NUM-1:0] weight_to_bram_B,//
    
    output reg [BRAM_ADDRESS_WIDTH-1:0] bram_address_A,
    output wire [BRAM_ADDRESS_WIDTH-1:0] bram_address_B,

    output wire bram_A_en,
    output wire bram_B_en,

    output wire bram_A_wen,//
    output wire bram_B_wen,//

    //control in
    input wire [4:0] kernel_size,
    input wire [11:0] output_channel_size,
    input wire write_en,//
    input wire [bit_num:0] axis_fifo_cnt,
    input wire transfer_start,
    input wire bram_control_add1,
    input wire bram_control_add2,
    input wire port_sel,

    //control out
    output wire weight_from_bram_valid,
    output wire axis_fifo_read,
    output wire write_weight_finish

);
    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

//TODO:未測試
    /*
        bram_control再準備好值之後等待read_en將值讀走，FSM會再根據讀取長度(只讀portA還是讀A和B)，決定是否要
        更新address並且讀取下筆資料。
    */
    localparam RIDLE=2'd0,RS0=2'd1,RS1=2'd2,RVALID=2'd3;
    localparam WIDLE=3'd0,WS0=3'd1,WS1=3'd2,WVALID1=3'd3,WVALID2=3'd4;
    
    reg [1:0] read_state;
    reg [2:0] write_state;

    reg [12:0] write_bram_num;
    reg [12:0] write_bram_cnt;
    reg [12:0] next_write_bram_cnt;

    assign write_weight_finish=(next_write_bram_cnt==write_bram_num);

    assign axis_fifo_read=(write_state==WS0 || write_state==WS1);

    assign bram_A_en=1;
    assign bram_B_en=1;

    assign bram_A_wen=(write_state==WVALID1 || write_state==WVALID2);
    assign bram_B_wen=(write_state==WVALID2);

    assign weight_from_bram_valid=(read_state==RVALID);
    assign weight_out=(port_sel) ? weight_from_bram_B:weight_from_bram_A;

    assign bram_address_B = bram_address_A+1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bram_address_A<=0;
        end
        else begin
            if(transfer_start) begin
                bram_address_A<=0;
            end
            else if(bram_control_add1 || write_state==WVALID1) begin
                bram_address_A<=bram_address_A+1;
            end
            else if(bram_control_add2 || write_state==WVALID2) begin
                bram_address_A<=bram_address_A+2;
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
        else begin
            case (read_state)
                RIDLE:    read_state<=read_FSM_start ? RS0:RIDLE;
                RS0:      read_state<=RS1;
                RS1:      read_state<=RVALID;
                RVALID:   read_state<=(bram_control_add1 || bram_control_add2) ? RS0:
                                      (read_FSM_start) ? RS0:RVALID;
                default:  read_state<=RIDLE;         
            endcase
        end
    end

    //write FSM
    //TODO:要去想怎麼從FIFO一次讀兩筆並且怎麼知道是要寫一筆還是兩筆
    wire write_FSM_start;
    assign write_FSM_start=(transfer_start && (write_en));
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_state<=WIDLE;
        end
        else begin
            case (write_state)
                WIDLE:    write_state<=write_FSM_start ? WS0:WIDLE;
                WS0:      write_state<=(!write_en) ? WIDLE:
                                       (axis_fifo_cnt==0) ? WS0:
                                       (axis_fifo_cnt==1) ? WVALID1:WS1;                                       
                WS1:      write_state<=(!write_en) ? WIDLE:(WVALID2);
                WVALID1:  write_state<=(!write_en) ? WIDLE:(write_weight_finish ? WIDLE:WS0);
                WVALID2:  write_state<=(!write_en) ? WIDLE:(write_weight_finish ? WIDLE:WS0);
                default:  write_state<=WIDLE;         
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_to_bram_A<=0;
        end
        else begin
            weight_to_bram_A<=(write_state==WS0 && axis_fifo_cnt!=0) ? weight_from_preload:weight_to_bram_A;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_to_bram_B<=0;
        end
        else begin
            weight_to_bram_B<=(write_state==WS1) ? weight_from_preload:weight_to_bram_B;
        end
    end


    //write_bram_cnt

    always @(*) begin
        case(kernel_size)
            5'b00001:write_bram_num=output_channel_size;
            5'b00010:write_bram_num=output_channel_size*2;
            5'b00100:write_bram_num=output_channel_size*3;
            5'b01000:write_bram_num=output_channel_size*4;
            5'b10000:write_bram_num=output_channel_size*5;
            default :write_bram_num=output_channel_size;
        endcase
    end

    always @(*) begin
        next_write_bram_cnt=(write_state==WIDLE)   ? 0:
                            (write_state==WVALID1) ? write_bram_cnt+1:
                            (write_state==WVALID2) ? write_bram_cnt+2:write_bram_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_bram_cnt<=0;
        end
        else begin
            write_bram_cnt<=next_write_bram_cnt;
        end
    end

endmodule