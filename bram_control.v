module bram_control #(
    parameter integer MAC_NUM = 256,
    parameter integer BRAM_ADDRESS_WIDTH = 12
)
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
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
    localparam IDLE=2'd0,S0=2'd1,S1=2'd2,S2=2'd3;
    localparam A=1'd0,B=1'd1;
    
    reg [1:0] read_state;
    reg out_state;

    assign bram_A_en=1;
    assign bram_B_en=1;

    assign data_valid=(read_state==S2);
    assign weight_out = (out_state==A) ? weight_from_bram_A:weight_from_bram_B;

    assign bram_address_B = bram_address_A+1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bram_address_A<=0;
        end
        else begin
            if(read_en & read_state==IDLE) begin
                bram_address_A<=address_reset ? 0:(read_len ? bram_address_A+2:bram_address_A+1);
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            read_state<=IDLE;
        end
        else begin
            case (read_state)
                IDLE:read_state<=(read_en || address_reset) ? S0:IDLE;
                S0:read_state<=S1;
                S1:read_state<=S2;
                S2:read_state<=IDLE;
                default:read_state<=IDLE;         
            endcase
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_state<=A;
        end
        else begin
            case(out_state)
                A:out_state<=data_valid ? (read_len ? B:A):A;
                B:out_state<=A;
            endcase
        end
    end

endmodule