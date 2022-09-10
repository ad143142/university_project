module top #(
    parameter MAC_NUM=256,
    parameter BRAM_ADDRESS_WIDTH=12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
) 
(
    //golbal
    input wire clk,
    input wire rst_n,
    //data path
    output wire  S_AXIS_TREADY,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
    input wire  S_AXIS_TLAST,
    input wire  S_AXIS_TVALID,

    output wire [1279:0]psum_out,
    output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] axi_control_3,

    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] axi_control_0,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] axi_control_1,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] axi_control_2

);
    wire weight_from_bram_valid;
    wire operation;
    wire [4:0] kernel_size;
    wire load_weight_preload;
    wire load_weight;
    wire bram_port_sel;
    wire bram_control_add1;
    wire bram_control_add2;
    wire address_reset;
    wire ifmaps_fifo_empty;
    wire load_ifmaps;

    control_unit 
    #(
        .MAC_NUM                    (MAC_NUM                    ),
        .BRAM_ADDRESS_WIDTH         (BRAM_ADDRESS_WIDTH         ),
        .C_S_AXIS_TDATA_WIDTH       (C_S_AXIS_TDATA_WIDTH       )
    )
    u_control_unit(
        //golbal
    	.clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        //control in        
        .axi_control_0              (axi_control_0              ),
        .axi_control_1              (axi_control_1              ),
        .axi_control_2              (axi_control_2              ),
        .weight_from_bram_valid     (weight_from_bram_valid     ),
        .ifmaps_fifo_empty          (ifmaps_fifo_empty          ),
        //control out          
        .operation                  (operation                  ),
        .kernel_size                (kernel_size                ),
        .load_weight_preload        (load_weight_preload        ),
        .load_weight                (load_weight                ),
        .bram_port_sel              (bram_port_sel              ),
        .bram_control_add1          (bram_control_add1          ),
        .bram_control_add2          (bram_control_add2          ),
        .address_reset              (address_reset              ),
        .load_ifmaps                (load_ifmaps                ),
        .axi_control_3              (axi_control_3              )
    );
    
    data_path 
    #(
        .MAC_NUM                    (MAC_NUM                    ),
        .BRAM_ADDRESS_WIDTH         (BRAM_ADDRESS_WIDTH         ),
        .C_S_AXIS_TDATA_WIDTH       (C_S_AXIS_TDATA_WIDTH       )
    )
    u_data_path(
        //golbal
    	.clk                        (clk                        ),
        .rst_n                      (rst_n                      ),
        //data path              
        .S_AXIS_TREADY              (S_AXIS_TREADY              ),
        .S_AXIS_TDATA               (S_AXIS_TDATA               ),
        .S_AXIS_TSTRB               (S_AXIS_TSTRB               ),
        .S_AXIS_TLAST               (S_AXIS_TLAST               ),
        .S_AXIS_TVALID              (S_AXIS_TVALID              ),
        .psum_out                   (psum_out                   ),
        //contol in              
        .psum_valid                 (psum_valid                 ),
        .operation                  (operation                  ),
        .kernel_size                (kernel_size                ),
        .address_reset              (address_reset              ),
        .bram_control_add1          (bram_control_add1          ),
        .bram_control_add2          (bram_control_add2          ),
        .port_sel                   (port_sel                   ),
        .load_weight_preload        (load_weight_preload        ),
        .load_weight                (load_weight                ),
        .load_ifmaps                (load_ifmaps                ),
        //control out
        .ifmaps_fifo_empty          (ifmaps_fifo_empty          ),
        .weight_from_bram_valid     (weight_from_bram_valid     ),
        .axi_control_3              (axi_control_3              )
    );
    


endmodule