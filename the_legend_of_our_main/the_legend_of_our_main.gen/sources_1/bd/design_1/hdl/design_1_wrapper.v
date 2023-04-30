//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
//Date        : Sun Apr 30 00:09:05 2023
//Host        : yinchian-ASUS-TUF-Gaming-A15-FA506II-FA506II running 64-bit Ubuntu 22.04.2 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (BRAM_PORTA_0_addr,
    BRAM_PORTA_0_clk,
    BRAM_PORTA_0_din,
    BRAM_PORTA_0_dout,
    BRAM_PORTA_0_en,
    BRAM_PORTA_0_we,
    BRAM_PORTB_0_addr,
    BRAM_PORTB_0_clk,
    BRAM_PORTB_0_din,
    BRAM_PORTB_0_dout,
    BRAM_PORTB_0_en,
    BRAM_PORTB_0_we);
  input [11:0]BRAM_PORTA_0_addr;
  input BRAM_PORTA_0_clk;
  input [1279:0]BRAM_PORTA_0_din;
  output [1279:0]BRAM_PORTA_0_dout;
  input BRAM_PORTA_0_en;
  input [0:0]BRAM_PORTA_0_we;
  input [11:0]BRAM_PORTB_0_addr;
  input BRAM_PORTB_0_clk;
  input [1279:0]BRAM_PORTB_0_din;
  output [1279:0]BRAM_PORTB_0_dout;
  input BRAM_PORTB_0_en;
  input [0:0]BRAM_PORTB_0_we;

  wire [11:0]BRAM_PORTA_0_addr;
  wire BRAM_PORTA_0_clk;
  wire [1279:0]BRAM_PORTA_0_din;
  wire [1279:0]BRAM_PORTA_0_dout;
  wire BRAM_PORTA_0_en;
  wire [0:0]BRAM_PORTA_0_we;
  wire [11:0]BRAM_PORTB_0_addr;
  wire BRAM_PORTB_0_clk;
  wire [1279:0]BRAM_PORTB_0_din;
  wire [1279:0]BRAM_PORTB_0_dout;
  wire BRAM_PORTB_0_en;
  wire [0:0]BRAM_PORTB_0_we;

  design_1 design_1_i
       (.BRAM_PORTA_0_addr(BRAM_PORTA_0_addr),
        .BRAM_PORTA_0_clk(BRAM_PORTA_0_clk),
        .BRAM_PORTA_0_din(BRAM_PORTA_0_din),
        .BRAM_PORTA_0_dout(BRAM_PORTA_0_dout),
        .BRAM_PORTA_0_en(BRAM_PORTA_0_en),
        .BRAM_PORTA_0_we(BRAM_PORTA_0_we),
        .BRAM_PORTB_0_addr(BRAM_PORTB_0_addr),
        .BRAM_PORTB_0_clk(BRAM_PORTB_0_clk),
        .BRAM_PORTB_0_din(BRAM_PORTB_0_din),
        .BRAM_PORTB_0_dout(BRAM_PORTB_0_dout),
        .BRAM_PORTB_0_en(BRAM_PORTB_0_en),
        .BRAM_PORTB_0_we(BRAM_PORTB_0_we));
endmodule
