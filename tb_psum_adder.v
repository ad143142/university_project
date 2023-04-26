`timescale  1ns / 1ps

module tb_psum_adder;

// psum_adder Parameters
parameter PERIOD                  = 10  ;       
parameter PSUM_IN_WIDTH           = 6*256;       
parameter OFMAPS_BRAM_ADDR_WIDTH  = 12  ;       

// psum_adder Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [7:0]  in_channel                    = 0 ;
reg   [2:0]  kernel_size                   = 0 ;
reg   [PSUM_IN_WIDTH-1:0]  psum_in         = 0 ;
reg   [OFMAPS_BRAM_ADDR_WIDTH-1:0]  address_in = 0 ;
reg   i_valid                              = 0 ;
reg   layer_finish                         = 0 ;
// psum_adder Outputs
wire  o_data                               ;
wire  [OFMAPS_BRAM_ADDR_WIDTH-1:0 ]  address_out ;
wire  o_valid                              ;
wire  o_last                               ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

psum_adder #(
    .PSUM_IN_WIDTH          ( PSUM_IN_WIDTH          ),
    .OFMAPS_BRAM_ADDR_WIDTH ( OFMAPS_BRAM_ADDR_WIDTH ))
 u_psum_adder (
    .clk                     ( clk                                        ),
    .rst_n                   ( rst_n                                      ),

    .in_channel              ( in_channel   [7:0]                         ),
    .kernel_size             ( kernel_size  [2:0]                         ),
    .layer_finish            ( layer_finish                               ),

    .psum_in                 ( psum_in      [PSUM_IN_WIDTH-1:0]           ),
    .address_in              ( address_in   [OFMAPS_BRAM_ADDR_WIDTH-1:0]  ),
    .i_valid                 ( i_valid                                    ),

    .o_last                  ( o_last                                     ),
    .o_data                  ( o_data                                     ),
    .address_out             ( address_out  [OFMAPS_BRAM_ADDR_WIDTH-1:0 ] ),
    .o_valid                 ( o_valid                                    )
);

initial
begin
    in_channel = 2;
    kernel_size = 5;

    #(PERIOD*10);

    set_two_num_psum_address(25,-25,12'hAB2);
    set_two_num_psum_address(-25,-25,12'hAB2);
    set_two_num_psum_address(25,25,12'hAB2);
    set_two_num_psum_address(1,-25,12'hAB2);
    set_two_num_psum_address(2,3,12'hAB2);
    set_two_num_psum_address(-5,-2,12'hAB2);
    set_two_num_psum_address(3,-5,12'hAB2);
    set_two_num_psum_address(-5,3,12'hAB2);

    #(PERIOD*100);
    $finish;
end

always @(negedge clk ) begin
    if(o_valid)
        $display($time,"  o_valid = %d , address_out = %h , o_data = %h",o_valid,address_out,o_data);
end

task set_two_num_psum_address(input [5:0]num1,input [5:0]num2,input [11:0]addr_in);begin

        psum_in = {1524'd0,num2,num1};
        address_in = addr_in;
        i_valid=1'd1;

        #(PERIOD*1) 

        i_valid = 1'd0;
        psum_in = 1536'd0;
        address_in = 12'd0;
    end
endtask

task set_psum_address(input [6*256-1:0] psum,input [11:0]addr_in);begin

        psum_in = psum;
        address_in = addr_in;
        i_valid=1'd1;

        #(PERIOD*1) 

        i_valid = 1'd0;
        psum_in = 1280'd0;
        address_in = 12'd0;
    end
endtask

endmodule