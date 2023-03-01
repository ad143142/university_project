`timescale  1ns / 1ps

module tb_psum_adder;

// psum_adder Parameters
parameter PERIOD                  = 10  ;       
parameter PSUM_IN_WIDTH           = 1280;       
parameter OFMAPS_BRAM_ADDR_WIDTH  = 12  ;       

// psum_adder Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [7:0]  in_channel                    = 0 ;
reg   [2:0]  kernel_size                   = 0 ;
reg   [PSUM_IN_WIDTH-1:0]  psum_in         = 0 ;
reg   [OFMAPS_BRAM_ADDR_WIDTH-1:0]  address_in = 0 ;
reg   i_valid                              = 0 ;

// psum_adder Outputs
wire  o_data                               ;
wire  [OFMAPS_BRAM_ADDR_WIDTH-1:0 ]  address_out ;
wire  o_valid                              ;


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

    .psum_in                 ( psum_in      [PSUM_IN_WIDTH-1:0]           ),
    .address_in              ( address_in   [OFMAPS_BRAM_ADDR_WIDTH-1:0]  ),
    .i_valid                 ( i_valid                                    ),

    .o_data                  ( o_data                                     ),
    .address_out             ( address_out  [OFMAPS_BRAM_ADDR_WIDTH-1:0 ] ),
    .o_valid                 ( o_valid                                    )
);

initial
begin
    in_channel = 2;
    kernel_size = 5;

    #(PERIOD*10);

    // set_psum_address(1280'h209,12'h3f1);//209=16 9
    set_psum_address(1280'h209        ,12'h123);//209=16 9
    #(PERIOD*1);
    set_psum_address(1280'h208        ,12'h333);//209=16 9
    #(PERIOD*2);
    set_psum_address(1280'b10000_01100,12'h213);//16 12
    #(PERIOD*3);
    set_psum_address(1280'b11001_11001,12'haa1);//25 25
    #(PERIOD*4);
    set_psum_address(1280'b01001_11001,12'hf1f);//9 25
    #(PERIOD*5);
    set_psum_address(1280'b01001_00001,12'habc);//9 1
    #(PERIOD*6);
    set_psum_address(1280'b00000_00000,12'h690);//0 0
    #(PERIOD*7);
    set_psum_address(1280'b00010_00001,12'h745);//2 1
    #(PERIOD*1);
    set_psum_address(1280'b10010_00111,12'h743);//18 7
    #(PERIOD*2);
    set_psum_address(1280'b10010_10010,12'h111);//18 18

    #(PERIOD*100);
    $finish;
end

always @(negedge clk ) begin
    if(o_valid)
        $display($time,"  o_valid = %d , address_out = %h , o_data = %h",o_valid,address_out,o_data);
end



task set_psum_address(input [1279:0] psum,input [11:0]addr_in);begin

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