// `timescale  1ns / 1ps

// `define INST_COMPUTE 32'd87 
// `define INST_LOADIFMAPS 32'd88 
// `timescale  1ns / 1ps

// module tb_top;

//     // top Parameters
//     parameter PERIOD                = 10 ;
//     parameter MAC_NUM               = 256;
//     parameter BRAM_ADDRESS_WIDTH    = 12 ;
//     parameter C_S_AXIS_TDATA_WIDTH  = 32 ;

//     // top Inputs
//     reg   clk                                  = 0 ;
//     reg   rst_n                                = 0 ;
//     reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  S_AXIS_TDATA = 0 ;
//     reg   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]  S_AXIS_TSTRB = 0 ;
//     reg   S_AXIS_TLAST                         = 0 ;
//     reg   S_AXIS_TVALID                        = 0 ;
//     reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_0 = 0 ;
//     reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_1 = 0 ;
//     reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_2 = 0 ;

//     // top Outputs
//     wire  S_AXIS_TREADY                        ;
//     wire  [1279:0]  psum_out                   ;
//     wire  [C_S_AXIS_TDATA_WIDTH-1 : 0]  axi_control_3 ;
    

//     initial
//     begin
//         forever #(PERIOD/2)  clk=~clk;
//     end

//     initial
//     begin
//         $fsdbDumpfile("top_tb_1.fsdb");
//         $fsdbDumpvars(0);
//     end
//     initial
//     begin
//         #(PERIOD*2) rst_n  =  1;
//         set_CONV();
//         set_input_channel(1);
//         set_kernel_size(5);
//         set_ofmaps_width(3);
//         set_ofmaps_channel(2);
//         // compute_finish(0);
//         #20;
//         axis_in(32'b11111);
//         axis_in(32'b10111);
//         axis_in(32'b11101);
//         axis_in(32'b11011);
//         axis_in(32'b10001);
//         // axis_in(32'b11111);
//         // axis_in(32'b11111);
//         compute_start();
//         axis_in(32'b11111);
//         axis_in(32'b01111);
//         axis_in(32'b10111);
//         axis_in(32'b11011);
//         axis_in(32'b11101);
//         axis_in(32'b11110);
//         axis_in(32'b11101);
//         axis_in(32'b11011);
//         axis_in(32'b10111);
//         axis_in(32'b01111);
//         axis_in(32'b10111);
//         axis_in(32'b11011);
//         axis_in(32'b11101);
//         axis_in(32'b11110);
//         axis_in(32'b11101);
//         axis_in(32'b11011);
//         axis_in(32'b10111);
//         axis_in(32'b01111);
        
//         #10000000;
//         $finish;
//     end
//     top 
//     #(
//         .MAC_NUM              (MAC_NUM              ),
//     )
//     u_top(
//         //global
//     	.clk           (clk           ),
//         .rst_n         (rst_n         ),

//         //AXI_S
//         .S_AXIS_TREADY (S_AXIS_TREADY ),
//         .S_AXIS_TDATA  (S_AXIS_TDATA  ),
//         .S_AXIS_TSTRB  (S_AXIS_TSTRB  ),
//         .S_AXIS_TLAST  (S_AXIS_TLAST  ),
//         .S_AXIS_TVALID (S_AXIS_TVALID ),

//         //temp_out
//         .psum_out      (psum_out      ),
        
//         //AXI_in
//         .S_AXI_AWADDR  (S_AXI_AWADDR  ),
//         .S_AXI_AWPROT  (S_AXI_AWPROT  ),
//         .S_AXI_AWVALID (S_AXI_AWVALID ),
//         .S_AXI_AWREADY (S_AXI_AWREADY ),
//         .S_AXI_WDATA   (S_AXI_WDATA   ),
//         .S_AXI_WSTRB   (S_AXI_WSTRB   ),
//         .S_AXI_WVALID  (S_AXI_WVALID  ),
//         .S_AXI_WREADY  (S_AXI_WREADY  ),
//         .S_AXI_BRESP   (S_AXI_BRESP   ),
//         .S_AXI_BVALID  (S_AXI_BVALID  ),
//         .S_AXI_BREADY  (S_AXI_BREADY  ),
//         .S_AXI_ARADDR  (S_AXI_ARADDR  ),
//         .S_AXI_ARPROT  (S_AXI_ARPROT  ),
//         .S_AXI_ARVALID (S_AXI_ARVALID ),
//         .S_AXI_ARREADY (S_AXI_ARREADY ),
//         .S_AXI_RDATA   (S_AXI_RDATA   ),
//         .S_AXI_RRESP   (S_AXI_RRESP   ),
//         .S_AXI_RVALID  (S_AXI_RVALID  ),
//         .S_AXI_RREADY  (S_AXI_RREADY  )
//     );

