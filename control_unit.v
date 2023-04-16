`define INST_COMPUTE 32'd87 
`define INST_WRITE_WEIGHT 32'd12 

module control_unit #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
) (
    //golbal
    input wire clk,
    input wire rst_n,

    //control output  
        //AXI_interface
    output wire layer_finish,
        //MAC
    output reg [MAC_NUM-1:0] MAC_enable,
    output wire [1:0]operation,
    output wire [4:0]kernel_size,
    output wire load_weight_preload,
    output wire load_weight,
    output wire pooling_compute,
    output wire [2:0]stride,
        //ifmaps_preload
    output wire load_ifmaps,
    output wire [11:0] input_channel_size,
    output wire [11:0] output_channel_size,
    output wire axis_en,
    output wire axis_clear,

        //BRAM_control
    output wire bram_write_en,
    output wire bram_port_sel,
    output wire bram_control_add1,
    output wire bram_control_add2,
    output wire bram_transfer_start,
        
    //control input 
    input wire weight_from_bram_valid,
    input wire ifmaps_fifo_empty,
    input wire M_AXIS_output_finsih,
    // input wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_3_in,
    input wire write_weight_finish,
    input wire pooling_finish,

    //AXI_reg
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_0,//主要的控制訊號(loadweight、compute....)
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_1,//附加控制訊號(kernel size、operation...)
    input  wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_2,//附加控制訊號(kernel size、operation...)
    output reg [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_3 //回復訊號(compute over、FIFO_full、read_ofmaps...)
    
);
    //FIXME:MAC_enable等增加round之後要更改input
    localparam LOAD_WEIGHT_IDLE=5'd0,RESET_ADDR=5'd1,K1_0=5'd2,K2_0=5'd3,K2_1=5'd4,K3_0=5'd5,K3_1=5'd6,K3_2=5'd7,
               K4_0=5'd8,K4_1=5'd9,K4_2=5'd10,K4_3=5'd11,K5_0=5'd12,K5_1=5'd13,K5_2=5'd14,K5_3=5'd15,K5_4=5'd16,
               K1_LOAD_WEIGHT=5'd17,K2_LOAD_WEIGHT=5'd18,K3_LOAD_WEIGHT=5'd19,K4_LOAD_WEIGHT=5'd20,K5_LOAD_WEIGHT=5'd21;

    localparam LOAD_IFMAPS_IDLE=5'd0,WAIT_FIFO1=5'd1,LOAD1=5'd2,WAIT_FIFO2=5'd3,LOAD2=5'd4,WAIT_FIFO3=5'd5,LOAD3=5'd6,WAIT_FIFO4=5'd7,
               LOAD4=5'd8,WAIT_FIFO5=5'd9,LOAD5=5'd10,COMPUTE=5'd11,WAIT_FIFO6=5'd12,LOAD=5'd13;

    //WW=write_weight
    localparam WW_IDLE=3'd0,WW_START=3'd1,WW_WAIT=3'd2,WW_FINISH=3'd3;
    
    reg [4:0] load_weight_state; 
    reg [4:0] load_ifmaps_state;
    reg [2:0] write_weight_state;

    reg [11:0] filter_cnt;
    // reg [12:0] write_bram_num;
    // reg [12:0] write_bram_cnt;
    reg [8:0] ofmaps_width_cnt;
    reg [8:0] ofmaps_hegiht_cnt;
    reg [2:0] stride_cnt;

    //buf
    reg axis_en_buf;
    reg axis_clear_buf;
    
    reg pooling_compute_buf;
    reg layer_finish_buf;
    reg inst_compute_buf;
    reg inst_write_weight_buf;

    //inst
    wire inst_compute;
    wire inst_write_weight;
    wire inst_compute_pos_edge;
    wire inst_write_weight_pos_edge;

    //setting
    wire op_conv;
    wire op_pool;
    wire [8:0] ofmaps_width;

    //FSM
    wire load_weight_FSM_start;
    wire load_ifmaps_state_enable;
    wire load_weight_state_enable;
    wire write_weight_state_enable;

    //control
    wire [7:0] MAC_enable_in;
    wire all_finish;
    wire all_weight_compute_finish;
    wire last_weight;
    wire ifmaps_flush;
    wire [11:0] next_filter_cnt;
    wire layer_finish_wire;
    wire axi_control_3_clear;

    // wire [12:0] next_write_bram_cnt;
    
    //decode
    assign inst_compute=(axi_control_0[7:0]==`INST_COMPUTE);
    assign inst_write_weight=(axi_control_0[7:0]==`INST_WRITE_WEIGHT);

    assign input_channel_size=(axi_control_0[19:8]);
    assign output_channel_size=(axi_control_0[31:20]);

    assign operation=(axi_control_1[1:0]);
    assign ofmaps_width=(axi_control_1[10:2]);   
    assign stride=(axi_control_1[13:11]);   

    assign kernel_size=(axi_control_2[4:0]);

    assign op_conv = (operation == 2'd0);
    assign op_pool = (operation == 2'd1);

    assign layer_finish = (layer_finish_wire && (!layer_finish_buf));
    assign layer_finish_wire=(all_finish & all_weight_compute_finish) || (all_finish & op_pool);

    assign bram_transfer_start=(load_weight_state==RESET_ADDR || write_weight_state==WW_START);

    //assign axi_control_3=(write_weight_state==WW_FINISH) ? 32'd1:0;
    assign pooling_compute = (op_pool && (load_ifmaps_state == COMPUTE)) && (!pooling_compute_buf);

    assign axis_en = axis_en_buf | inst_write_weight | inst_compute;
    assign axis_clear = axis_clear_buf | inst_compute_pos_edge;

    assign inst_compute_pos_edge = inst_compute && (!inst_compute_buf);
    assign inst_write_weight_pos_edge = inst_write_weight && (!inst_write_weight_buf);
    assign axi_control_3_clear = (inst_compute_pos_edge | inst_write_weight_pos_edge);
    /////////////////////////////////////////////////
    //                   ifmaps_FSM                //
    /////////////////////////////////////////////////
    assign next_filter_cnt=filter_cnt+1;
    assign last_weight=(next_filter_cnt==output_channel_size);
    assign all_finish=(ofmaps_width_cnt==(ofmaps_width-1) && ofmaps_hegiht_cnt==ofmaps_width-1);
    assign ifmaps_flush=(ofmaps_width_cnt==(ofmaps_width-1));

    assign load_ifmaps=(load_ifmaps_state==LOAD || load_ifmaps_state==LOAD1 || load_ifmaps_state==LOAD2 || load_ifmaps_state==LOAD3 || 
                        load_ifmaps_state==LOAD4 || load_ifmaps_state==LOAD5);

    assign all_weight_compute_finish=last_weight & 
                                    (load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || 
                                     load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT);

    //FIXME:現在這個狀態機是以convolution為主，並且沒有考慮stride=1以外的情況。
    assign load_ifmaps_state_enable = (!inst_compute);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            load_ifmaps_state<=5'd0;
        end
        else begin
            if(load_ifmaps_state_enable) begin
                load_ifmaps_state <= LOAD_IFMAPS_IDLE;
            end
            else begin
                case(load_ifmaps_state)
                    LOAD_IFMAPS_IDLE  :load_ifmaps_state<=(WAIT_FIFO1);
                    WAIT_FIFO1        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO1:LOAD1);
                    LOAD1             :load_ifmaps_state<=((kernel_size==5'b00001) ? COMPUTE:WAIT_FIFO2);
                    WAIT_FIFO2        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO2:LOAD2);
                    LOAD2             :load_ifmaps_state<=((kernel_size==5'b00010) ? COMPUTE:WAIT_FIFO3);
                    WAIT_FIFO3        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO3:LOAD3);
                    LOAD3             :load_ifmaps_state<=((kernel_size==5'b00100) ? COMPUTE:WAIT_FIFO4);
                    WAIT_FIFO4        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO4:LOAD4);
                    LOAD4             :load_ifmaps_state<=((kernel_size==5'b01000) ? COMPUTE:WAIT_FIFO5);
                    WAIT_FIFO5        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO5:LOAD5);
                    LOAD5             :load_ifmaps_state<=(COMPUTE);         
                    COMPUTE           :load_ifmaps_state<=((all_weight_compute_finish || pooling_finish) ? (all_finish ? LOAD_IFMAPS_IDLE:(ifmaps_flush ? WAIT_FIFO1:WAIT_FIFO6)):COMPUTE);
                    WAIT_FIFO6        :load_ifmaps_state<=(ifmaps_fifo_empty ? WAIT_FIFO6:LOAD);
                    LOAD              :load_ifmaps_state<=(stride_cnt+3'd1 == stride) ? COMPUTE : WAIT_FIFO6;
                    default           :load_ifmaps_state<=LOAD_IFMAPS_IDLE;          
                endcase
            end
            
        end
    end
    /////////////////////////////////////////////////
    //                   ifmaps_FSM                //
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    //                read_weight_FSM              //
    /////////////////////////////////////////////////

    //有去read bram的要等weight_from_bram_valid 其餘不用
    assign load_weight_preload=((weight_from_bram_valid) & 
                               (load_weight_state==K1_0 || load_weight_state==K2_0 || load_weight_state==K3_0 || 
                                load_weight_state==K3_2 || load_weight_state==K4_0 || load_weight_state==K4_2 ||
                                load_weight_state==K5_0 || load_weight_state==K5_2 || load_weight_state==K5_4 )) 
                            || (load_weight_state==K2_1 || load_weight_state==K3_1 || load_weight_state==K4_1 || 
                                load_weight_state==K4_3 || load_weight_state==K5_1 || load_weight_state==K5_3);

    assign load_weight=(load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT ||
                        load_weight_state==K3_LOAD_WEIGHT || load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT);

    assign bram_control_add1=weight_from_bram_valid && (load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT || load_weight_state==K3_0 || load_weight_state==K5_4);   
    assign bram_control_add2=weight_from_bram_valid && (load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || load_weight_state==K4_0 || 
                                                        load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_0  || load_weight_state==K5_2);

    assign bram_port_sel=(load_weight_state==K2_1 || load_weight_state==K3_1 || load_weight_state==K4_1 || load_weight_state==K4_3 || load_weight_state==K5_1 ||
                          load_weight_state==K5_3);

    assign load_weight_FSM_start=(load_ifmaps_state==COMPUTE);

    assign load_weight_state_enable = ~(inst_compute && op_conv);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            load_weight_state<=LOAD_WEIGHT_IDLE;
        end 
        else begin
            if(load_weight_state_enable) begin
                load_weight_state<=LOAD_WEIGHT_IDLE;
            end
            else begin
                case (load_weight_state)
                    LOAD_WEIGHT_IDLE:load_weight_state<=(load_weight_FSM_start ? RESET_ADDR:LOAD_WEIGHT_IDLE);
                    RESET_ADDR      :load_weight_state<=((kernel_size==5'b00001) ? K1_0:
                                                        (kernel_size==5'b00010) ? K2_0:
                                                        (kernel_size==5'b00100) ? K3_0:
                                                        (kernel_size==5'b01000) ? K4_0:
                                                        (kernel_size==5'b10000) ? K5_0:K1_0);//不應該有else
                    K1_0            :load_weight_state<=(weight_from_bram_valid ? K1_LOAD_WEIGHT:K1_0);
                    K1_LOAD_WEIGHT  :load_weight_state<=(last_weight ? LOAD_WEIGHT_IDLE:K1_0);

                    K2_0            :load_weight_state<=(weight_from_bram_valid ? K2_1:K2_0);
                    K2_1            :load_weight_state<=(K2_LOAD_WEIGHT);
                    K2_LOAD_WEIGHT  :load_weight_state<=(last_weight ? LOAD_WEIGHT_IDLE:K2_0);

                    K3_0            :load_weight_state<=(weight_from_bram_valid ? K3_1:K3_0);
                    K3_1            :load_weight_state<=(K3_2);
                    K3_2            :load_weight_state<=(weight_from_bram_valid ? K3_LOAD_WEIGHT:K3_2);
                    K3_LOAD_WEIGHT  :load_weight_state<=(last_weight ? LOAD_WEIGHT_IDLE:K3_0);

                    K4_0            :load_weight_state<=(weight_from_bram_valid ? K4_1:K4_0);
                    K4_1            :load_weight_state<=(K4_2);
                    K4_2            :load_weight_state<=(weight_from_bram_valid ? K4_3:K4_2);
                    K4_3            :load_weight_state<=(K4_LOAD_WEIGHT);
                    K4_LOAD_WEIGHT  :load_weight_state<=(last_weight ? LOAD_WEIGHT_IDLE:K4_0);

                    K5_0            :load_weight_state<=(weight_from_bram_valid ? K5_1:K5_0);
                    K5_1            :load_weight_state<=(K5_2);
                    K5_2            :load_weight_state<=(weight_from_bram_valid ? K5_3:K5_2);
                    K5_3            :load_weight_state<=(K5_4);
                    K5_4            :load_weight_state<=(weight_from_bram_valid ? K5_LOAD_WEIGHT:K5_4);
                    K5_LOAD_WEIGHT  :load_weight_state<=(last_weight ? LOAD_WEIGHT_IDLE:K5_0);

                    default: load_weight_state<=LOAD_WEIGHT_IDLE;
                endcase
            end
            
        end
    end
    
    /////////////////////////////////////////////////
    //                read_weight_FSM              //
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    //                write_weight_FSM             //
    /////////////////////////////////////////////////

    // assign next_write_bram_cnt=write_bram_cnt+1;
    assign bram_write_en=(write_weight_state!=WW_IDLE);

    assign write_weight_state_enable = (!inst_write_weight);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_weight_state<=WW_IDLE;
        end
        else begin
            if(write_weight_state_enable) begin
                write_weight_state<=WW_IDLE;
            end
            else begin
                case(write_weight_state)
                    WW_IDLE  :write_weight_state<=WW_START;
                    WW_START :write_weight_state<=WW_WAIT;
                    WW_WAIT  :write_weight_state<=((write_weight_finish) ? WW_FINISH:WW_WAIT);
                    WW_FINISH:write_weight_state<=WW_FINISH;
                    default  :write_weight_state<=WW_IDLE;                 
                endcase
            end
            
        end
    end


    /////////////////////////////////////////////////
    //                write_weight_FSM             //
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
                filter_cnt<=(load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || 
                             load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT) ? next_filter_cnt:filter_cnt;
            end
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
                if(ofmaps_width_cnt != ofmaps_width) begin
                    ofmaps_width_cnt<=((last_weight & 
                                  (load_weight_state==K1_LOAD_WEIGHT || load_weight_state==K2_LOAD_WEIGHT || load_weight_state==K3_LOAD_WEIGHT || 
                                   load_weight_state==K4_LOAD_WEIGHT || load_weight_state==K5_LOAD_WEIGHT)) || (pooling_finish)) ? ofmaps_width_cnt+1:ofmaps_width_cnt;
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
                ofmaps_hegiht_cnt<=(ofmaps_width_cnt==ofmaps_width) ? ofmaps_hegiht_cnt+1:ofmaps_hegiht_cnt;
            end
        end
    end

    /////////////////////////////////////////////////
    //                   MAC_enable                //
    /////////////////////////////////////////////////
    
    //FIXME:MAC_enable等增加round之後要更改input
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

    /////////////////////////////////////////////////
    //                   stride                    //
    /////////////////////////////////////////////////
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            stride_cnt <= 3'd0;
        end
        else begin
            stride_cnt <= (load_ifmaps_state == LOAD) ? stride_cnt+3'd1 : 
                          (load_ifmaps_state == COMPUTE) ? 3'd0 : stride_cnt;
        end
    end
    

    /////////////////////////////////////////////////
    //                   stride                    //
    /////////////////////////////////////////////////

    /////////////////////////////////////////////////
    //                     buf                     //
    /////////////////////////////////////////////////

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            axis_en_buf <= 1'd0;
        end
        else begin
            axis_en_buf <= (layer_finish_wire | write_weight_finish) ? 1'd0 :
                           (inst_write_weight_pos_edge | inst_compute_pos_edge) ? 1'd1 : axis_en_buf;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            axis_clear_buf <= 1'd0;
        end
        else begin
            axis_clear_buf <= write_weight_finish;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            axi_control_3 <= 32'd0;
        end
        else begin
            axi_control_3 <= write_weight_finish ? 32'd1 :
                             (M_AXIS_output_finsih) ? 32'hFFFFFFFF : 
                             (axi_control_3_clear) ? 32'd0 : axi_control_3;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pooling_compute_buf <= 1'd0;
        end
        else begin
            pooling_compute_buf <= (op_pool && (load_ifmaps_state == COMPUTE));

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            layer_finish_buf <= 1'd0;
        end
        else begin
            layer_finish_buf <= layer_finish_wire;

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst_compute_buf <= 1'd0;
        end
        else begin
            inst_compute_buf <= inst_compute;

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            inst_write_weight_buf <= 1'd0;
        end
        else begin
            inst_write_weight_buf <= inst_write_weight;
        end
    end

    /////////////////////////////////////////////////
    //                      buf                    //
    /////////////////////////////////////////////////
    
endmodule