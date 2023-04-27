`timescale  1ns / 1ps
`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 
`define INST_WRITE_WEIGHT 32'd12 

`define TESTFILEDIR    "F:\\vivado_works\\verilog_code\\git_repo\\university_project\\test_data"

`define DEBUG

module tb_auto_read;

    //setting//
    parameter FUNC = 0;
    parameter IFMAPS_WIDTH = 7;
    parameter IFMAPS_HIGHT = 7;
    parameter IFMAPS_CH    = 7;
    parameter WEIGHT_WIDTH = 3;
    parameter WEIGHT_HIGHT = 3;
    parameter WEIGHT_NUM   = 3;
    parameter STRIDE       = 1;
    //////dont touch/////
    parameter OFMAPS_WIDTH = ((IFMAPS_WIDTH - WEIGHT_WIDTH) / STRIDE + 1);
    parameter OFMAPS_HIGHT = ((IFMAPS_HIGHT - WEIGHT_HIGHT) / STRIDE + 1);

    // top Parameters
    parameter PERIOD                = 20 ;
    parameter MAC_NUM               = 256;
    parameter BRAM_ADDRESS_WIDTH    = 12 ;
    parameter C_S_AXIS_TDATA_WIDTH  = 32 ;
    parameter C_S_AXI_DATA_WIDTH    = 32 ;
    parameter C_S_AXI_ADDR_WIDTH    = 4  ;
    parameter C_M_AXIS_TDATA_WIDTH  = 32 ;

    integer w,z,x,y;//for load mem
    integer ofmaps_validation_cnt=0;
    integer psum_validation_cnt=0;
    integer i;
    integer error_flag=0;
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

    reg M_AXIS_TREADY = 1 ;

    wire [C_M_AXIS_TDATA_WIDTH-1:0]       M_AXIS_TDATA;
    wire                                  M_AXIS_TVALID;
    wire						          M_AXIS_TLAST;
    wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB ; 

    reg [0:0] mem_i [0:IFMAPS_CH-1][0:IFMAPS_HIGHT-1][0:IFMAPS_WIDTH-1];
    reg [0:0] mem_w [0:WEIGHT_NUM-1][0:IFMAPS_CH-1][0:WEIGHT_HIGHT-1][0:WEIGHT_WIDTH-1];
    reg [0:0] mem_b [0:WEIGHT_NUM-1];
    reg [31:0] mem_pb [0:WEIGHT_NUM-1][0:OFMAPS_HIGHT-1][0:OFMAPS_WIDTH-1];
    reg [31:0] mem_pa [0:WEIGHT_NUM-1][0:OFMAPS_HIGHT-1][0:OFMAPS_WIDTH-1];
    reg [0:0] mem_o [0:WEIGHT_NUM-1][0:OFMAPS_HIGHT-1][0:OFMAPS_WIDTH-1];

    reg [OFMAPS_WIDTH*OFMAPS_HIGHT*WEIGHT_NUM+32:0] TVALID_ANS = 0;

    assign psum_out = u_top.u_data_path.u_psum_adder.o_data;

    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        #(PERIOD*2) rst_n  =  1;
        #(PERIOD*5);
        load_mem_from_file();

        ////////////////////////////////////////////////////////

        set_kernel_size(WEIGHT_WIDTH);
        set_ofmaps_channel_and_input_channel(WEIGHT_NUM,IFMAPS_CH);
        set_stride_function_ofmaps_width(STRIDE,FUNC,OFMAPS_WIDTH);
        #(PERIOD*5);
    // error_axis_input(3000,0);
        write_weight_start();
        write_weight();

        while(S_AXI_RDATA!=32'd1)begin
            read_AXI_3();
        end

        #(PERIOD*5);
        compute_start();
        #(PERIOD*2);

        @(posedge clk);
        write_ifmaps();
        while(S_AXI_RDATA!=32'hFFFFFFFF)begin
            read_AXI_3();
        end
        
        if(error_flag == 0) begin
            $display("/////////////////////////////////////////////////////////////////////////////////");
            $display("//                                                                             //");
            $display("//                    congratulation you pass the pattern                      //");
            $display("//                                                                             //");
            $display("/////////////////////////////////////////////////////////////////////////////////");
        end
        else begin
            $display("/////////////////////////////////////////////////////////////////////////////////");
            $display("//                                                                             //");
            $display("//           you fail the pattern there are some error in your design          //");
            $display("//                                                                             //");
            $display("/////////////////////////////////////////////////////////////////////////////////");
        end

        #10000;
        $finish;
    end

    
    always @(*) begin
        if(u_top.M_AXIS_TVALID) begin
            $display("time=%7d  M_AXIS_TDATA = %h = %b, M_AXIS_TVALID = %d , M_AXIS_TLAST = %h",$time,u_top.M_AXIS_TDATA,u_top.M_AXIS_TDATA,u_top.M_AXIS_TVALID,u_top.M_AXIS_TLAST);
            for(i=0;i<32;i=i+1) begin
                if(u_top.M_AXIS_TDATA[i] != mem_o[ofmaps_validation_cnt%WEIGHT_NUM][ofmaps_validation_cnt/(WEIGHT_NUM*OFMAPS_WIDTH)][(ofmaps_validation_cnt/WEIGHT_NUM)%OFMAPS_WIDTH]) begin
                    $display("time=%7d  out:M_AXIS_TDATA[%d] = %b , expect: %b",$time,i,u_top.M_AXIS_TDATA[i],mem_o[ofmaps_validation_cnt%WEIGHT_NUM][ofmaps_validation_cnt/(WEIGHT_NUM*OFMAPS_WIDTH)][(ofmaps_validation_cnt/WEIGHT_NUM)%OFMAPS_WIDTH]);   
                    error_flag = 1;
                end
                ofmaps_validation_cnt=ofmaps_validation_cnt+1;
            end
        end
    end

`ifdef DEBUG
    always @(*) begin
        if(u_top.u_data_path.u_psum_adder.o_valid) begin
            $display("time=%7d  psum_binarization_valid = %d , address_out = %h , psum_binarization_data = %h",$time,u_top.u_data_path.u_psum_adder.o_valid,u_top.u_data_path.u_psum_adder.address_out,u_top.u_data_path.u_psum_adder.o_data);
        end
    end
