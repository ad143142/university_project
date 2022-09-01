module bram_control #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    //TODO:從AXI寫BRAM的部分還沒有實作
        // input wire [31:0] axi_in,

    input wire [5*MAC_NUM-1:0] weight_from_bram_A,
    input wire [5*MAC_NUM-1:0] weight_from_bram_B,

    output wire [5*MAC_NUM-1:0] weight_out,

        // output wire [5*MAC_NUM-1:0] weight_to_bram_A,
        // output wire [5*MAC_NUM-1:0] weight_to_bram_B,
    
    output reg [BRAM_ADDRESS_WIDTH-1:0] bram_address_A,
    output wire [BRAM_ADDRESS_WIDTH-1:0] bram_address_B,

    output wire bram_A_en,
    output wire bram_B_en,

    //control
    input wire address_reset,
    input wire read_en,
    input wire read_len,
    output wire data_valid

);

    localparam S0=2'd0,S1=2'd1,VALID_A=2'd2,VALID_B=2'd3;
    
    reg [1:0] state;

    assign bram_A_en=1;
    assign bram_B_en=1;

    assign data_valid=(state==VALID_A || state==VALID_B);
    assign weight_out = (state==VALID_B) ? weight_from_bram_B:weight_from_bram_A;

    assign bram_address_B = bram_address_A+1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bram_address_A<=0;
        end
        else begin
            if(address_reset) begin
                bram_address_A<=0;
            end
            else if(state==VALID_A && ~read_len && read_en) begin
                bram_address_A<=bram_address_A+1;
            end
            else if(state==VALID_B && read_en) begin
                bram_address_A<=bram_address_A+2;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state<=S0;
        end
        else begin
            case (state)
                S0:state<=S1;
                S1:state<=VALID_A;
                VALID_A:state<=read_en ? (read_len ? VALID_B:S0):VALID_A;
                VALID_B:state<=read_en ? S0:VALID_B;
                default:state<=S0;         
            endcase
        end
    end


endmodule