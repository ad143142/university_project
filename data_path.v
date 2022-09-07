module data_path #(
    parameter MAC_NUM=256,
    parameter BRAM_ADDRESS_WIDTH=12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data

    //AXI_S_in
    input wire S_AXIS_TREADY,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA ,
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB ,
    input wire S_AXIS_TLAST ,
    input wire S_AXIS_TVALID,
    //AXI_S_out
    //TODO:還沒完成
    //temp_out
    output wire [5*MAC_NUM-1:0] psum_out,
    output wire psum_valid,
    //control

    input wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_0,
    input wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_1,
    input wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_2,
    input wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_3,
    input wire address_reset
);

    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] ifmaps_from_axis;
    wire axi_fifo_empty,axi_fifo_full;
    wire axi_fifo_read;

    axis_fifo_my 
    #(
        .C_S_AXIS_TDATA_WIDTH (C_S_AXIS_TDATA_WIDTH )
    )
    u_axis_fifo_my(
        .data_out       (ifmaps_from_axis),
        .read_want      (axi_fifo_read   ),//*
        .out_valid      (out_valid       ),
        .fifo_full      (axi_fifo_full   ),
        .fifo_empty     (axi_fifo_empty  ),
        .S_AXIS_ACLK    (clk             ),
        .S_AXIS_ARESETN (rst_n           ),
        .S_AXIS_TREADY  (S_AXIS_TREADY   ),
        .S_AXIS_TDATA   (S_AXIS_TDATA    ),
        .S_AXIS_TSTRB   (S_AXIS_TSTRB    ),
        .S_AXIS_TLAST   (S_AXIS_TLAST    ),
        .S_AXIS_TVALID  (S_AXIS_TVALID   )
    );


    wire [5*MAC_NUM-1:0] ifmaps_from_fifo;
    wire ifmaps_fifo_empty;

    axis_ifmaps_preload 
    #(
        .C_S_AXIS_TDATA_WIDTH (C_S_AXIS_TDATA_WIDTH ),
        .MAC_NUM              (MAC_NUM              )
    )
    u_axis_ifmaps_preload(
    	.clk              (clk              ),
        .rst_n            (rst_n            ),
        .ifmaps_from_axis (ifmaps_from_axis ),
        .ifmaps_out       (ifmaps_from_fifo ),
        .axi_fifo_empty   (axi_fifo_empty   ),
        .axi_fifo_read    (axi_fifo_read    ),//*
        .MAC_read         (read_ifmaps      ),
        .fifo_empty       (ifmaps_fifo_empty),
        .fifo_full        (fifo_full        )
    );
    
    wire bram_address_A,bram_address_B;
    wire [5*MAC_NUM-1:0] weight_from_bram;
    wire read_weight,read_ifmaps;
    MAC_array_control 
    #(
        .MAC_NUM            (MAC_NUM            ),
        .BRAM_ADDRESS_WIDTH (BRAM_ADDRESS_WIDTH )
    )
    u_MAC_array_control(
    	.clk               (clk               ),
        .rst_n             (rst_n             ),
        .ifmaps_from_fifo  (ifmaps_from_fifo  ),
        .weight_from_bram  (weight_from_bram  ),
        .psum_out          (psum_out          ),
        .ifmaps_fifo_empty (ifmaps_fifo_empty ),
        .data_valid        (psum_valid        ),
        .read_weight       (read_weight       ),
        .read_ifmaps       (read_ifmaps       ),
        .axi_control_0     (axi_control_0     ),//
        .axi_control_1     (axi_control_1     ),//
        .axi_control_2     (axi_control_2     ),//
        .axi_control_3     (axi_control_3     ) //
    );
    
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
        .weight_out         (weight_from_bram   ),
        .bram_address_A     (bram_address_A     ),
        .bram_address_B     (bram_address_B     ),
        .bram_A_en          (bram_A_en          ),
        .bram_B_en          (bram_B_en          ),
        .address_reset      (address_reset      ),
        .read_en            (read_weight        ),
        .read_length        (read_length        ),
        .data_valid         (data_valid         )
    );
    
    //BRAM_instance
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