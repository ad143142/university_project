module weight_preload 
(
    //golbal
    input wire clk,
    input wire rst_n,

    //data
    input wire [5-1:0] weight_from_bram,
    
    output wire [25-1:0] weight_from_preload,

    //control
    input wire input_valid

);
    
    reg weight_reg_00,weight_reg_01,weight_reg_02,weight_reg_03,weight_reg_04;
    reg weight_reg_10,weight_reg_11,weight_reg_12,weight_reg_13,weight_reg_14;
    reg weight_reg_20,weight_reg_21,weight_reg_22,weight_reg_23,weight_reg_24;
    reg weight_reg_30,weight_reg_31,weight_reg_32,weight_reg_33,weight_reg_34;
    reg weight_reg_40,weight_reg_41,weight_reg_42,weight_reg_43,weight_reg_44;

    assign weight_from_preload={weight_reg_44,weight_reg_43,weight_reg_42,weight_reg_41,weight_reg_40,
                                weight_reg_34,weight_reg_33,weight_reg_32,weight_reg_31,weight_reg_30,
                                weight_reg_24,weight_reg_23,weight_reg_22,weight_reg_21,weight_reg_20,
                                weight_reg_14,weight_reg_13,weight_reg_12,weight_reg_11,weight_reg_10,
                                weight_reg_04,weight_reg_03,weight_reg_02,weight_reg_01,weight_reg_00};

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_reg_00<=0;
            weight_reg_01<=0;
            weight_reg_02<=0;
            weight_reg_03<=0;
            weight_reg_04<=0;
        end
        else begin
            if(input_valid) begin
                weight_reg_00<=weight_from_bram[0];
                weight_reg_01<=weight_reg_00;
                weight_reg_02<=weight_reg_01;
                weight_reg_03<=weight_reg_02;
                weight_reg_04<=weight_reg_03;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_reg_10<=0;
            weight_reg_11<=0;
            weight_reg_12<=0;
            weight_reg_13<=0;
            weight_reg_14<=0;
        end
        else begin
            if(input_valid) begin
                weight_reg_10<=weight_from_bram[1];
                weight_reg_11<=weight_reg_10;
                weight_reg_12<=weight_reg_11;
                weight_reg_13<=weight_reg_12;
                weight_reg_14<=weight_reg_13;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_reg_20<=0;
            weight_reg_21<=0;
            weight_reg_22<=0;
            weight_reg_23<=0;
            weight_reg_24<=0;
        end
        else begin
            if(input_valid) begin
                weight_reg_20<=weight_from_bram[2];
                weight_reg_21<=weight_reg_20;
                weight_reg_22<=weight_reg_21;
                weight_reg_23<=weight_reg_22;
                weight_reg_24<=weight_reg_23;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_reg_30<=0;
            weight_reg_31<=0;
            weight_reg_32<=0;
            weight_reg_33<=0;
            weight_reg_34<=0;
        end
        else begin
            if(input_valid) begin
                weight_reg_30<=weight_from_bram[3];
                weight_reg_31<=weight_reg_30;
                weight_reg_32<=weight_reg_31;
                weight_reg_33<=weight_reg_32;
                weight_reg_34<=weight_reg_33;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            weight_reg_40<=0;
            weight_reg_41<=0;
            weight_reg_42<=0;
            weight_reg_43<=0;
            weight_reg_44<=0;
        end
        else begin
            if(input_valid) begin
                weight_reg_40<=weight_from_bram[4];
                weight_reg_41<=weight_reg_40;
                weight_reg_42<=weight_reg_41;
                weight_reg_43<=weight_reg_42;
                weight_reg_44<=weight_reg_43;
            end
        end
    end


endmodule