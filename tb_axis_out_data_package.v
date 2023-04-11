`timescale  1ns / 1ps

module tb_axis_out_data_package;   

// axis_out_data_package Parameters
parameter PERIOD                = 10;
parameter FIFO_DEPTH            = 4 ;
parameter C_M_AXIS_TDATA_WIDTH  = 32;

// axis_out_data_package Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   layer_finish                         = 0 ;
reg   in_valid                             = 0 ;
reg   in_data                              = 0 ;
reg   M_AXIS_TREADY                        = 1 ;
// axis_out_data_package Outputs
wire  out_valid                            ;
wire  out_last                             ;
wire  [C_M_AXIS_TDATA_WIDTH-1:0]  out_data ;
wire  [C_M_AXIS_TDATA_WIDTH-1:0]  M_AXIS_TDATA;
wire  M_AXIS_TVALID;
wire  M_AXIS_TLAST;
wire  [3:0]M_AXIS_TSTRB;
initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


axis_out_data_package #(
    .FIFO_DEPTH           ( FIFO_DEPTH           ),
    .C_M_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH ))
 u_axis_out_data_package (
    .clk                     ( clk                                      ),
    .rst_n                   ( rst_n                                    ),
    .layer_finish            ( layer_finish                             ),
    .in_valid                ( in_valid                                 ),
    .in_data                 ( in_data                                  ),

    .out_valid               ( out_valid                                ),
    .out_data                ( out_data      [C_M_AXIS_TDATA_WIDTH-1:0] ),
    .out_last                ( out_last                                 )
);

axis_master #(
    .FIFO_DEPTH           ( FIFO_DEPTH           ),
    .C_M_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH ))
 u_axis_master (
    .M_AXIS_ACLK             ( clk                                      ),
    .M_AXIS_ARESETN          ( rst_n                                   ),
    .TDATA_in                ( out_data        [C_M_AXIS_TDATA_WIDTH-1:0]       ),
    .TVALID_in               ( out_valid                                        ),
    .TLAST_in                ( out_last                                         ),
    .M_AXIS_TREADY           ( M_AXIS_TREADY                                    ),

    .M_AXIS_TDATA            ( M_AXIS_TDATA    [C_M_AXIS_TDATA_WIDTH-1:0]       ),
    .M_AXIS_TVALID           ( M_AXIS_TVALID                                    ),
    .M_AXIS_TLAST            ( M_AXIS_TLAST                                     ),
    .M_AXIS_TSTRB            ( M_AXIS_TSTRB    [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] )
);

integer i;
initial
begin

    #(PERIOD*2) rst_n  =  1;
    psum_input_32_bit(32'h12345678);
    psum_input_32_bit(32'h9abcdef0);
    psum_input_32_bit(32'h98765432);
    psum_input_one_bit(1);
    layer_fin();
    psum_input_32_bit(32'haaaaaaaa);
    psum_input_32_bit(32'hffffffff);
    psum_input_32_bit(32'h00000000);
    psum_input_one_bit(1);
    psum_input_one_bit(1);
    psum_input_one_bit(1);
    psum_input_one_bit(0);
    psum_input_one_bit(1);
    layer_fin();
    #1000;
    $finish;
end

always @(negedge clk) begin
    if(out_valid)
    $display($time,"  out_data = %h , out_valid = %d , out_last = %d",u_axis_out_data_package.out_data,u_axis_out_data_package.out_valid,u_axis_out_data_package.out_last);
end
always @(*) begin
    if(u_axis_master.M_AXIS_TVALID && M_AXIS_TREADY)
        $display($time,"  M_AXIS_TDATA = %h , M_AXIS_TVALID = %d , M_AXIS_TLAST = %h",u_axis_master.M_AXIS_TDATA,u_axis_master.M_AXIS_TVALID,u_axis_master.M_AXIS_TLAST);
end
task psum_input_32_bit(input[31:0] data);begin
        for(i=0;i < 32 ; i=i+1) begin
            psum_input_one_bit(data[i]);
        end
    end
endtask

task psum_input_one_bit(input data);begin
        in_data = data;
        in_valid = 1'd1;
        #(PERIOD*1)
        in_valid = 1'd0;
    end
endtask

task layer_fin();begin
        layer_finish = 1'd1;
        #(PERIOD*1)
        layer_finish = 1'd0;
    end
endtask

endmodule