`endif

    always @(*) begin
        if(u_top.u_data_path.u_psum_adder.r_pipe8_valid) begin
`ifdef DEBUG
            $display("time=%7d  psum_after_bias_valid = %d   , address_out = %h , psum_after_bias_data   = %h",$time,u_top.u_data_path.u_psum_adder.r_pipe8_valid,u_top.u_data_path.u_psum_adder.r_pipe8_addr,u_top.u_data_path.u_psum_adder.r_pipe8_data);
`endif   
            if({{18{u_top.u_data_path.u_psum_adder.r_pipe8_data[13]}},u_top.u_data_path.u_psum_adder.r_pipe8_data} != mem_pa [psum_validation_cnt%WEIGHT_NUM][psum_validation_cnt/(WEIGHT_NUM*OFMAPS_WIDTH)][(psum_validation_cnt/WEIGHT_NUM)%OFMAPS_WIDTH]) begin
                $display("time=%7d  no.%d :psum_after_bias_data = %h , expect: %h",$time,psum_validation_cnt,u_top.u_data_path.u_psum_adder.r_pipe8_data,mem_pa[psum_validation_cnt%WEIGHT_NUM][psum_validation_cnt/(WEIGHT_NUM*OFMAPS_WIDTH)][(psum_validation_cnt/WEIGHT_NUM)%OFMAPS_WIDTH]);   
                error_flag = 1;
            end
            psum_validation_cnt=psum_validation_cnt+1;
        end

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
            $display("time=%7d  set_kernel_size success",$time);
        end
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
                // $monitor($time,,"AXI_3 read success");
                if(S_AXI_RDATA==32'd1) begin
                    $display("time=%7d  write_weight_finish",$time);
                end
                else if (S_AXI_RDATA==32'hFFFFFFFF)begin
                    $display("time=%7d  layer_finish",$time);
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
            $display("time=%7d  write_weight_start success",$time);
            watch_write_weight_start=0;
        end
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
            $display("time=%7d  compute_start success",$time);
            watch_compute_start=0;
        end
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
            $display("time=%7d  set_ofmaps_channel_and_input_channel success",$time);
            watch_set_ofmaps_channel_and_input_channel=0;

        end
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
            $display("time=%7d  set_stride_function_ofmaps_width success",$time);
            watch_set_function_and_ofmaps_width=0;
        end
    end
    endtask

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

    task error_axis_input(input integer in_delay, input integer out_delay);begin
        #(in_delay);
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
        #(out_delay);
    end
    endtask

    task load_mem_from_file();begin
        $readmemb($sformatf("%s/ifmaps.txt",`TESTFILEDIR),mem_i);
        $readmemb($sformatf("%s/weight.txt",`TESTFILEDIR),mem_w);
        $readmemb($sformatf("%s/bias.txt",`TESTFILEDIR),mem_b);
        $readmemh($sformatf("%s/psum_before_bias.txt",`TESTFILEDIR),mem_pb);
        $readmemh($sformatf("%s/psum_after_bias.txt",`TESTFILEDIR),mem_pa);
        $readmemb($sformatf("%s/ofmaps.txt",`TESTFILEDIR),mem_o);

`ifdef DEBUG
        $write("ifmaps:\n");
        for(z=0;z<IFMAPS_CH;z=z+1) begin
            for(x=0;x<IFMAPS_HIGHT;x=x+1) begin
                for(y=0;y<IFMAPS_WIDTH;y=y+1) begin
                    $write("%h ",mem_i[z][x][y]);
                end
                $write("\n");
            end
            $write("\n");
        end

        $write("weight:\n");
        for(w=0;w<WEIGHT_NUM;w=w+1) begin
            for(z=0;z<IFMAPS_CH;z=z+1) begin
                for(x=0;x<WEIGHT_HIGHT;x=x+1) begin
                    for(y=0;y<WEIGHT_WIDTH;y=y+1) begin
                        $write("%h ",mem_w[w][z][x][y]);
                    end
                    $write("\n");
                end
                $write("\n");
            end
            $write("\n");
        end

        $write("bias:\n");
        for(y=0;y<WEIGHT_NUM;y=y+1) begin
            $write("%h ",mem_b[y]);
        end
        $write("\n");

        $write("psum_before_bias:\n");
        for(z=0;z<WEIGHT_NUM;z=z+1) begin
            for(x=0;x<OFMAPS_HIGHT;x=x+1) begin
                for(y=0;y<OFMAPS_WIDTH;y=y+1) begin
                    $write("%h ",mem_pb[z][x][y]);
                end
                $write("\n");
            end
            $write("\n");
        end

        $write("psum_after_bias:\n");
        for(z=0;z<WEIGHT_NUM;z=z+1) begin
            for(x=0;x<OFMAPS_HIGHT;x=x+1) begin
                for(y=0;y<OFMAPS_WIDTH;y=y+1) begin
                    $write("%h ",mem_pa[z][x][y]);
                end
                $write("\n");
            end
            $write("\n");
        end

        $write("ofmaps:\n");
        for(z=0;z<WEIGHT_NUM;z=z+1) begin
            for(x=0;x<OFMAPS_HIGHT;x=x+1) begin
                for(y=0;y<OFMAPS_WIDTH;y=y+1) begin
                    $write("%h ",mem_o[z][x][y]);
                end
                $write("\n");
            end
            $write("\n");
        end

`endif
        $write("M_AXIS_ANS:\n");
        for(ofmaps_validation_cnt = 0 ; ofmaps_validation_cnt < OFMAPS_HIGHT*OFMAPS_WIDTH*WEIGHT_NUM;ofmaps_validation_cnt=ofmaps_validation_cnt+1) begin
            TVALID_ANS[ofmaps_validation_cnt] = mem_o[ofmaps_validation_cnt%WEIGHT_NUM][ofmaps_validation_cnt/(WEIGHT_NUM*OFMAPS_WIDTH)][(ofmaps_validation_cnt/WEIGHT_NUM)%OFMAPS_WIDTH];
        end
        for(x=0;(x * 32) < OFMAPS_HIGHT*OFMAPS_WIDTH*WEIGHT_NUM;x=x+1) begin
            $write("%h\n",TVALID_ANS[x*32 +: 32]);
        end

        $display("load test data finish");
    end
    endtask

    reg[31:0] write_weight_reg;
    task write_weight(); begin
        $display("write weight start");
        for(x=0;x<WEIGHT_NUM;x=x+1) begin
            wait(!clk);
            for(y=0;y<WEIGHT_WIDTH;y=y+1) begin
                for(z=0;z<IFMAPS_CH;z=z+6) begin
                    write_weight_reg[30]=1'd0;
                    write_weight_reg[31]=1'd0;
                    for(w=0;w<30;w=w+1) begin
                        if( (w%5 >= WEIGHT_HIGHT) || (((w/5) + z)>=IFMAPS_CH) ) begin
                            write_weight_reg[w]=1'd0;
                        end
                        else begin
                            write_weight_reg[w]=mem_w[x][((w / 5) + z)][(w%5)][y];
                        end


                        // if(((w / 5) + z)<IFMAPS_CH) begin
                        //     if((w%5)>=WEIGHT_HIGHT) begin
                        //         write_weight_reg[w]=1'd0;
                        //     end
                        //     else begin
                        //         write_weight_reg[w]=mem_w[x][((w / 5) + z)][(w%5)][y];
                        //     end
                        // end
                        // else begin
                        //     write_weight_reg[w]=1'd0;
                        // end
                        
                    end
`ifdef DEBUG
                        $display("%h     %b",write_weight_reg,write_weight_reg);
`endif 
                    axis_in(write_weight_reg);
                end
            end
`ifdef DEBUG
            $display("\n");
`endif
        end
    end
    endtask

    reg[31:0] write_ifmaps_reg;
    task write_ifmaps(); begin
        $display("write ifmaps start");
        for(x=0;x<OFMAPS_HIGHT;x=x+1) begin
            for(y=0;y<IFMAPS_WIDTH;y=y+1) begin
                for(z=0;z<IFMAPS_CH;z=z+6) begin
                    write_ifmaps_reg[30]=1'd0;
                    write_ifmaps_reg[31]=1'd0;
                    for(w=0;w<30;w=w+1) begin 
                        if( (w%5 >= WEIGHT_HIGHT) || (((w/5) + z)>=IFMAPS_CH) ) begin
                            write_ifmaps_reg[w]=1'd0;
                        end
                        else begin
                            write_ifmaps_reg[w]=mem_i[(w / 5) + z][(w%5)+x][y];
                        end

                        // if( (((w/5)*((z/6)+1))<IFMAPS_CH) ) begin
                        //     if(((w / 5) + z)>=IFMAPS_CH  || w%5>=WEIGHT_HIGHT ) begin
                        //         write_ifmaps_reg[w]=1'd0;
                        //     end
                        //     else begin
                        //         write_ifmaps_reg[w]=mem_i[(w / 5) + z][(w%5)+x][y];
                        //     end
                        // end
                        // else begin
                        //     write_ifmaps_reg[w]=1'd0;
                        // end
                        
                    end
`ifdef DEBUG
                    $display("%h    %b",write_ifmaps_reg,write_ifmaps_reg);
`endif
                    axis_in(write_ifmaps_reg);
                end
            end
`ifdef DEBUG
            $display("\n");
`endif
        end
        $display("write ifmaps finish");
    end
    endtask
    
endmodule