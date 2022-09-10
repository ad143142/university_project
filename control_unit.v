`define INST_COMPUTE 32'd87 

module control_unit #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
) (
    //golbal
    input wire clk,
    input wire rst_n,

    //control output  
    output wire [1:0]operation,
    output wire [4:0]kernel_size,
    output wire load_weight_preload,
    output wire load_weight,
    output wire bram_port_sel,
    output wire bram_control_add1,
    output wire bram_control_add2,
    output wire address_reset,

    output wire load_ifmaps,
    output wire [11:0] input_channel_size,

    output reg [MAC_NUM-1:0] MAC_enable,
    //control input 
    input wire weight_from_bram_valid,
    input wire ifmaps_fifo_empty,
    //global
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_0,//主要的控制訊號(loadweight、compute....)
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_1,//附加控制訊號(kernel size、operation...)
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_2,//附加控制訊號(kernel size、operation...)
    output wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_3 //回復訊號(compute over、FIFO_full、read_ofmaps...)
    
);
    //FIXME:MAC_enable等增加round之後要更改input
    localparam LOAD_WEIGHT_IDLE=5'd0,RESET_ADDR=5'd1,K1_0=5'd2,K2_0=5'd3,K2_1=5'd4,K3_0=5'd5,K3_1=5'd6,K3_2=5'd7,
               K4_0=5'd8,K4_1=5'd9,K4_2=5'd10,K4_3=5'd11,K5_0=5'd12,K5_1=5'd13,K5_2=5'd14,K5_3=5'd15,K5_4=5'd16,
               K1_LOAD_WEIGHT=5'd17,K2_LOAD_WEIGHT=5'd18,K3_LOAD_WEIGHT=5'd19,K4_LOAD_WEIGHT=5'd20,K5_LOAD_WEIGHT=5'd21;

    localparam LOAD_IFMAPS_IDLE=5'd0,WAIT_FIFO1=5'd1,LOAD1=5'd2,WAIT_FIFO2=5'd3,LOAD2=5'd4,WAIT_FIFO3=5'd5,LOAD3=5'd6,WAIT_FIFO4=5'd7,
               LOAD4=5'd8,WAIT_FIFO5=5'd9,LOAD5=5'd10,COMPUTE=5'd11,WAIT_FIFO6=5'd12,LOAD=5'd13;
    
    reg [4:0] load_weight_state; 
    reg [4:0] load_ifmaps_state;
    reg [9:0] filter_cnt;
    reg [8:0] ofmaps_width_cnt;
    reg [8:0] ofmaps_hegiht_cnt;
    reg all_weight_compute_finish_delay;

    wire load_weight_FSM_start,load_ifmaps_FSM_start;
    wire [8:0] ofmaps_weight;
    wire [7:0] MAC_enable_in;
    
    //decode
    assign load_ifmaps_FSM_start=(axi_control_0[7:0]==`INST_COMPUTE);
    assign input_channel_size=(axi_control_0[19:8]);

    assign ofmaps_weight=(axi_control_1[10:2]);   
    assign operation=(axi_control_1[1:0]);

    assign kernel_size=(axi_control_2[4:0]);

    assign axi_control_3=0;

    /////////////////////////////////////////////////
    //                   ifmaps_FSM                //
    /////////////////////////////////////////////////
    wire all_weight_compute_finish,all_finish,ifmaps_flush;
    assign all_weight_compute_finish=(filter_cnt==input_channel_size);
    assign all_finish=(ofmaps_width_cnt==ofmaps_weight && ofmaps_hegiht_cnt==ofmaps_weight);
    assign ifmaps_flush=(ofmaps_width_cnt==0);

    assign load_ifmaps=(load_ifmaps_state==LOAD || load_ifmaps_state==LOAD1 || load_ifmaps_state==LOAD2 || load_ifmaps_state==LOAD3 || 
                        load_ifmaps_state==LOAD4 || load_ifmaps_state==LOAD5);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            load_ifmaps_state<=5'd0;
        end
        else begin
            case(load_ifmaps_state)
                LOAD_IFMAPS_IDLE  :load_ifmaps_state<=load_ifmaps_FSM_start ? WAIT_FIFO1:LOAD_IFMAPS_IDLE;
                WAIT_FIFO1        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO1:LOAD1;
                LOAD1             :load_ifmaps_state<=(kernel_size==5'b00001) ? COMPUTE:WAIT_FIFO2;
                WAIT_FIFO2        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO2:LOAD2;
                LOAD2             :load_ifmaps_state<=(kernel_size==5'b00010) ? COMPUTE:WAIT_FIFO3;
                WAIT_FIFO3        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO3:LOAD3;
                LOAD3             :load_ifmaps_state<=(kernel_size==5'b00100) ? COMPUTE:WAIT_FIFO4;
                WAIT_FIFO4        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO4:LOAD4;
                LOAD4             :load_ifmaps_state<=(kernel_size==5'b01000) ? COMPUTE:WAIT_FIFO5;
                WAIT_FIFO5        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO5:LOAD5;
                LOAD5             :load_ifmaps_state<=COMPUTE;         
                COMPUTE           :load_ifmaps_state<=all_weight_compute_finish_delay ? (all_finish ? LOAD_WEIGHT_IDLE:(ifmaps_flush ? WAIT_FIFO1:WAIT_FIFO6)):COMPUTE;
                WAIT_FIFO6        :load_ifmaps_state<=ifmaps_fifo_empty ? WAIT_FIFO6:LOAD;
                LOAD              :load_ifmaps_state<=COMPUTE;
            endcase
        end
    end
    /////////////////////////////////////////////////
    //                   ifmaps_FSM                //
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    //                   weight_FSM                //
    /////////////////////////////////////////////////

    

    // assign address_reset=(load_weight_state==RESET_ADDR);

    assign load_weight_preload=(weight_from_bram_valid) & 
                               (load_weight_state==K1_0 || load_weight_state==K2_0 || load_weight_state==K2_1 || load_weight_state==K3_0 || load_weight_state==K3_1 || 
                                load_weight_state==K3_2 || load_weight_state==K4_0 || load_weight_state==K4_1 || load_weight_state==K4_2 || load_weight_state==K4_3 ||
                                load_weight_state==K5_0 || load_weight_state==K5_1 || load_weight_state==K5_2 || load_weight_state==K5_3 || load_weight_state==K5_4 );

    assign load_weight=(load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT ||
                        load_weight_state==K3_LOAD_WEIGHT || load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT);

    // assign bram_control_add1=(load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT || load_weight_state==K3_1 || load_weight_state==K5_3);      
    // assign bram_control_add2=(load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || load_weight_state==K4_1 || 
    //                           load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_1);

    assign bram_control_add1=(load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT || load_weight_state==K3_0 || load_weight_state==K5_2);   
    assign bram_control_add2=(load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || load_weight_state==K4_0 || 
                              load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_0);

    assign bram_port_sel=(load_weight_state==K2_1 || load_weight_state==K3_1 || load_weight_state==K4_1 || load_weight_state==K4_3 || load_weight_state==K5_1 ||
                          load_weight_state==K5_3);

    wire compute_finish;//所有weight都跑完
    assign compute_finish=axi_control_2[5];//TODO:先借用axi_control_2[5]實際上要由control unit來給

    assign load_weight_FSM_start=(load_ifmaps_state==COMPUTE);

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
                                              (kernel_size==5'b10000) ? K5_0:K1_0;//不應該有else
                K1_0:load_weight_state<=weight_from_bram_valid ? K1_LOAD_WEIGHT:K1_0;
                K1_LOAD_WEIGHT:load_weight_state<=all_weight_compute_finish ? LOAD_WEIGHT_IDLE:K1_0;

                K2_0:load_weight_state<=weight_from_bram_valid ? K2_1:K2_0;
                K2_1:load_weight_state<=K2_LOAD_WEIGHT;
                K2_LOAD_WEIGHT:load_weight_state<=all_weight_compute_finish ? LOAD_WEIGHT_IDLE:K2_0;

                K3_0:load_weight_state<=weight_from_bram_valid ? K3_1:K3_0;
                K3_1:load_weight_state<=K3_2;
                K3_2:load_weight_state<=weight_from_bram_valid ? K3_LOAD_WEIGHT:K3_2;
                K3_LOAD_WEIGHT:load_weight_state<=all_weight_compute_finish ? LOAD_WEIGHT_IDLE:K3_0;

                K4_0:load_weight_state<=weight_from_bram_valid ? K4_1:K4_0;
                K4_1:load_weight_state<=K4_2;
                K4_2:load_weight_state<=weight_from_bram_valid ? K4_3:K4_2;
                K4_3:load_weight_state<=K4_LOAD_WEIGHT;
                K4_LOAD_WEIGHT:load_weight_state<=all_weight_compute_finish ? LOAD_WEIGHT_IDLE:K4_0;

                K5_0:load_weight_state<=weight_from_bram_valid ? K5_1:K5_0;
                K5_1:load_weight_state<=K5_2;
                K5_2:load_weight_state<=weight_from_bram_valid ? K5_3:K5_2;
                K5_3:load_weight_state<=K5_4;
                K5_4:load_weight_state<=weight_from_bram_valid ? K5_LOAD_WEIGHT:K5_4;
                K5_LOAD_WEIGHT:load_weight_state<=all_weight_compute_finish ? LOAD_WEIGHT_IDLE:K5_0;

                default: load_weight_state<=LOAD_WEIGHT_IDLE;
            endcase
        end
    end
    
    /////////////////////////////////////////////////
    //                   weight_FSM                //
    /////////////////////////////////////////////////

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            filter_cnt<=0;
        end
        else begin
            if(load_weight_state==LOAD_WEIGHT_IDLE) begin
                filter_cnt<=0;
            end
            else begin
                filter_cnt<=(K1_LOAD_WEIGHT || K2_LOAD_WEIGHT || K3_LOAD_WEIGHT || K4_LOAD_WEIGHT || K5_LOAD_WEIGHT) ? filter_cnt+1:filter_cnt;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            all_weight_compute_finish_delay<=0;
        end
        else begin
            all_weight_compute_finish_delay<=all_weight_compute_finish & 
                                            (load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || 
                                             load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ofmaps_width_cnt<=0;
        end
        else begin
            if(load_ifmaps_state==LOAD_IFMAPS_IDLE) begin
                ofmaps_width_cnt<=0;
            end
            else begin
                if(ofmaps_width_cnt != ofmaps_weight) begin
                    ofmaps_width_cnt<=(all_weight_compute_finish & 
                                  (load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || 
                                   load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT)) ? ofmaps_width_cnt+1:ofmaps_width_cnt;
                end
                else begin
                    ofmaps_width_cnt<=0;
                end
                
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ofmaps_hegiht_cnt<=0;
        end
        else begin
            if(load_ifmaps_state==LOAD_IFMAPS_IDLE) begin
                ofmaps_hegiht_cnt<=0;
            end
            else begin
                ofmaps_hegiht_cnt<=(ofmaps_width_cnt==ofmaps_weight) ? ofmaps_hegiht_cnt+1:ofmaps_hegiht_cnt;
            end
        end
    end

    /////////////////////////////////////////////////
    //                   MAC_enable                //
    /////////////////////////////////////////////////
    
    //FIXME:
    assign MAC_enable_in=input_channel_size[7:0];

    integer idx;
    always @(*) begin
        for(idx=0;idx<MAC_NUM;idx=idx+1) begin
            MAC_enable[idx]=(idx<MAC_enable_in) ? 1:0;
        end
    end
    

    /////////////////////////////////////////////////
    //                   MAC_enable                //
    /////////////////////////////////////////////////


endmodule