module MAC_array #(
    parameter integer MAC_NUM = 256
) 
(
    //global
    input wire clk,
    input wire rst_n,

    //data
    input wire [25*MAC_NUM-1:0] weight_from_preload,
    input wire [5*MAC_NUM-1:0] ifmaps_from_fifo,

    output wire [5*MAC_NUM-1:0] psum_out,

    //control
    input wire operation,
    input wire [4:0] kernel_size,

    input wire ifmaps_input_valid,

    input wire load_ifmaps,
    input wire load_weight
);
//2022/09/1已測試

    //產生MAC_NUM(板子上的LUT應該只能放256個MAC，其LUT用量已經45%不包括其他外設及control_unit)
    genvar idx;
    generate
        for(idx=0;idx<MAC_NUM;idx=idx+1)
        begin
            MAC 
            #(
                .DATA_WIDTH (1)
            )
            u_MAC(
            	.clk                 (clk                                     ),
                .rst_n               (rst_n                                   ),
                .ifmaps_fifo_row0_in (ifmaps_from_fifo[(idx*5)+0]             ),
                .ifmaps_fifo_row1_in (ifmaps_from_fifo[(idx*5)+1]             ),
                .ifmaps_fifo_row2_in (ifmaps_from_fifo[(idx*5)+2]             ),
                .ifmaps_fifo_row3_in (ifmaps_from_fifo[(idx*5)+3]             ),
                .ifmaps_fifo_row4_in (ifmaps_from_fifo[(idx*5)+4]             ),
                .ifmaps_input_valid  (ifmaps_input_valid                      ),
                .weight_in           (weight_from_preload[(idx*25+24) -: 25]  ),
                .MAC_out             (psum_out[(idx*5+4) -: 5]                ),
                .load_ifmaps         (load_ifmaps                             ),
                .load_weight         (load_weight                             ),
                .operation           (operation                               ),
                .kernel_size         (kernel_size                             )
            );
            
        end
    endgenerate

    
endmodule