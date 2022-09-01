module MAC_array_control #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12
) 
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    input wire [5*MAC_NUM-1:0] ifmaps_from_fifo,

    input wire [5*MAC_NUM-1:0] weight_from_bram_A,
    input wire [5*MAC_NUM-1:0] weight_from_bram_B,
    output wire [BRAM_ADDRESS_WIDTH-1:0] bram_address_A,
    output wire [BRAM_ADDRESS_WIDTH-1:0] bram_address_B,

    output wire [5*MAC_NUM-1:0] psum_out,
    //control
    input wire operation,
    input wire [4:0] kernel_size

);
    /*
        0901
        目前bram_control已修好，其他的control_path皆有問題。
        bram_control再準備好值之後等待read_en將值讀走，FSM會再根據讀取長度(只讀portA還是讀A和B)，決定是否要更新address並且讀取下筆資料。
    */
    //TODO:還沒有實作AXI input的control path因此load_weight_FSM_start，或是要load weight給bram的data path、control path都還沒辦法實作

    //FIXME:需先將bram_control修好，state會少一半
    //K=>kernelsize
    localparam LOAD_WEIGHT_IDLE=5'd0,RESET_ADDR=5'd1,K1_0=5'd2,K2_0=5'd3,K2_1=5'd4,K3_0=5'd5,K3_1=5'd6,K3_2=5'd7,
               K4_0=5'd8,K4_1=5'd9,K4_2=5'd10,K4_3=5'd11,K5_0=5'd12,K5_1=5'd13,K5_2=5'd14,K5_3=5'd15,K5_4=5'd16,
               K1_LOAD_WEIGHT=5'd17,K2_LOAD_WEIGHT=5'd18,K3_LOAD_WEIGHT=5'd19,K4_LOAD_WEIGHT=5'd20,K5_LOAD_WEIGHT=5'd21;
    reg  [4:0] load_weight_state;

    //TODO: 雙斜線的是指還沒實作
    wire ifmaps_input_valid;//

    wire load_ifmaps;//
    wire load_weight;

    wire address_reset;
    wire read_en;
    wire read_len;//
    wire load_weight_FSM_start;//

    assign address_rest=(load_weight_state==RESET_ADDR);
    assign read_en=(load_weight_state!=LOAD_WEIGHT_IDLE && load_weight_state!=K1_LOAD_WEIGHT && load_weight_state!=K2_LOAD_WEIGHT &&
                    load_weight_state!=K3_LOAD_WEIGHT && load_weight_state!=K4_LOAD_WEIGHT && load_weight_state!=K5_LOAD_WEIGHT); //除了IDLE和要load外都是1
    assign load_weight=(load_weight_state==K1_LOAD_WEIGHT && load_weight_state==K2_LOAD_WEIGHT &&
                        load_weight_state==K3_LOAD_WEIGHT && load_weight_state==K4_LOAD_WEIGHT && load_weight_state!=K5_LOAD_WEIGHT);
    
    //FIXME:len需要將bram_control修好
    assign read_len=(load_weight_state==K2_0 || load_weight_state==K3_0 || load_weight_state==K4_0 || load_weight_state==K4_2 || load_weight_state==K5_0 || 
                     load_weight_state==K5_2);

    /////////////////////////////////////////////////
    //                                             //
    //                   FSM                       //
    //                                             //
    /////////////////////////////////////////////////

    //TODO:須確定bram的時序及state走法
    wire load_weight_finish;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            load_weight_state<=LOAD_WEIGHT_IDLE;
        end 
        else begin
            case (load_weight_state)
                LOAD_WEIGHT_IDLE:load_weight_state<= load_weight_FSM_start ? RESET_ADDR:LOAD_WEIGHT_IDLE;
                RESET_ADDR:load_weight_state<=(kernel_size==5'b00001) ? K1_0:
                                              (kernel_size==5'b00010) ? K2_0:
                                              (kernel_size==5'b00100) ? K3_0:
                                              (kernel_size==5'b01000) ? K4_0:
                                              (kernel_size==5'b10000) ? K5_0:K1_0;//不應該要有else
                K1_0:load_weight_state<=data_valid ? K1_LOAD_WEIGHT:K1_0;
                K1_LOAD_WEIGHT:load_weight_state<=load_weight_finish ? LOAD_WEIGHT_IDLE:K1_0;

                K2_0:load_weight_state<=data_valid ? K2_1:K2_0;
                K2_1:load_weight_state<=data_valid ? K2_LOAD_WEIGHT:K2_1;
                K2_LOAD_WEIGHT:load_weight_state<=load_weight_finish ? LOAD_WEIGHT_IDLE:K2_0;

                K3_0:load_weight_state<=data_valid ? K3_1:K3_0;
                K3_1:load_weight_state<=data_valid ? K3_2:K3_1;
                K3_2:load_weight_state<=data_valid ? K3_LOAD_WEIGHT:K3_2;
                K3_LOAD_WEIGHT:load_weight_state<=load_weight_finish ? LOAD_WEIGHT_IDLE:K3_0;

                K4_0:load_weight_state<=data_valid ? K4_1:K4_0;
                K4_1:load_weight_state<=data_valid ? K4_2:K4_1;
                K4_2:load_weight_state<=data_valid ? K4_3:K4_2;
                K4_3:load_weight_state<=data_valid ? K4_LOAD_WEIGHT:K4_3;
                K4_LOAD_WEIGHT:load_weight_state<=load_weight_finish ? LOAD_WEIGHT_IDLE:K4_0;

                K5_0:load_weight_state<=data_valid ? K5_1:K5_0;
                K5_1:load_weight_state<=data_valid ? K5_2:K5_1;
                K5_2:load_weight_state<=data_valid ? K5_3:K5_2;
                K5_3:load_weight_state<=data_valid ? K5_4:K5_3;
                K5_4:load_weight_state<=data_valid ? K5_LOAD_WEIGHT:K5_4;
                K5_LOAD_WEIGHT:load_weight_state<=load_weight_finish ? LOAD_WEIGHT_IDLE:K5_0;

                default: load_weight_state<=LOAD_WEIGHT_IDLE;
            endcase
        end
    end

    /////////////////////////////////////////////////
    //                                             //
    //                   instance                  //
    //                                             //
    /////////////////////////////////////////////////

    bram_control 
    #(
        .MAC_NUM            (MAC_NUM              ),
        .BRAM_ADDRESS_WIDTH (BRAM_ADDRESS_WIDTH   )
    )
    u_bram_control(
    	.clk                (clk                  ),
        .rst_n              (rst_n                ),
        .weight_from_bram_A (weight_from_bram_A   ),
        .weight_from_bram_B (weight_from_bram_B   ),
        .weight_out         (weight_out           ),
        .bram_address_A     (bram_address_A       ),
        .bram_address_B     (bram_address_B       ),
        .bram_A_en          (bram_A_en            ),
        .bram_B_en          (bram_B_en            ),
        .address_reset      (address_reset        ),//
        .read_en            (read_en              ),//
        .read_len           (read_len             ),//
        .data_valid         (data_valid           ) 
    );

    weight_preload u_weight_preload(
    	.clk                 (clk                 ),
        .rst_n               (rst_n               ),
        .weight_from_bram    (weight_out          ),
        .weight_from_preload (weight_from_preload ),
        .input_valid         (data_valid          ) 
    );    

    MAC_array 
    #(
        .MAC_NUM (MAC_NUM )
    )
    u_MAC_array(
        .clk                 (clk                 ),
        .rst_n               (rst_n               ),
        .weight_from_preload (weight_from_preload ),
        .ifmaps_from_fifo    (ifmaps_from_fifo    ),
        .psum_out            (psum_out            ),
        .operation           (operation           ),
        .kernel_size         (kernel_size         ),
        .ifmaps_input_valid  (ifmaps_input_valid  ),//
        .load_ifmaps         (load_ifmaps         ),//
        .load_weight         (load_weight         ) //
    );





    
endmodule