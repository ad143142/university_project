(* use_dsp = "yes" *)
module psum_adder #(
    parameter PSUM_IN_WIDTH = 6*256,
    parameter OFMAPS_BRAM_ADDR_WIDTH = 12
)
(
    //golbal
    input wire clk,
    input wire rst_n,
    //control
    //input [11:0] in_channel,
    //input [4:0] kernel_size,
    input wire layer_finish,

    //input data
    input [PSUM_IN_WIDTH-1:0] psum_in,
    input [OFMAPS_BRAM_ADDR_WIDTH-1:0] address_in,
    input i_valid,

    input [15:0] bias_in,
    input bias_valid,
    //output data
    output o_last,
    output o_data,
    output [OFMAPS_BRAM_ADDR_WIDTH-1:0 ] address_out,
    output o_valid

);
//////////////////////reg//////////////////////////
    reg signed [5 : 0] r_pipe0_data [0 : 256-1];
    reg signed [6 : 0] r_pipe1_data [0 : 128-1];
    reg signed [7 : 0] r_pipe2_data [0 : 64 -1];
    reg signed [8 : 0] r_pipe3_data [0 : 32 -1];
    reg signed [9 : 0] r_pipe4_data [0 : 16 -1];
    reg signed [10: 0] r_pipe5_data [0 : 8  -1];
    reg signed [11: 0] r_pipe6_data [0 : 4  -1];
    reg signed [12: 0] r_pipe7_data [0 : 2  -1];
    reg signed [13: 0] r_pipe8_data ;
    //cmp
    reg r_pipe9_data;

    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe0_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe1_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe2_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe3_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe4_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe5_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe6_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe7_addr ;
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe8_addr ;
    //cmp
    reg [OFMAPS_BRAM_ADDR_WIDTH -1:0] r_pipe9_addr ;

    reg r_pipe0_valid;
    reg r_pipe1_valid;
    reg r_pipe2_valid;
    reg r_pipe3_valid;
    reg r_pipe4_valid;
    reg r_pipe5_valid;
    reg r_pipe6_valid;
    reg r_pipe7_valid;
    reg r_pipe8_valid;
    //cmp
    reg r_pipe9_valid;

    reg r_pipe0_last;
    reg r_pipe1_last;
    reg r_pipe2_last;
    reg r_pipe3_last;
    reg r_pipe4_last;
    reg r_pipe5_last;
    reg r_pipe6_last;
    reg r_pipe7_last;
    reg r_pipe8_last;
    reg r_pipe9_last;
    reg r_pipe10_last;
    reg r_pipe11_last;

    reg signed [15:0] bias_fifo [0:7];
    reg [2:0] write_ptr;
    reg [2:0] read_ptr;
    reg signed [15:0] bias_out;

//////////////////////wire//////////////////////////


    /*wire [12:0] threshold_0;
    wire [12:0] threshold;*/

    /*reg [2:0] kernel_num;
    always @(*) begin
        case(kernel_size)
            5'b10000 : kernel_num = 3'd5;
            5'b01000 : kernel_num = 3'd4;
            5'b00100 : kernel_num = 3'd3;
            5'b00010 : kernel_num = 3'd2;
            5'b00001 : kernel_num = 3'd1;

            default  : kernel_num = 3'd1;
        endcase
    end*/

    /*assign threshold_0 = kernel_num * kernel_num * in_channel;
    assign threshold = {1'd0,threshold_0[12:1]}; */

    assign o_data = r_pipe9_data;
    assign address_out = r_pipe9_addr;
    assign o_valid = r_pipe9_valid;
    assign o_last = r_pipe11_last;

//////////////////////bias_fifo//////////////////////////

    integer x ;
    always @(posedge clk or negedge rst_n) begin
        for(x=0;x<8;x=x+1) begin
            if(!rst_n) begin
                bias_fifo[x] <= 16'd0;
            end
            else begin
                bias_fifo[write_ptr] <= bias_valid ? bias_in : bias_fifo[write_ptr];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            write_ptr <= 3'd0;
        end
        else begin
            write_ptr <= bias_valid ? write_ptr+3'd1 : write_ptr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            read_ptr <= 3'd0;
        end
        else begin
            read_ptr <= r_pipe9_valid ? read_ptr+3'd1 : read_ptr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bias_out <= 16'd0;
        end
        else begin
            bias_out <= -bias_fifo[read_ptr];//psum+bias>=0 simplify psum>=-bias
        end
    end
