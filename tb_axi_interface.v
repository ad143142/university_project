`timescale  1ns / 1ps
`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 
`define INST_WRITE_WEIGHT 32'd12 
module tb_axi_interface;

    // top Parameters
    parameter PERIOD                = 20 ;
    parameter MAC_NUM               = 256;
    parameter BRAM_ADDRESS_WIDTH    = 12 ;
    parameter C_S_AXIS_TDATA_WIDTH  = 32 ;
    parameter C_S_AXI_DATA_WIDTH    = 32 ;
    parameter C_S_AXI_ADDR_WIDTH    = 5  ;
    parameter C_M_AXIS_TDATA_WIDTH  = 32 ;

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
    reg   watch_read_AXI=0;
    reg   watch_write_AXI=0;
    reg   watch_read_FSM=0;
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

    reg M_AXIS_TREADY = 1 ;

    wire [C_M_AXIS_TDATA_WIDTH-1:0]       M_AXIS_TDATA;
    wire                                  M_AXIS_TVALID;
    wire						          M_AXIS_TLAST;
    wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB ; 

    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        #(PERIOD*2) rst_n  =  1;
        #(PERIOD*5);
        
        set_kernel_size(3'd5);
        set_ofmaps_channel_and_input_channel(2,2);
        set_stride_function_ofmaps_width(1,0,3);
        // compute_finish(0);
        @(posedge clk);
        read_FSM();
        write_weight_start();
        read_FSM();

        fork
            begin
                wait(!clk);
                axis_in(32'b0110100110);
                axis_in(32'b0100110001);
                axis_in(32'b0110011001);
                axis_in(32'b1101100111);
                axis_in(32'b0011001001);
                
                wait(!clk);
                axis_in(32'b0011101000);
                axis_in(32'b1001110001);
                axis_in(32'b0100101010);
                axis_in(32'b1010100101);
                axis_in(32'b0101001110);

                //more
                // #3000;
                axis_in(32'b1111111111);
                axis_in(32'b1000000111);
                axis_in(32'b1110000001);
                axis_in(32'b1110001000);
                axis_in(32'b0101100001);
                axis_in(32'b1110001000);
                axis_in(32'b0101100001);
                axis_in(32'b1110001000);
                axis_in(32'b0101100001);
                axis_in(32'b1110001000);
                axis_in(32'b0101100001);
                axis_in(32'b1000000111);
            end
            begin
                @(posedge clk);
                read_AXI(0);
                read_AXI(1);
                read_AXI(2);
                read_AXI(3);
                // write_AXI(4,32'h1234abcd);
                // read_AXI(4);
                write_AXI(5,32'habcd1234);
                read_AXI(5);
                write_AXI(6,32'hfedcba98);
                read_AXI(6);
                write_AXI(7,32'h76543210);
                read_AXI(7);

                read_FSM();
                #(PERIOD*3)
                read_FSM();

            end
            
        join
        

        //以�?�是weight
        while(S_AXI_RDATA!=32'd1)begin
            read_AXI(3);
        end

        #(PERIOD*5);
        compute_start();
        #20;

        fork
            begin
                axis_in(32'b1100111110);
                axis_in(32'b1110001010);
                axis_in(32'b0100101011);
                axis_in(32'b0011001111);
                axis_in(32'b0101100001);
                axis_in(32'b1001100101);
                axis_in(32'b0100110011);
                // #1000;

                axis_in(32'b1110001111);
                axis_in(32'b1111000101);
                axis_in(32'b1010000101);
                axis_in(32'b0001110111);
                axis_in(32'b0010110000);
                axis_in(32'b0100100010);
                axis_in(32'b1010001001);

                // #1000;
                axis_in(32'b1111000111);
                axis_in(32'b1111100010);
                axis_in(32'b1101010010);
                axis_in(32'b0000101011);
                axis_in(32'b1001001000);
                axis_in(32'b0010000001);
                axis_in(32'b1101010100);

                // #3000;
                //more
                axis_in(32'b1100010100);
                axis_in(32'b0001101011);
                axis_in(32'b1110001000);
                axis_in(32'b0101100001);
                axis_in(32'b1100010100);
            end
            begin
                
                read_AXI(0);
                read_AXI(1);
                read_AXI(2);
                read_AXI(3);
                // write_AXI(4,32'h76543210);
                // read_AXI(4);
                write_AXI(5,32'hfedcba98);
                read_AXI(5);
                write_AXI(6,32'habcd1234);
                read_AXI(6);
                write_AXI(7,32'h1234abcd);
                read_AXI(7);

                read_FSM();
                #(PERIOD*3)
                read_FSM();
            end
            
        join
      
        while(S_AXI_RDATA!=32'hFFFFFFFF)begin
            read_AXI(3);
        end
        #(PERIOD*3)
        read_FSM();
        #10000;
        $finish;
    end

    //FIXME:紅�?�是�?常�??
    integer i;
    integer out=0;
    
    //FIXME:紅�?�是�?常�??
    always @(negedge clk ) begin
        if(u_top.u_data_path.u_psum_adder.o_valid)
            $display($time,"  o_valid = %d , address_out = %h , o_data = %h",u_top.u_data_path.u_psum_adder.o_valid,u_top.u_data_path.u_psum_adder.address_out,u_top.u_data_path.u_psum_adder.o_data);
    end
    always @(*) begin
        if(u_top.u_axis_master.M_AXIS_TVALID && M_AXIS_TREADY)
            $display($time,"  M_AXIS_TDATA = %h , M_AXIS_TVALID = %d , M_AXIS_TLAST = %h",u_top.u_axis_master.M_AXIS_TDATA,u_top.u_axis_master.M_AXIS_TVALID,u_top.u_axis_master.M_AXIS_TLAST);
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
        .M_AXIS_TREADY     ( M_AXIS_TREADY                                   ),

        .M_AXIS_TDATA      ( M_AXIS_TDATA    [C_M_AXIS_TDATA_WIDTH-1:0]      ),
        .M_AXIS_TVALID     ( M_AXIS_TVALID                                   ),
        .M_AXIS_TLAST      ( M_AXIS_TLAST                                    ),
        .M_AXIS_TSTRB      ( M_AXIS_TSTRB    [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0])
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
            $display($time,,"set_kernel_size success");
        end
        // else begin
        //     $display($time,,"set_kernel_size WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        //axi_control_2[4:0];
    end
    endtask

    task write_AXI(input [2:0] addr,input [31:0] data);begin
        watch_write_AXI=1;
        
        S_AXI_AWADDR={addr,2'd0};
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b1111;
            
        S_AXI_WDATA=data;
        S_AXI_BREADY=1'b1;

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $display($time,,"write AXI[%d] = %h success",addr,data);
            watch_write_AXI=0;
        end
        // else begin
        //     $display($time,,"set_function_and_ofmaps_width WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_1[10:2]=ofmaps_width;
    end
    endtask

    task read_AXI(input [2:0] addr);begin
        @(posedge clk);
        watch_read_AXI=1;

        S_AXI_ARADDR={addr,2'd0};
        S_AXI_ARPROT=3'b000;
        S_AXI_ARVALID=1'b1;
        S_AXI_RREADY=1'd0;

        wait(S_AXI_ARREADY==1'b1) begin
            wait(S_AXI_RVALID) begin
                $display($time,,"read AXI[%d] = %d = %h = %b ",addr,S_AXI_RDATA,S_AXI_RDATA,S_AXI_RDATA);

                S_AXI_ARVALID=1'b0;
                S_AXI_RREADY=1'b1;
                watch_read_AXI=0;
                #(PERIOD*2)
                S_AXI_RREADY=1'b0;

            end            
        end
    end
    endtask
    task read_FSM();begin
        @(posedge clk);
        watch_read_FSM=1;

        S_AXI_ARADDR={3'd4,2'd0};
        S_AXI_ARPROT=3'b000;
        S_AXI_ARVALID=1'b1;
        S_AXI_RREADY=1'd0;

        wait(S_AXI_ARREADY==1'b1) begin
            wait(S_AXI_RVALID) begin
                $display("control_load_weight_state = %d\ncontrol_load_ifmaps_state = %d\ncontrol_write_weight_state = %d\nbram_control_read_state = %d\nbram_control_write_state = %d",S_AXI_RDATA[4:0],S_AXI_RDATA[9:5],S_AXI_RDATA[12:10],S_AXI_RDATA[14:13],S_AXI_RDATA[17:15]);

                S_AXI_ARVALID=1'b0;
                S_AXI_RREADY=1'b1;
                watch_read_FSM=0;
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
            $display($time,,"write_weight_start success");
            watch_write_weight_start=0;
        end
        // else begin
        //     $display($time,,"compute_start WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
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
            $display($time,,"compute_start success");
            watch_compute_start=0;
        end
        // else begin
        //     $display($time,,"compute_start WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
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
            $display($time,,"set_ofmaps_channel_and_input_channel success");
            watch_set_ofmaps_channel_and_input_channel=0;

        end
        // else begin
        //     $display($time,,"set_ofmaps_channel_and_input_channel WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_0[31:20]=ofmaps_channel;
        // axi_control_0[19:8]=input_channel;
    end
    endtask

    task set_stride_function_ofmaps_width(input [2:0] stride,input [1:0] func,input [8:0]ofmaps_width);begin
        watch_set_function_and_ofmaps_width=1;
        
        //0 CONV 1 POOL
        //[1:0] function
        //[10:2] ofmaps_width
        //[13:11]stride
        S_AXI_AWADDR=4'b0100;
        S_AXI_AWPROT=3'b000;
        S_AXI_WSTRB=4'b1111;
            
        S_AXI_WDATA={18'd0,stride,ofmaps_width,func};
        S_AXI_BREADY=1'b1;

        S_AXI_AWVALID=1'b1;
        S_AXI_WVALID=1'b1;

        wait(S_AXI_AWREADY==1'b1 && S_AXI_WREADY==1'b1) begin
            
            wait(S_AXI_BVALID) begin
                S_AXI_AWVALID=1'b0;
                S_AXI_WVALID=1'b0;
            end
            $display($time,,"set_stride_function_ofmaps_width success");
            watch_set_function_and_ofmaps_width=0;
        end
        // else begin
        //     $display($time,,"set_function_and_ofmaps_width WRITE ERROR : S_AXI_AWREADY= %b   S_AXI_WREADY= %b",S_AXI_AWREADY,S_AXI_WREADY);
        // end
        // axi_control_1[10:2]=ofmaps_width;
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
        S_AXIS_TVALID=1;
        S_AXIS_TDATA=data;
        S_AXIS_TSTRB=0;
        S_AXIS_TLAST=0;
        
        @(posedge clk);
        while(~S_AXIS_TREADY) begin
            @(posedge clk);
        end

        S_AXIS_TVALID=0;
    end
    endtask

endmodule