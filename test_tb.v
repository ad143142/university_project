module test_tb;
    parameter PERIOD   = 20 ;
    parameter MAC_NUM  = 256;
    parameter BRAM_ADDRESS_WIDTH=12;


    reg   clk                                  = 0 ;
    reg   rst_n                                = 0 ;
    reg address_reset=0;
    reg read_en=0;
    reg read_length=0;
    wire data_valid;
    wire [1279:0]weight_out_0;


    wire  [5*MAC_NUM-1:0]  psum_out            ;


    initial
    begin
        forever #(PERIOD/2)  clk=~clk;
    end

    initial
    begin
        clk=0;
        rst_n=0;
        #20;
        rst_n=1;
        #20;
        rst_n=0;
        #20;
        rst_n=1;
        #40;
        address_reset=1;
        read_en=1;
        read_length=1;
        #20
        address_reset=0;
        $finish;
    end

    wire [5*MAC_NUM-1:0] bram_dout_a,bram_dout_b;
    wire [5*MAC_NUM-1:0] weight_out;
    wire [BRAM_ADDRESS_WIDTH-1:0] bram_address_A,bram_address_B;
bram_control 
#(
    .MAC_NUM            (MAC_NUM            ),
    .BRAM_ADDRESS_WIDTH (BRAM_ADDRESS_WIDTH )
)
u_bram_control(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .weight_from_bram_A (bram_dout_a        ),
    .weight_from_bram_B (bram_dout_b        ),
    .weight_out         (weight_out         ),
    .bram_address_A     (bram_address_A     ),
    .bram_address_B     (bram_address_B     ),
    .bram_A_en          (bram_A_en          ),
    .bram_B_en          (bram_B_en          ),
    .address_reset      (address_reset      ),
    .read_en            (read_en            ),
    .read_length        (read_length        ),
    .data_valid         (data_valid         )
);

  design_1_wrapper u1
   (.BRAM_PORTA_0_addr(bram_address_A),
    .BRAM_PORTA_0_clk(clk),
   .BRAM_PORTA_0_din(1280'd0),
   .BRAM_PORTA_0_dout(bram_dout_a),
   .BRAM_PORTA_0_en(bram_A_en),
   .BRAM_PORTA_0_we(0),
   .BRAM_PORTB_0_addr(bram_address_B),
   .BRAM_PORTB_0_clk(clk),
   .BRAM_PORTB_0_din(1280'd0),
   .BRAM_PORTB_0_dout(bram_dout_b),
   .BRAM_PORTB_0_en(bram_B_en),
   .BRAM_PORTB_0_we(0));



endmodule