//////////////////////data_pipeline//////////////////////////
    integer i_0 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_0=0;i_0<256;i_0=i_0+1) begin
            if(!rst_n) begin
                r_pipe0_data[i_0] <= 6'd0;
            end
            else begin
                r_pipe0_data[i_0] <= i_valid ? psum_in[i_0*6 +: 6] : r_pipe0_data[i_0];
            end
        end
    end

    integer i_1 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_1=0;i_1<128;i_1=i_1+1) begin
            if(!rst_n) begin
                r_pipe1_data[i_1] <= 7'd0;
            end
            else begin
                r_pipe1_data[i_1] <= r_pipe0_data[i_1 * 2] + r_pipe0_data[i_1 * 2 + 1];
            end
        end
    end

    integer i_2 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_2=0;i_2<64;i_2=i_2+1) begin
            if(!rst_n) begin
                r_pipe2_data[i_2] <= 8'd0;
            end
            else begin
                r_pipe2_data[i_2] <= r_pipe1_data[i_2 * 2] + r_pipe1_data[i_2 * 2 + 1];
            end
        end
    end

    integer i_3 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_3=0;i_3<32;i_3=i_3+1) begin
            if(!rst_n) begin
                r_pipe3_data[i_3] <= 9'd0;
            end
            else begin
                r_pipe3_data[i_3] <= r_pipe2_data[i_3 * 2] + r_pipe2_data[i_3 * 2 + 1];
            end
        end
    end

    integer i_4 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_4=0;i_4<16;i_4=i_4+1) begin
            if(!rst_n) begin
                r_pipe4_data[i_4] <= 10'd0;
            end
            else begin
                r_pipe4_data[i_4] <= r_pipe3_data[i_4 * 2] + r_pipe3_data[i_4 * 2 + 1];
            end
        end
    end

    integer i_5 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_5=0;i_5<8;i_5=i_5+1) begin
            if(!rst_n) begin
                r_pipe5_data[i_5] <= 11'd0;
            end
            else begin
                r_pipe5_data[i_5] <= r_pipe4_data[i_5 * 2] + r_pipe4_data[i_5 * 2 + 1];
            end
        end
    end

    integer i_6 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_6=0;i_6<4;i_6=i_6+1) begin
            if(!rst_n) begin
                r_pipe6_data[i_6] <= 12'd0;
            end
            else begin
                r_pipe6_data[i_6] <= r_pipe5_data[i_6 * 2] + r_pipe5_data[i_6 * 2 + 1];
            end
        end
    end

    integer i_7 ;
    always @(posedge clk or negedge rst_n) begin
        for(i_7=0;i_7<2;i_7=i_7+1) begin
            if(!rst_n) begin
                r_pipe7_data[i_7] <= 13'd0;
            end
            else begin
                r_pipe7_data[i_7] <= r_pipe6_data[i_7 * 2] + r_pipe6_data[i_7 * 2 + 1];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe8_data <= 13'd0;
        end
        else begin
            r_pipe8_data <= r_pipe7_data[0] + r_pipe7_data[1];
        end
    end

    //FIXME:大於等於還是大於要確定
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe9_data <= 1'd0;
        end
        else begin
            r_pipe9_data <= (r_pipe8_data >= bias_out);
        end
    end

//////////////////////addr_pipeline//////////////////////////

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe0_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe0_addr <= i_valid ? address_in : r_pipe0_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe1_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe1_addr <= r_pipe0_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe2_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe2_addr <= r_pipe1_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe3_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe3_addr <= r_pipe2_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe4_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe4_addr <= r_pipe3_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe5_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe5_addr <= r_pipe4_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe6_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe6_addr <= r_pipe5_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe7_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe7_addr <= r_pipe6_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe8_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe8_addr <= r_pipe7_addr;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe9_addr <= {OFMAPS_BRAM_ADDR_WIDTH{1'd0}};
        end
        else begin
            r_pipe9_addr <= r_pipe8_addr;
        end
    end

//////////////////////valid_pipeline//////////////////////////

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe0_valid <= 1'd0;
        end
        else begin
            r_pipe0_valid <= i_valid;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe1_valid <= 1'd0;
        end
        else begin
            r_pipe1_valid <= r_pipe0_valid;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe2_valid <= 1'd0;
        end
        else begin
            r_pipe2_valid <= r_pipe1_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe3_valid <= 1'd0;
        end
        else begin
            r_pipe3_valid <= r_pipe2_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe4_valid <= 1'd0;
        end
        else begin
            r_pipe4_valid <= r_pipe3_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe5_valid <= 1'd0;
        end
        else begin
            r_pipe5_valid <= r_pipe4_valid;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe6_valid <= 1'd0;
        end
        else begin
            r_pipe6_valid <= r_pipe5_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe7_valid <= 1'd0;
        end
        else begin
            r_pipe7_valid <= r_pipe6_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe8_valid <= 1'd0;
        end
        else begin
            r_pipe8_valid <= r_pipe7_valid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe9_valid <= 1'd0;
        end
        else begin
            r_pipe9_valid <= r_pipe8_valid;
        end
    end
    
//////////////////////last_pipeline//////////////////////////

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe0_last <= 1'd0;
        end
        else begin
            r_pipe0_last <= layer_finish;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe1_last <= 1'd0;
        end
        else begin
            r_pipe1_last <= r_pipe0_last;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe2_last <= 1'd0;
        end
        else begin
            r_pipe2_last <= r_pipe1_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe3_last <= 1'd0;
        end
        else begin
            r_pipe3_last <= r_pipe2_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe4_last <= 1'd0;
        end
        else begin
            r_pipe4_last <= r_pipe3_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe5_last <= 1'd0;
        end
        else begin
            r_pipe5_last <= r_pipe4_last;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe6_last <= 1'd0;
        end
        else begin
            r_pipe6_last <= r_pipe5_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe7_last <= 1'd0;
        end
        else begin
            r_pipe7_last <= r_pipe6_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe8_last <= 1'd0;
        end
        else begin
            r_pipe8_last <= r_pipe7_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe9_last <= 1'd0;
        end
        else begin
            r_pipe9_last <= r_pipe8_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe10_last <= 1'd0;
        end
        else begin
            r_pipe10_last <= r_pipe9_last;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            r_pipe11_last <= 1'd0;
        end
        else begin
            r_pipe11_last <= r_pipe10_last;
        end
    end

endmodule