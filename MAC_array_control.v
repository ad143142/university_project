`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 

module MAC_array_control #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12
) 
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    input wire [5*MAC_NUM-1:0] ifmaps_from_axis_preload,

    input wire [5*MAC_NUM-1:0] weight_from_bram,

    output wire [6*MAC_NUM-1:0] MAC_out,
    //control
    input wire [MAC_NUM-1:0] enable,
    input wire [1:0] operation,
    input wire [4:0] kernel_size,
    
    input wire load_weight_preload,
    input wire load_MAC_weight,
    input wire load_ifmaps,
    input wire pooling_compute,
    // output wire read_weight,
    // output wire read_ifmaps,
    output reg MAC_o_valid,

    input wire ifmaps_fifo_empty
    // output[31:0] axi_control_3 //回復訊號(compute over、FIFO_full、read_ofmaps...)

);
    //TODO:選做:可以做data gating MAC如果在別的模式下(load weight)時用個enable把它關掉，其他的部分也是
    /*
        0901
        目前bram_control已修好，其他的control_path皆有問題。
        bram_control再準備好值之後等待read_en將值讀走，FSM會再根據讀取長度(只讀portA還是讀A和B)，決定是否要更新address並且讀取下筆資料。
    */

    //FIXME:需先將bram_control修好，state會少一半 20220902有修一版，還沒測
    //K=>kernelsize
    // localparam LOAD_WEIGHT_IDLE=5'd0,RESET_ADDR=5'd1,K1_0=5'd2,K2_0=5'd3,K2_1=5'd4,K3_0=5'd5,K3_1=5'd6,K3_2=5'd7,
    //            K4_0=5'd8,K4_1=5'd9,K4_2=5'd10,K4_3=5'd11,K5_0=5'd12,K5_1=5'd13,K5_2=5'd14,K5_3=5'd15,K5_4=5'd16,
    //            K1_LOAD_WEIGHT=5'd17,K2_LOAD_WEIGHT=5'd18,K3_LOAD_WEIGHT=5'd19,K4_LOAD_WEIGHT=5'd20,K5_LOAD_WEIGHT=5'd21;
    // reg  [4:0] load_weight_state;   

    //TODO: 雙斜線的是指還沒實作
    // assign axi_control_3=0;//
    wire ifmaps_input_valid;
    // wire load_weight;

    wire address_reset;
    wire read_en;
    wire read_len;
    wire load_weight_FSM_start;

    wire [25*MAC_NUM-1:0] weight_from_preload;

    assign ifmaps_input_valid=~ifmaps_fifo_empty;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            MAC_o_valid<=0;      
        end
        else begin
            MAC_o_valid<=(load_MAC_weight|pooling_compute); 
        end
    end

    /////////////////////////////////////////////////
    //                                             //
    //                   instance                  //
    //                                             //
    /////////////////////////////////////////////////

    genvar idx;
    generate
        for(idx=0;idx<MAC_NUM;idx=idx+1) begin:weight_preload_arr
            weight_preload u_weight_preload(
                .clk                 (clk                                    ),
                .rst_n               (rst_n                                  ),
                .weight_from_bram    (weight_from_bram[idx*5+4 -:5]          ),
                .weight_from_preload (weight_from_preload[idx*25+24 -:25]    ),
                .load_weight_preload (load_weight_preload                    ) 
            ); 
        end
    endgenerate

       

    MAC_array 
    #(
        .MAC_NUM (MAC_NUM )
    )
    u_MAC_array(
        .clk                         (clk                       ),
        .rst_n                       (rst_n                     ),
        .weight_from_preload         (weight_from_preload       ),
        .ifmaps_from_axis_preload    (ifmaps_from_axis_preload  ),
        .psum_out                    (MAC_out                   ),
        .enable                      (enable                    ),
        .operation                   (operation                 ),
        .kernel_size                 (kernel_size               ),
        .ifmaps_input_valid          (ifmaps_input_valid        ),//
        .load_ifmaps                 (load_ifmaps               ),//
        .load_weight                 (load_MAC_weight           ) 
    );





    
endmodule