//     task axi_control_set(input [31:0]data0,input [31:0]data1,input [31:0]data2);begin
//         axi_control_0=data0;
//         axi_control_1=data1;
//         axi_control_2=data2;   
//     end
//     endtask

//     task set_kernel_size(input [2:0]kernel_size);begin
//         case(kernel_size) 
//             3'd1:axi_control_2[4:0]=5'b00001;
//             3'd2:axi_control_2[4:0]=5'b00010;
//             3'd3:axi_control_2[4:0]=5'b00100;
//             3'd4:axi_control_2[4:0]=5'b01000;
//             3'd5:axi_control_2[4:0]=5'b10000;
//             default :axi_control_2[4:0]=5'b10000;                
//         endcase
        
//     end
//     endtask

//     task compute_start();begin
//         axi_control_0[7:0]=`INST_COMPUTE;
//     end
//     endtask

//     task set_ofmaps_channel(input [11:0] data);begin
//         axi_control_0[31:20]=data;
//     end
//     endtask

//     task set_input_channel(input [8:0]data);begin
//         axi_control_0[19:8]=data;
//     end
//     endtask

//     task set_ofmaps_width(input [8:0]data);begin
//         axi_control_1[10:2]=data;
//     end
//     endtask

//     task set_CONV();begin
//         axi_control_1[0]=0;
//     end
//     endtask

//     task set_POOL();begin
//         axi_control_1[0]=1;
//     end
//     endtask


//     //????????????????????
//     task compute_finish(input [0:0]finish);begin
//         axi_control_2[5]=finish;
//     end
//     endtask

//     task axis_in(input [31:0]data);begin
//         S_AXIS_TDATA=data;
//         S_AXIS_TVALID=1;
//         S_AXIS_TSTRB=0;
//         S_AXIS_TLAST=0;
//         #(PERIOD);
//         S_AXIS_TVALID=0;
//     end
//     endtask

// endmodule

