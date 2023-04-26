module top #(
    parameter MAC_NUM=256,
    parameter BRAM_ADDRESS_WIDTH=12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32,
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
    parameter integer C_S_AXI_ADDR_WIDTH	= 4,
    parameter C_M_AXIS_TDATA_WIDTH = 32,
    parameter M_AXIS_FIFO_DEPTH = 4
    
) 
(
    //golbal
    input wire clk,
    input wire rst_n,
    //data path
    //S_AXIS
    output wire  S_AXIS_TREADY,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
    input wire  S_AXIS_TLAST,
    input wire  S_AXIS_TVALID,

    //S_AXI
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire  S_AXI_AWVALID,
    output wire  S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire  S_AXI_WVALID,
    output wire  S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire  S_AXI_BVALID,
    input wire  S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire  S_AXI_ARVALID,
    output wire  S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire  S_AXI_RVALID,
    input wire  S_AXI_RREADY,

    //M_AXIS
    input wire  								 M_AXIS_TREADY,

    output wire	[C_M_AXIS_TDATA_WIDTH-1:0]       M_AXIS_TDATA,
    output wire                                  M_AXIS_TVALID,
    output wire 						         M_AXIS_TLAST,
    output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB  
);
    //TODO:full-connect、if input channel bigger than 256(MAC_NUM)control unit要增加紀錄現在到哪個channel的reg、load weight

    wire [MAC_NUM-1:0] MAC_enable;
    wire weight_from_bram_valid;
    wire [1:0] operation;
    wire [4:0] kernel_size;
    wire [2:0] stride;
    wire [11:0]input_channel_size;
    wire [11:0]output_channel_size;
    wire axis_en;
    wire axis_clear;
    wire load_weight_preload;
    wire load_weight;
    wire bram_port_sel;
    wire bram_control_add1;
    wire bram_control_add2;
    wire address_reset;
    wire ifmaps_fifo_empty;
    wire load_ifmaps;
    wire layer_finish;
    wire bram_write_en;
    wire write_weight_finish;
    wire pooling_compute;
    wire pooling_finish;
    
    wire [31:0]reg0_read_data;
    wire [31:0]reg1_read_data;
    wire [31:0]reg2_read_data;
    wire [31:0]reg3_write_data;

    wire M_AXIS_o_valid;
    wire [C_M_AXIS_TDATA_WIDTH-1:0] M_AXIS_o_data;
    wire M_AXIS_o_last;

    /*reg [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA_buf;
    reg [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB_buf;
    reg  S_AXIS_TLAST_buf;
    reg  S_AXIS_TVALID_buf;
    reg  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR_buf;
    reg  [2 : 0] S_AXI_AWPROT_buf;
    reg   S_AXI_AWVALID_buf;
    reg  [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA_buf;
    reg  [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB_buf;
    reg   S_AXI_WVALID_buf;
    reg   S_AXI_BREADY_buf;
    reg  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR_buf;
    reg  [2 : 0] S_AXI_ARPROT_buf;
    reg   S_AXI_ARVALID_buf;
    reg   S_AXI_RREADY_buf;
    reg  M_AXIS_TREADY_buf;*/

    // wire [31:0]axi_control_3_from_datapath;

    wire M_AXIS_output_finsih;
    assign M_AXIS_output_finsih = (M_AXIS_TVALID && M_AXIS_TLAST);
    AXI_interface 
    #(
        .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH ),
        .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH )
    )
    u_AXI_interface(
        //golbal
        .S_AXI_ACLK           (clk                               ),
        .S_AXI_ARESETN        (rst_n                             ),
        //data     
    	.reg0_read_data       (reg0_read_data                    ),
        .reg1_read_data       (reg1_read_data                    ),
        .reg2_read_data       (reg2_read_data                    ),
        .reg3_write_data      (reg3_write_data                   ),
        //control     
        .layer_finish         (M_AXIS_output_finsih              ),
        .write_weight_finish  (write_weight_finish               ),

        .S_AXI_AWADDR         (S_AXI_AWADDR                  ),
        .S_AXI_AWPROT         (S_AXI_AWPROT                  ),
        .S_AXI_AWVALID        (S_AXI_AWVALID                 ),
        .S_AXI_AWREADY        (S_AXI_AWREADY                     ),
        .S_AXI_WDATA          (S_AXI_WDATA                  ),
        .S_AXI_WSTRB          (S_AXI_WSTRB                  ),
        .S_AXI_WVALID         (S_AXI_WVALID                 ),
        .S_AXI_WREADY         (S_AXI_WREADY                      ),
        .S_AXI_BRESP          (S_AXI_BRESP                       ),
        .S_AXI_BVALID         (S_AXI_BVALID                      ),
        .S_AXI_BREADY         (S_AXI_BREADY                  ),
        .S_AXI_ARADDR         (S_AXI_ARADDR                  ),
        .S_AXI_ARPROT         (S_AXI_ARPROT                  ),
        .S_AXI_ARVALID        (S_AXI_ARVALID                 ),
        .S_AXI_ARREADY        (S_AXI_ARREADY                     ),
        .S_AXI_RDATA          (S_AXI_RDATA                       ),
        .S_AXI_RRESP          (S_AXI_RRESP                       ),
        .S_AXI_RVALID         (S_AXI_RVALID                      ),
        .S_AXI_RREADY         (S_AXI_RREADY                  )
    );
    

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
        .axi_control_0              (reg0_read_data             ),
        .axi_control_1              (reg1_read_data             ),
        .axi_control_2              (reg2_read_data             ),
        .weight_from_bram_valid     (weight_from_bram_valid     ),
        .ifmaps_fifo_empty          (ifmaps_fifo_empty          ),
        .pooling_finish             (pooling_finish             ),
        .M_AXIS_output_finsih       (M_AXIS_output_finsih       ),
        // .axi_control_3_in           (axi_control_3_from_datapath),
        //control out          
        .layer_finish               (layer_finish               ),
        .write_weight_finish        (write_weight_finish        ),

        .MAC_enable                 (MAC_enable                 ),
        .operation                  (operation                  ),
        .input_channel_size         (input_channel_size         ),
        .output_channel_size        (output_channel_size        ),
        .axis_en                    (axis_en                    ),
        .axis_clear                 (axis_clear                 ),
        .kernel_size                (kernel_size                ),
        .stride                     (stride                     ),
        .load_weight_preload        (load_weight_preload        ),
        .load_weight                (load_weight                ),
        .pooling_compute            (pooling_compute            ),
        .bram_write_en              (bram_write_en              ),
        .bram_port_sel              (bram_port_sel              ),
        .bram_control_add1          (bram_control_add1          ),
        .bram_control_add2          (bram_control_add2          ),
        .bram_transfer_start        (bram_transfer_start        ),
        .load_ifmaps                (load_ifmaps                ),
        .axi_control_3              (reg3_write_data            )
    );
    
    data_path 
    #(
        .MAC_NUM                    (MAC_NUM                    ),
        .BRAM_ADDRESS_WIDTH         (BRAM_ADDRESS_WIDTH         ),
        .C_S_AXIS_TDATA_WIDTH       (C_S_AXIS_TDATA_WIDTH       )
    )
    u_data_path(
        //golbal
    	.clk                           (clk                            ),
        .rst_n                         (rst_n                          ),
        //data path in            
        .S_AXIS_TREADY                 (S_AXIS_TREADY                  ),
        .S_AXIS_TDATA                  (S_AXIS_TDATA               ),
        .S_AXIS_TSTRB                  (S_AXIS_TSTRB               ),
        .S_AXIS_TLAST                  (S_AXIS_TLAST               ),
        .S_AXIS_TVALID                 (S_AXIS_TVALID              ),
        //data path out
        .M_AXIS_o_data                 (M_AXIS_o_data                  ),
        .M_AXIS_o_valid                (M_AXIS_o_valid                 ),
        .M_AXIS_o_last                 (M_AXIS_o_last                  ),
        //contol in       
            //golbal control       
        .input_channel_size            (input_channel_size             ),
        .output_channel_size           (output_channel_size            ),
        .operation                     (operation                      ),
        .kernel_size                   (kernel_size                    ),
        .stride                        (stride                         ),
        .axis_en                       (axis_en                        ),
        .axis_clear                    (axis_clear                     ),
        .layer_finish                  (layer_finish                   ),
        .pooling_compute               (pooling_compute                ),
            //MAC_control
        .MAC_enable                    (MAC_enable                     ),
        .load_weight                   (load_weight                    ),
        .load_ifmaps                   (load_ifmaps                    ),
            //BRAM_control
        .bram_write_en                 (bram_write_en                  ),
        .bram_transfer_start           (bram_transfer_start           ),
        .bram_control_add1             (bram_control_add1              ),
        .bram_control_add2             (bram_control_add2              ),
        .port_sel                      (bram_port_sel                  ),
            //weight_preload
        .load_weight_preload           (load_weight_preload            ),
        //control out
        .ifmaps_fifo_empty             (ifmaps_fifo_empty              ),
        .weight_from_bram_valid        (weight_from_bram_valid         ),
        .pooling_finish                (pooling_finish                 ),
        // .axi_control_3              (axi_control_3_from_datapath),
        .write_weight_finish           (write_weight_finish            )
    );


    axis_master #(
        .FIFO_DEPTH           ( M_AXIS_FIFO_DEPTH           ),
        .C_M_AXIS_TDATA_WIDTH ( C_M_AXIS_TDATA_WIDTH ))
    u_axis_master (
        .M_AXIS_ACLK             ( clk                                              ),
        .M_AXIS_ARESETN          ( rst_n                                            ),
        .TDATA_in                ( M_AXIS_o_data                                    ),
        .TVALID_in               ( M_AXIS_o_valid                                   ),
        .TLAST_in                ( M_AXIS_o_last                                    ),
        .M_AXIS_TREADY           ( M_AXIS_TREADY                                    ),

        .M_AXIS_TDATA            ( M_AXIS_TDATA    [C_M_AXIS_TDATA_WIDTH-1:0]       ),
        .M_AXIS_TVALID           ( M_AXIS_TVALID                                    ),
        .M_AXIS_TLAST            ( M_AXIS_TLAST                                     ),
        .M_AXIS_TSTRB            ( M_AXIS_TSTRB    [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] )
    );

    ///////////////////////////////////////////////////////////////////////////////////////
    /*always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            S_AXIS_TDATA_buf  <= 32'd0 ;
            S_AXIS_TSTRB_buf  <= 4'd0 ;
            S_AXIS_TLAST_buf  <= 1'd0 ;
            S_AXIS_TVALID_buf <= 1'd0 ;
            S_AXI_AWADDR_buf  <= 4'd0 ;
            S_AXI_AWPROT_buf  <= 3'd0 ;
            S_AXI_AWVALID_buf <= 1'd0 ;
            S_AXI_WDATA_buf   <= 32'd0 ;
            S_AXI_WSTRB_buf   <= 4'd0 ;
            S_AXI_WVALID_buf  <= 1'd0 ;
            S_AXI_BREADY_buf  <= 1'd0 ;
            S_AXI_ARADDR_buf  <= 4'd0 ;
            S_AXI_ARPROT_buf  <= 3'd0 ;
            S_AXI_ARVALID_buf <= 1'd0 ;
            S_AXI_RREADY_buf  <= 1'd0 ;
            M_AXIS_TREADY_buf <= 1'd0;
        end            
        else begin
            S_AXIS_TDATA_buf  <= S_AXIS_TDATA  ;
            S_AXIS_TSTRB_buf  <= S_AXIS_TSTRB  ;
            S_AXIS_TLAST_buf  <= S_AXIS_TLAST  ;
            S_AXIS_TVALID_buf <= S_AXIS_TVALID ;
            S_AXI_AWADDR_buf  <= S_AXI_AWADDR  ;
            S_AXI_AWPROT_buf  <= S_AXI_AWPROT  ;
            S_AXI_AWVALID_buf <= S_AXI_AWVALID ;
            S_AXI_WDATA_buf   <= S_AXI_WDATA   ;
            S_AXI_WSTRB_buf   <= S_AXI_WSTRB   ;
            S_AXI_WVALID_buf  <= S_AXI_WVALID  ;
            S_AXI_BREADY_buf  <= S_AXI_BREADY  ;
            S_AXI_ARADDR_buf  <= S_AXI_ARADDR  ;
            S_AXI_ARPROT_buf  <= S_AXI_ARPROT  ;
            S_AXI_ARVALID_buf <= S_AXI_ARVALID ;
            S_AXI_RREADY_buf  <= S_AXI_RREADY  ;
            M_AXIS_TREADY_buf <= M_AXIS_TREADY ;

        end
    end*/
   

endmodule