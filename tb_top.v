`timescale  1ns / 1ps

`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 
`timescale  1ns / 1ps

module tb_top;

    // top Parameters
    parameter PERIOD                = 10 ;
    parameter MAC_NUM               = 256;
    parameter BRAM_ADDRESS_WIDTH    = 12 ;
    parameter C_S_AXIS_TDATA_WIDTH  = 32 ;

    // top Inputs
    reg   clk                                  = 0 ;
    reg   rst_n                                = 0 ;
    reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  S_AXIS_TDATA = 0 ;
    reg   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]  S_AXIS_TSTRB = 0 ;
    reg   S_AXIS_TLAST                         = 0 ;
    reg   S_AXIS_TVALID                        = 0 ;
    reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_0 = 0 ;
    reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_1 = 0 ;
    reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_2 = 0 ;

    // top Outputs
    wire  S_AXIS_TREADY                        ;
    wire  [1279:0]  psum_out                   ;
    wire  [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_3 ;
    

    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        $fsdbDumpfile("top_tb.fsdb");
        $fsdbDumpvars(0);
    end
    initial
    begin
        #(PERIOD*2) rst_n  =  1;
        set_CONV();
        set_input_channel(1);
        set_kernel_size(5);
        set_ofmaps_width(3);
        set_ofmaps_channel(2);
        // compute_finish(0);
        #20;
        axis_in(32'b11111);
        axis_in(32'b10111);
        axis_in(32'b11101);
        axis_in(32'b11011);
        axis_in(32'b10001);
        // axis_in(32'b11111);
        // axis_in(32'b11111);
        compute_start();
        axis_in(32'b11111);
        axis_in(32'b01111);
        axis_in(32'b10111);
        axis_in(32'b11011);
        axis_in(32'b11101);
        axis_in(32'b11110);
        axis_in(32'b11101);
        axis_in(32'b11011);
        axis_in(32'b10111);
        axis_in(32'b01111);
        axis_in(32'b10111);
        axis_in(32'b11011);
        axis_in(32'b11101);
        axis_in(32'b11110);
        axis_in(32'b11101);
        axis_in(32'b11011);
        axis_in(32'b10111);
        axis_in(32'b01111);
        
        #10000000;
        $finish;
    end

    top #(
            .MAC_NUM              ( MAC_NUM              ),
            .BRAM_ADDRESS_WIDTH   ( BRAM_ADDRESS_WIDTH   ),
            .C_S_AXIS_TDATA_WIDTH ( C_S_AXIS_TDATA_WIDTH ))
        u_top (
            .clk                     ( clk                                             ),
            .rst_n                   ( rst_n                                           ),
            .S_AXIS_TDATA            ( S_AXIS_TDATA   [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),
            .S_AXIS_TSTRB            ( S_AXIS_TSTRB   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] ),
            .S_AXIS_TLAST            ( S_AXIS_TLAST                                    ),
            .S_AXIS_TVALID           ( S_AXIS_TVALID                                   ),
            .axi_control_0           ( axi_control_0  [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),
            .axi_control_1           ( axi_control_1  [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),
            .axi_control_2           ( axi_control_2  [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),

            .S_AXIS_TREADY           ( S_AXIS_TREADY                                   ),
            .psum_out                ( psum_out       [1279:0]                         ),
            .axi_control_3           ( axi_control_3  [C_S_AXIS_TDATA_WIDTH-1 : 0]     )
    );

    task axi_control_set(input [31:0]data0,input [31:0]data1,input [31:0]data2);begin
        axi_control_0=data0;
        axi_control_1=data1;
        axi_control_2=data2;   
    end
    endtask

    task set_CONV();begin
        axi_control_1=0;
    end
    endtask

    task set_POOL();begin
        axi_control_1[0]=1;
    end
    endtask

    task set_kernel_size(input [2:0]kernel_size);begin
        case(kernel_size) 
            3'd1:axi_control_2[4:0]=5'b00001;
            3'd2:axi_control_2[4:0]=5'b00010;
            3'd3:axi_control_2[4:0]=5'b00100;
            3'd4:axi_control_2[4:0]=5'b01000;
            3'd5:axi_control_2[4:0]=5'b10000;
            default :axi_control_2[4:0]=5'b10000;                
        endcase
        
    end
    endtask

    task compute_start();begin
        axi_control_0[7:0]=`INST_COMPUTE;
    end
    endtask

    task set_ofmaps_channel(input [11:0] data);begin
        axi_control_0[31:20]=data;
    end
    endtask

    task set_ofmaps_width(input [8:0]data);begin
        axi_control_1[10:2]=data;
    end
    endtask

    task set_input_channel(input [8:0]data);begin
        axi_control_0[19:8]=data;
    end
    endtask

    //?��?��不用
    task compute_finish(input [0:0]finish);begin
        axi_control_2[5]=finish;
    end
    endtask

    task axis_in(input [31:0]data);begin
        S_AXIS_TDATA=data;
        S_AXIS_TVALID=1;
        S_AXIS_TSTRB=0;
        S_AXIS_TLAST=0;
        #(PERIOD);
        S_AXIS_TVALID=0;
    end
    endtask

endmodule