module bram_test (
    input [11:0]addr_a,
    input [11:0]addr_b,
    // input ena_a,
    // input ena_b,
    // input we_a,
    // input we_b,
    input clk_a,
    input clk_b,
    // input [1279:0]din_a,
    // input [1279:0]din_b,
    output [11:0]addr_a_o,
    output [11:0]addr_b_o,
    output ena_a_o,
    output ena_b_o,
    output we_a_o,
    output we_b_o,
    output clk_a_o,
    output clk_b_o,
    output [1279:0]din_a_o,
    output [1279:0]din_b_o
);
    assign clk_a_o=clk_a;
    assign clk_b_o=clk_b;
    assign ena_a_o=1;
    assign ena_b_o=1;
    assign we_a_o=0;
    assign we_b_o=0;
    assign din_a_o=0;
    assign din_b_o=0;
    assign addr_a_o=addr_a+1;
    assign addr_b_o=addr_b+1;

endmodule