//~ `New testbench
`timescale  1ns / 1ps
`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 
`define INST_WRITE_WEIGHT 32'd12 
module tb_top;

    // top Parameters
    parameter PERIOD                = 20 ;
    parameter MAC_NUM               = 256;
    parameter BRAM_ADDRESS_WIDTH    = 12 ;
    parameter C_S_AXIS_TDATA_WIDTH  = 32 ;
    parameter C_S_AXI_DATA_WIDTH    = 32 ;
    parameter C_S_AXI_ADDR_WIDTH    = 4  ;

    // top Inputs
    reg   clk                                  = 0 ;
    reg   rst_n                                = 0 ;
    reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  S_AXIS_TDATA = 0 ;
    reg   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]  S_AXIS_TSTRB = 0 ;
    reg   S_AXIS_TLAST                         = 0 ;
    reg   S_AXIS_TVALID                        = 0 ;
    reg   [C_S_AXI_ADDR_WIDTH-1 : 0]  S_AXI_AWADDR = 0 ;
    reg   [2 : 0]  S_AXI_AWPROT                = 0 ;
    reg   S_AXI_AWVALID                        = 0 ;
    reg   [C_S_AXI_DATA_WIDTH-1 : 0]  S_AXI_WDATA = 0 ;
    reg   [(C_S_AXI_DATA_WIDTH/8)-1 : 0]  S_AXI_WSTRB = 0 ;
    reg   S_AXI_WVALID                         = 0 ;
    reg   S_AXI_BREADY                         = 0 ;
    reg   [C_S_AXI_ADDR_WIDTH-1 : 0]  S_AXI_ARADDR = 0 ;
    reg   [2 : 0]  S_AXI_ARPROT                = 0 ;
    reg   S_AXI_ARVALID                        = 0 ;
    reg   S_AXI_RREADY                         = 0 ;
    
    reg   watch_set_kernel_size=0;
    reg   watch_set_ofmaps_channel_and_input_channel=0;
    reg   watch_set_function_and_ofmaps_width=0;
    reg   watch_compute_start=0;
    reg   watch_write_weight_start=0;
    reg   watch_read_AXI_3=0;
    // top Outputs
    wire  S_AXIS_TREADY                        ;
    wire  [1279:0]  psum_out                   ;
    wire  S_AXI_AWREADY                        ;
    wire  S_AXI_WREADY                         ;
    wire  [1 : 0]  S_AXI_BRESP                 ;
    wire  S_AXI_BVALID                         ;
    wire  S_AXI_ARREADY                        ;
    wire  [C_S_AXI_DATA_WIDTH-1 : 0]  S_AXI_RDATA ;
    wire  [1 : 0]  S_AXI_RRESP                 ;
    wire  S_AXI_RVALID                         ;


    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        #(PERIOD*2) rst_n  =  1;
        #(PERIOD*5);
        set_kernel_size(5);
        set_ofmaps_channel_and_input_channel(2,1);
        set_function_and_ofmaps_width(0,3);
        // compute_finish(0);
        wait(!clk);
        axis_in(32'b00110);
        axis_in(32'b10001);
        axis_in(32'b11001);
        axis_in(32'b00111);
        axis_in(32'b01001);
        write_weight_start();
        wait(!clk);
        axis_in(32'b01000);
        axis_in(32'b10001);
        axis_in(32'b01010);
        axis_in(32'b00101);
        axis_in(32'b01110);
        //?????????weight
        while(S_AXI_RDATA!=32'd1)begin
            read_AXI_3();
        end
        //?????????ifmaps
        #(PERIOD*5);
        compute_start();
        #20;
        axis_in(32'b11110);
        axis_in(32'b01010);
        axis_in(32'b01011);
        axis_in(32'b01111);
        axis_in(32'b00001);
        axis_in(32'b00101);
        axis_in(32'b10011);
        #1000;

        axis_in(32'b01111);
        axis_in(32'b00101);
        axis_in(32'b00101);
        axis_in(32'b10111);
        axis_in(32'b10000);
        axis_in(32'b00010);
        axis_in(32'b01001);

        #1000;
        axis_in(32'b00111);
        axis_in(32'b00010);
        axis_in(32'b10010);
        axis_in(32'b01011);
        axis_in(32'b01000);
        axis_in(32'b00001);
        axis_in(32'b10100);
        
        #1000000;
        $finish;
    end

    initial
    begin
        $fsdbDumpfile("top_tb_1.fsdb");
        $fsdbDumpvars(0);
    end

    top #(
            .MAC_NUM              ( MAC_NUM              ),
            .BRAM_ADDRESS_WIDTH   ( BRAM_ADDRESS_WIDTH   ),
            .C_S_AXIS_TDATA_WIDTH ( C_S_AXIS_TDATA_WIDTH ),
            .C_S_AXI_DATA_WIDTH   ( C_S_AXI_DATA_WIDTH   ),
            .C_S_AXI_ADDR_WIDTH   ( C_S_AXI_ADDR_WIDTH   ))
    u_top (
        //golbal
        .clk               ( clk                                             ),
        .rst_n             ( rst_n                                           ),

        //AXIS
        .S_AXIS_TDATA      ( S_AXIS_TDATA   [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),
        .S_AXIS_TSTRB      ( S_AXIS_TSTRB   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] ),
        .S_AXIS_TLAST      ( S_AXIS_TLAST                                    ),
        .S_AXIS_TVALID     ( S_AXIS_TVALID                                   ),
        .S_AXIS_TREADY     ( S_AXIS_TREADY                                   ),

        //AXI   
            //AW
        .S_AXI_AWADDR      ( S_AXI_AWADDR   [C_S_AXI_ADDR_WIDTH-1 : 0]       ),
        .S_AXI_AWPROT      ( S_AXI_AWPROT   [2 : 0]                          ),
        .S_AXI_AWVALID     ( S_AXI_AWVALID                                   ),
        .S_AXI_AWREADY     ( S_AXI_AWREADY                                   ),
            //W
        .S_AXI_WREADY      ( S_AXI_WREADY                                    ),
        .S_AXI_WDATA       ( S_AXI_WDATA    [C_S_AXI_DATA_WIDTH-1 : 0]       ),
        .S_AXI_WSTRB       ( S_AXI_WSTRB    [(C_S_AXI_DATA_WIDTH/8)-1 : 0]   ),
        .S_AXI_WVALID      ( S_AXI_WVALID                                    ),
            //B
        .S_AXI_BREADY      ( S_AXI_BREADY                                    ),
        .S_AXI_BRESP       ( S_AXI_BRESP    [1 : 0]                          ),
        .S_AXI_BVALID      ( S_AXI_BVALID                                    ),
            //AR
        .S_AXI_ARREADY     ( S_AXI_ARREADY                                   ),
        .S_AXI_ARADDR      ( S_AXI_ARADDR   [C_S_AXI_ADDR_WIDTH-1 : 0]       ),
        .S_AXI_ARPROT      ( S_AXI_ARPROT   [2 : 0]                          ),
        .S_AXI_ARVALID     ( S_AXI_ARVALID                                   ),
            //R
        .S_AXI_RREADY      ( S_AXI_RREADY                                    ),
        .S_AXI_RDATA       ( S_AXI_RDATA    [C_S_AXI_DATA_WIDTH-1 : 0]       ),
        .S_AXI_RRESP       ( S_AXI_RRESP    [1 : 0]                          ),
        .S_AXI_RVALID      ( S_AXI_RVALID                                    ),

        //tmp_out
        .psum_out          ( psum_out       [1279:0]                         )
    );


    // task axi_control_set(input [31:0]data0,input [31:0]data1,input [31:0]data2);begin
    //     axi_control_0=data0;
    //     axi_control_1=data1;
    //     axi_control_2=data2;   
    // end
    // endtask

    task set_kernel_size(input [2:0]kernel_size);begin
        watch_set_kernel_size=1;

        S_AXI_BREADY=1'b1;
        S_AXI_AWADDR=4'b1000;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b1111;
        case(kernel_size) 
            3'd1:S_AXI_WDATA[4:0]=5'b00001;
            3'd2:S_AXI_WDATA[4:0]=5'b00010;
            3'd3:S_AXI_WDATA[4:0]=5'b00100;
            3'd4:S_AXI_WDATA[4:0]=5'b01000;
            3'd5:S_AXI_WDATA[4:0]=5'b10000;
            default :S_AXI_WDATA[4:0]=5'b10000;                
        endcase

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
                watch_set_kernel_size=0;
            end
            $monitor($time,,"set_kernel_size success");
        end
        // else begin
        //     $monitor($time,,"set_kernel_size WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        //axi_control_2[4:0];
    end
    endtask

    task read_AXI_3();begin
        watch_read_AXI_3=1;

        S_AXI_ARADDR=4'b1100;
        S_AXI_ARPROT=3'b000;
        S_AXI_ARVALID=1'b1;
        S_AXI_RREADY=1'd0;

        wait(S_AXI_ARREADY==1'b1) begin
            wait(S_AXI_RVALID) begin
                    $monitor($time,,"AXI_3 read success");
                if(S_AXI_RDATA==32'd1) begin
                    $monitor($time,,"write_weight_finish");
                end
                else begin
                    $monitor($time,,"write_weight_fail");
                end
                S_AXI_ARVALID=1'b0;
                S_AXI_RREADY=1'b1;
                watch_read_AXI_3=0;
                #(PERIOD*2)
                S_AXI_RREADY=1'b0;

            end            
        end
    end
    endtask

    task write_weight_start();begin
        watch_write_weight_start=1;

        S_AXI_BREADY=1'b1;
        S_AXI_AWADDR=4'b0000;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b0001;
        S_AXI_WDATA=`INST_WRITE_WEIGHT;

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $monitor($time,,"write_weight_start success");
            watch_write_weight_start=0;
        end
        // else begin
        //     $monitor($time,,"compute_start WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_0[7:0]=`INST_COMPUTE;
    end
    endtask

    task compute_start();begin
        watch_compute_start=1;

        S_AXI_BREADY=1'b1;
        S_AXI_AWADDR=4'b0000;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b0001;
        S_AXI_WDATA=`INST_COMPUTE;

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $monitor($time,,"compute_start success");
            watch_compute_start=0;
        end
        // else begin
        //     $monitor($time,,"compute_start WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_0[7:0]=`INST_COMPUTE;
    end
    endtask 

    task set_ofmaps_channel_and_input_channel(input [11:0]ofmaps_channel,input [11:0] input_channel);begin
        watch_set_ofmaps_channel_and_input_channel=1;

        S_AXI_AWADDR=4'b0000;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b1110;
        S_AXI_WDATA={ofmaps_channel,input_channel,8'd0};
        S_AXI_BREADY=1'b1;
            
        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $monitor($time,,"set_ofmaps_channel_and_input_channel success");
            watch_set_ofmaps_channel_and_input_channel=0;

        end
        // else begin
        //     $monitor($time,,"set_ofmaps_channel_and_input_channel WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_0[31:20]=ofmaps_channel;
        // axi_control_0[19:8]=input_channel;
    end
    endtask

    task set_function_and_ofmaps_width(input [1:0] func,input [8:0]data);begin
        watch_set_function_and_ofmaps_width=1;
        
        //0 CONV 1 POOL
        S_AXI_AWADDR=4'b0100;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b1111;
        S_AXI_WDATA={21'd0,data,func};
        S_AXI_BREADY=1'b1;

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $monitor($time,,"set_function_and_ofmaps_width success");
            watch_set_function_and_ofmaps_width=0;
        end
        // else begin
        //     $monitor($time,,"set_function_and_ofmaps_width WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_1[10:2]=data;
    end
    endtask

    // task set_CONV();begin
    //     axi_control_1[1:0]=0;
    // end
    // endtask

    // task set_POOL();begin
    //     axi_control_1[1:0]=1;
    // end
    // endtask

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