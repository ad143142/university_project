`define INST_COMPUTE 32'd87 
`define INST_LOADIFMAPS 32'd88 

module data_path #(
    parameter MAC_NUM=256,
    parameter BRAM_ADDRESS_WIDTH=12,
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32,
    parameter AXIS_PRELOAD_FIFO_DEPTH = 4,
    parameter AXIS_FIFO_SIZE  = 16,

    parameter AXIS_PRELOAD_BIT_NUM=clogb2(AXIS_PRELOAD_FIFO_DEPTH-1),
    parameter AXIS_BIT_NUM  = clogb2(AXIS_FIFO_SIZE-1)
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data

    //AXI_S_in
    output wire S_AXIS_TREADY,
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA ,
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB ,
    input wire S_AXIS_TLAST ,
    input wire S_AXIS_TVALID,
    //AXI_S_out
    //TODO:還沒完成
    //temp_out
    output wire [5*MAC_NUM-1:0] psum_out,
    output wire psum_valid,

    //control in 
    input wire [MAC_NUM-1:0] MAC_enable,
    input wire [1:0] operation,
    input wire [11:0] input_channel_size,
    input wire [11:0] output_channel_size,
    input wire [4:0] kernel_size,

    input wire bram_write_en,
    input wire bram_transfer_start,
    input wire bram_control_add1,
    input wire bram_control_add2,
    input wire port_sel,

    input wire load_weight_preload,
    input wire load_weight,
    input wire load_ifmaps,
    
    //control out
    output wire ifmaps_fifo_empty,
    output wire weight_from_bram_valid,

    // output wire [C_S_AXIS_TDATA_WIDTH-1:0] axi_control_3,
    output wire write_weight_finish
    // input wire bram_transfer_start
);

    function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

    localparam LOAD_WEIGHT_IDLE=5'd0,RESET_ADDR=5'd1,K1_0=5'd2,K2_0=5'd3,K2_1=5'd4,K3_0=5'd5,K3_1=5'd6,K3_2=5'd7,
               K4_0=5'd8,K4_1=5'd9,K4_2=5'd10,K4_3=5'd11,K5_0=5'd12,K5_1=5'd13,K5_2=5'd14,K5_3=5'd15,K5_4=5'd16,
               K1_LOAD_WEIGHT=5'd17,K2_LOAD_WEIGHT=5'd18,K3_LOAD_WEIGHT=5'd19,K4_LOAD_WEIGHT=5'd20,K5_LOAD_WEIGHT=5'd21;

    reg  [4:0] load_weight_state;   

    wire load_weight_FSM_start,load_ifmaps_FSM_start;
    wire bram_read;
    wire read_length;


    //雙斜線module之間的控制訊號
    //雙斜線+星號為golbal control
    wire [C_S_AXIS_TDATA_WIDTH-1 : 0] ifmaps_from_axis;
    wire axi_fifo_empty,axi_fifo_full;
    wire axi_fifo_read;
    wire [5*MAC_NUM-1:0] ifmaps_from_fifo;
    wire [11:0] bram_address_A,bram_address_B;
    wire [5*MAC_NUM-1:0] weight_from_bram;
    wire read_weight,read_ifmaps;
    // wire [AXIS_BIT_NUM:0] axis_fifo_cnt;
    wire [AXIS_PRELOAD_BIT_NUM:0] axis_preload_fifo_cnt;
    wire axis_fifo_read;
    wire ifmaps_fifo_full;

    wire load_ifmaps_preload;
    assign load_ifmaps_preload=(~axi_fifo_empty) & (~ifmaps_fifo_full);
    // assign load_ifmaps_preload=(~axi_fifo_empty) & ((~ifmaps_fifo_full) | load_ifmaps);

    axis_fifo_my 
    #(
        .C_S_AXIS_TDATA_WIDTH (C_S_AXIS_TDATA_WIDTH ),
        .FIFO_SIZE            (AXIS_FIFO_SIZE        ),
        .bit_num              (AXIS_BIT_NUM          )
    )
    u_axis_fifo_my(
        //golbal
        .S_AXIS_ACLK    (clk                 ),
        .S_AXIS_ARESETN (rst_n               ),
        //data
        .S_AXIS_TDATA   (S_AXIS_TDATA        ),
        .data_out       (ifmaps_from_axis    ),
        //control in
        .S_AXIS_TREADY  (S_AXIS_TREADY       ),
        .S_AXIS_TSTRB   (S_AXIS_TSTRB        ),
        .S_AXIS_TLAST   (S_AXIS_TLAST        ),
        .S_AXIS_TVALID  (S_AXIS_TVALID       ),
        .read_want      (load_ifmaps_preload ),
        //control out 
        .out_valid      (out_valid           ),//
        .fifo_full      (axi_fifo_full       ),//
        .fifo_empty     (axi_fifo_empty      )//
    );

    wire axis_preload_fifo_read;
    assign axis_preload_fifo_read=load_ifmaps | axis_fifo_read ;//| write_weight_bram; //TODO:

    axis_preload_fifo 
    #(
        .C_S_AXIS_TDATA_WIDTH     (C_S_AXIS_TDATA_WIDTH     ),
        .MAC_NUM                  (MAC_NUM                  ),
        .AXIS_PRELOAD_FIFO_DEPTH  (AXIS_PRELOAD_FIFO_DEPTH  )
    )  
    u_axis_preload_fifo(  
        //golbal  
    	.clk                  (clk                      ),
        .rst_n                (rst_n                    ),
        //data          
        .ifmaps_from_axis     (ifmaps_from_axis         ),
        .ifmaps_out           (ifmaps_from_fifo         ),
        //control in          
        .fifo_read            (axis_preload_fifo_read   ),
        .load_ifmaps_preload  (load_ifmaps_preload      ),
        .input_channel_size   (input_channel_size       ),
  
        //control out      
        .fifo_cnt             (axis_preload_fifo_cnt    ),
        .fifo_empty           (ifmaps_fifo_empty        ),//
        .fifo_full            (ifmaps_fifo_full         )//
    );
    
    
    MAC_array_control 
    #(
        .MAC_NUM            (MAC_NUM              ),
        .BRAM_ADDRESS_WIDTH (BRAM_ADDRESS_WIDTH   )
    )
    u_MAC_array_control(
        //golbal
    	.clk                 (clk                 ),
        .rst_n               (rst_n               ),
        //data
        .ifmaps_from_fifo    (ifmaps_from_fifo    ),
        .weight_from_bram    (weight_from_bram    ),
        .psum_out            (psum_out            ),
        //control in
        .enable              (MAC_enable          ),
        .operation           (operation           ),
        .kernel_size         (kernel_size         ),
        .load_weight_preload (load_weight_preload ),
        .load_MAC_weight     (load_weight         ),
        .load_ifmaps         (load_ifmaps         ),//TODO:
        .ifmaps_fifo_empty   (ifmaps_fifo_empty   ),
        //control out
        .psum_valid          (psum_valid          )
        // .axi_control_3       (axi_control_3       )
    );
    
    
    wire [1279:0] weight_from_bram_A,weight_from_bram_B,weight_to_bram_A,weight_to_bram_B;
    wire bram_A_en,bram_B_en;

    //FIXME:注意這裡已經換成test版的了
    bram_control_test 
    #(
        .MAC_NUM                (MAC_NUM                ),
        .BRAM_ADDRESS_WIDTH     (BRAM_ADDRESS_WIDTH     ),
        .AXIS_PRELOAD_FIFO_DEPTH(AXIS_PRELOAD_FIFO_DEPTH)
    )
    u_bram_control_test(
        //golbal
    	.clk                    (clk                    ),
        .rst_n                  (rst_n                  ),

        //data
        .weight_from_preload    (ifmaps_from_fifo       ),
        .weight_from_bram_A     (weight_from_bram_A     ),
        .weight_from_bram_B     (weight_from_bram_B     ),
        .weight_out             (weight_from_bram       ),
        .weight_to_bram_A       (weight_to_bram_A       ),
        .weight_to_bram_B       (weight_to_bram_B       ),
        .bram_address_A         (bram_address_A         ),
        .bram_address_B         (bram_address_B         ),
        .bram_A_en              (bram_A_en              ),
        .bram_B_en              (bram_B_en              ),
        .bram_A_wen             (bram_A_wen             ),
        .bram_B_wen             (bram_B_wen             ),

        //control
        .output_channel_size    (output_channel_size    ),
        .kernel_size            (kernel_size            ),
        .write_en               (bram_write_en          ),
        .axis_fifo_cnt          (axis_preload_fifo_cnt  ),
        .transfer_start         (bram_transfer_start    ),
        .bram_control_add1      (bram_control_add1      ),
        .bram_control_add2      (bram_control_add2      ),
        .port_sel               (port_sel               ),
        .weight_from_bram_valid (weight_from_bram_valid ),
        .axis_fifo_read         (axis_fifo_read         ),
        .write_weight_finish    (write_weight_finish    )
    );
    
    // bram_control 
    // #(
    //     .MAC_NUM            (MAC_NUM            ),
    //     .BRAM_ADDRESS_WIDTH (BRAM_ADDRESS_WIDTH )
    // )
    // u_bram_control(
    //     //golbal
    // 	.clk                       (clk                   ),
    //     .rst_n                     (rst_n                 ),
    //     //data
    //     .weight_out                (weight_from_bram      ),
    //     //BRAM control
    //     .weight_from_bram_A        (weight_from_bram_A    ),
    //     .weight_from_bram_B        (weight_from_bram_B    ),
    //     .bram_address_A            (bram_address_A        ),
    //     .bram_address_B            (bram_address_B        ),
    //     .bram_A_en                 (bram_A_en             ),
    //     .bram_B_en                 (bram_B_en             ),
    //     //control in
    //     .transfer_start            (bram_transfer_start   ),//i
    //     .bram_control_add1         (bram_control_add1     ),//i
    //     .bram_control_add2         (bram_control_add2     ),//i
    //     .port_sel                  (port_sel              ),//i
    //     //contrl out
    //     .weight_from_bram_valid    (weight_from_bram_valid) //o
    // );
    
    //BRAM_instance
    design_1_wrapper u_BRAM(
        //control
        .BRAM_PORTA_0_clk        (clk                ),
        .BRAM_PORTB_0_clk        (clk                ),
        //data
        .BRAM_PORTA_0_dout       (weight_from_bram_A ),
        .BRAM_PORTB_0_dout       (weight_from_bram_B ),
        .BRAM_PORTA_0_din        (weight_to_bram_A   ),
        .BRAM_PORTB_0_din        (weight_to_bram_B   ),
        //BRAM control
        .BRAM_PORTA_0_addr       (bram_address_A     ),
        .BRAM_PORTB_0_addr       (bram_address_B     ),
        .BRAM_PORTA_0_en         (bram_A_en          ),
        .BRAM_PORTB_0_en         (bram_B_en          ),
        .BRAM_PORTA_0_we         (bram_A_wen         ),
        .BRAM_PORTB_0_we         (bram_B_wen         )
    );
    
endmodule