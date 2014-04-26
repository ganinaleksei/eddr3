///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 2011 Xilinx Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//
//   ____   ___
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \   \   \/      Version     : 2012.2
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        
// /___/   /\      Filename    : TX_BITSLICE_TRI.v
// \   \  /  \ 
//  \___\/\___\                    
//                                 
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

`celldefine
module TX_BITSLICE_TRI #(
  `ifdef XIL_TIMING //Simprim 
  parameter LOC = "UNPLACED",  
  `endif
  parameter integer DATA_WIDTH = 8,
  parameter DELAY_FORMAT = "TIME",
  parameter DELAY_TYPE = "FIXED",
  parameter integer DELAY_VALUE = 0,
  parameter [0:0] INIT = 1'b1,
  parameter [0:0] IS_CLK_INVERTED = 1'b0,
  parameter [0:0] IS_RST_DLY_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter OUTPUT_PHASE_90 = "FALSE",
  parameter real REFCLK_FREQUENCY = 300.0,
  parameter UPDATE_MODE = "ASYNC"
)(
  output [10:0] BIT_CTRL_OUT,
  output [8:0] CNTVALUEOUT,
  output TRI_OUT,

  input [34:0] BIT_CTRL_IN,
  input CE,
  input CLK,
  input [8:0] CNTVALUEIN,
  input EN_VTC,
  input INC,
  input LOAD,
  input RST,
  input RST_DLY
);
  
// define constants
  localparam MODULE_NAME = "TX_BITSLICE_TRI";
  localparam in_delay    = 0;
  localparam out_delay   = 0;
  localparam inclk_delay    = 0;
  localparam outclk_delay   = 0;

// Parameter encodings and registers

  `ifndef XIL_DR
  localparam [3:0] DATA_WIDTH_REG = DATA_WIDTH;
  localparam [40:1] DELAY_FORMAT_REG = DELAY_FORMAT;
  localparam [64:1] DELAY_TYPE_REG = DELAY_TYPE;
  localparam [10:0] DELAY_VALUE_REG = DELAY_VALUE;
  localparam [0:0] INIT_REG = INIT;
  localparam [0:0] IS_CLK_INVERTED_REG = IS_CLK_INVERTED;
  localparam [0:0] IS_RST_DLY_INVERTED_REG = IS_RST_DLY_INVERTED;
  localparam [0:0] IS_RST_INVERTED_REG = IS_RST_INVERTED;
  localparam [40:1] OUTPUT_PHASE_90_REG = OUTPUT_PHASE_90;
  localparam real REFCLK_FREQUENCY_REG = REFCLK_FREQUENCY;
  localparam [48:1] UPDATE_MODE_REG = UPDATE_MODE;
  `endif

  localparam [0:0] DC_ADJ_EN_REG = 1'b0;
  localparam [2:0] FDLY_REG = 3'b000;
  localparam [2:0] FDLY_RES_REG = 3'b000;
  reg [63:0] REFCLK_FREQUENCY_INT = REFCLK_FREQUENCY * 1000;
  localparam [64:1] TBYTE_CTL_REG = "TBYTE_IN";
  localparam [40:1] XIPHY_BITSLICE_MODE_REG = "TRUE";

  wire IS_CLK_INVERTED_BIN;
  wire IS_RST_DLY_INVERTED_BIN;
  wire IS_RST_INVERTED_BIN;

  tri0 glblGSR = glbl.GSR;

  `ifdef XIL_TIMING //Simprim 
  reg notifier;
  `endif
  reg trig_attr = 1'b0;
  reg attr_err = 1'b0;
  
// include dynamic registers - XILINX test only
  `ifdef XIL_DR
  `include "TX_BITSLICE_TRI_dr.v"
  `endif

  wire CDATAOUT_out;
  wire TRI_OUT_out;
  wire T_OUT_out;
  wire [10:0] BIT_CTRL_OUT_out;
  wire [8:0] CNTVALUEOUT_out;

  wire TRI_OUT_delay;
  wire [10:0] BIT_CTRL_OUT_delay;
  wire [8:0] CNTVALUEOUT_delay;

  wire CDATAIN0_in;
  wire CDATAIN1_in;
  wire CE_in;
  wire CLK_in;
  wire EN_VTC_in;
  wire INC_in;
  wire LOAD_in;
  wire OFD_CE_in;
  wire RST_DLY_in;
  wire RST_in;
  wire [34:0] BIT_CTRL_IN_in;
  wire [8:0] CNTVALUEIN_in;

  wire CE_delay;
  wire CLK_delay;
  wire EN_VTC_delay;
  wire INC_delay;
  wire LOAD_delay;
  wire RST_DLY_delay;
  wire RST_delay;
  wire [34:0] BIT_CTRL_IN_delay;
  wire [8:0] CNTVALUEIN_delay;

  
  assign #(out_delay) BIT_CTRL_OUT = BIT_CTRL_OUT_delay;
  assign #(out_delay) CNTVALUEOUT = CNTVALUEOUT_delay;
  assign #(out_delay) TRI_OUT = TRI_OUT_delay;
  
`ifndef XIL_TIMING // inputs with timing checks
  assign #(inclk_delay) CLK_delay = CLK;

  assign #(in_delay) BIT_CTRL_IN_delay = BIT_CTRL_IN;
  assign #(in_delay) CE_delay = CE;
  assign #(in_delay) CNTVALUEIN_delay = CNTVALUEIN;
  assign #(in_delay) INC_delay = INC;
  assign #(in_delay) LOAD_delay = LOAD;
`endif //  `ifndef XIL_TIMING
// inputs with no timing checks

  assign #(in_delay) EN_VTC_delay = EN_VTC;
  assign #(in_delay) RST_DLY_delay = RST_DLY;
  assign #(in_delay) RST_delay = RST;

  assign BIT_CTRL_OUT_delay = BIT_CTRL_OUT_out;
  assign CNTVALUEOUT_delay = CNTVALUEOUT_out;
  assign TRI_OUT_delay = TRI_OUT_out;

  assign BIT_CTRL_IN_in = BIT_CTRL_IN_delay;
  assign CE_in = CE_delay;
  assign CLK_in = CLK_delay ^ IS_CLK_INVERTED_BIN;
  assign CNTVALUEIN_in = CNTVALUEIN_delay;
  assign EN_VTC_in = EN_VTC_delay;
  assign INC_in = INC_delay;
  assign LOAD_in = LOAD_delay;
  assign RST_DLY_in = RST_DLY_delay ^ IS_RST_DLY_INVERTED_BIN;
  assign RST_in = RST_delay ^ IS_RST_INVERTED_BIN;


  initial begin
  #1;
  trig_attr = ~trig_attr;
  end

  assign IS_CLK_INVERTED_BIN = IS_CLK_INVERTED_REG;

  assign IS_RST_DLY_INVERTED_BIN = IS_RST_DLY_INVERTED_REG;

  assign IS_RST_INVERTED_BIN = IS_RST_INVERTED_REG;

  always @ (trig_attr) begin
    #1;
    if ((DATA_WIDTH_REG != 8) &&
        (DATA_WIDTH_REG != 2) &&
        (DATA_WIDTH_REG != 4)) begin
      $display("Attribute Syntax Error : The attribute DATA_WIDTH on %s instance %m is set to %d.  Legal values for this attribute are 2 to 8.", MODULE_NAME, DATA_WIDTH_REG, 8);
      attr_err = 1'b1;
    end

    if ((DELAY_FORMAT_REG != "TIME") &&
        (DELAY_FORMAT_REG != "COUNT")) begin
      $display("Attribute Syntax Error : The attribute DELAY_FORMAT on %s instance %m is set to %s.  Legal values for this attribute are TIME or COUNT.", MODULE_NAME, DELAY_FORMAT_REG);
      attr_err = 1'b1;
    end

    if ((DELAY_TYPE_REG != "FIXED") &&
        (DELAY_TYPE_REG != "VARIABLE") &&
        (DELAY_TYPE_REG != "VAR_LOAD")) begin
      $display("Attribute Syntax Error : The attribute DELAY_TYPE on %s instance %m is set to %s.  Legal values for this attribute are FIXED, VARIABLE or VAR_LOAD.", MODULE_NAME, DELAY_TYPE_REG);
      attr_err = 1'b1;
    end

    if ((DELAY_VALUE_REG < 0) || (DELAY_VALUE_REG > 1250)) begin
      $display("Attribute Syntax Error : The attribute DELAY_VALUE on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1250.", MODULE_NAME, DELAY_VALUE_REG);
      attr_err = 1'b1;
    end

    if ((INIT_REG < 1'b0) || (INIT_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute INIT on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, INIT_REG);
      attr_err = 1'b1;
    end

    if ((IS_CLK_INVERTED_REG < 1'b0) || (IS_CLK_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_CLK_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_CLK_INVERTED_REG);
      attr_err = 1'b1;
    end

    if ((IS_RST_DLY_INVERTED_REG < 1'b0) || (IS_RST_DLY_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_RST_DLY_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_RST_DLY_INVERTED_REG);
      attr_err = 1'b1;
    end

    if ((IS_RST_INVERTED_REG < 1'b0) || (IS_RST_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_RST_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_RST_INVERTED_REG);
      attr_err = 1'b1;
    end

    if ((OUTPUT_PHASE_90_REG != "FALSE") &&
        (OUTPUT_PHASE_90_REG != "TRUE")) begin
      $display("Attribute Syntax Error : The attribute OUTPUT_PHASE_90 on %s instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE.", MODULE_NAME, OUTPUT_PHASE_90_REG);
      attr_err = 1'b1;
    end

    if ((UPDATE_MODE_REG != "ASYNC") &&
        (UPDATE_MODE_REG != "MANUAL") &&
        (UPDATE_MODE_REG != "SYNC")) begin
      $display("Attribute Syntax Error : The attribute UPDATE_MODE on %s instance %m is set to %s.  Legal values for this attribute are ASYNC, MANUAL or SYNC.", MODULE_NAME, UPDATE_MODE_REG);
      attr_err = 1'b1;
    end

    if (REFCLK_FREQUENCY_REG >= 300.0 && REFCLK_FREQUENCY_REG <= 1333.0) begin // float
      REFCLK_FREQUENCY_INT <= REFCLK_FREQUENCY_REG * 1000;
    end
    else begin
      $display("Attribute Syntax Error : The attribute REFCLK_FREQUENCY on %s instance %m is set to %f.  Legal values for this attribute are  300.0 to 1333.0.", MODULE_NAME, REFCLK_FREQUENCY_REG);
      attr_err = 1'b1;
    end

  if (attr_err == 1'b1) $finish;
  end


  assign CDATAIN0_in = 1'b1; // tie off
  assign CDATAIN1_in = 1'b1; // tie off
  assign OFD_CE_in = 1'b0; // tie off

  SIP_TX_BITSLICE_TRI SIP_TX_BITSLICE_TRI_INST (
    .DATA_WIDTH (DATA_WIDTH_REG),
    .DC_ADJ_EN (DC_ADJ_EN_REG),
    .DELAY_FORMAT (DELAY_FORMAT_REG),
    .DELAY_TYPE (DELAY_TYPE_REG),
    .DELAY_VALUE (DELAY_VALUE_REG),
    .FDLY (FDLY_REG),
    .FDLY_RES (FDLY_RES_REG),
    .INIT (INIT_REG),
    .OUTPUT_PHASE_90 (OUTPUT_PHASE_90_REG),
    .REFCLK_FREQUENCY (REFCLK_FREQUENCY_INT),
    .TBYTE_CTL (TBYTE_CTL_REG),
    .UPDATE_MODE (UPDATE_MODE_REG),
    .XIPHY_BITSLICE_MODE (XIPHY_BITSLICE_MODE_REG),
    .BIT_CTRL_OUT (BIT_CTRL_OUT_out),
    .CDATAOUT (CDATAOUT_out),
    .CNTVALUEOUT (CNTVALUEOUT_out),
    .TRI_OUT (TRI_OUT_out),
    .T_OUT (T_OUT_out),
    .BIT_CTRL_IN (BIT_CTRL_IN_in),
    .CDATAIN0 (CDATAIN0_in),
    .CDATAIN1 (CDATAIN1_in),
    .CE (CE_in),
    .CLK (CLK_in),
    .CNTVALUEIN (CNTVALUEIN_in),
    .EN_VTC (EN_VTC_in),
    .INC (INC_in),
    .LOAD (LOAD_in),
    .OFD_CE (OFD_CE_in),
    .RST (RST_in),
    .RST_DLY (RST_DLY_in),
    .GSR (glblGSR)
  );

    specify
    (BIT_CTRL_IN *> TRI_OUT) = (0:0:0, 0:0:0);
`ifdef XIL_TIMING // Simprim
    $period (negedge BIT_CTRL_IN, 0:0:0, notifier);
    $period (negedge CLK, 0:0:0, notifier);
    $period (posedge BIT_CTRL_IN, 0:0:0, notifier);
    $period (posedge CLK, 0:0:0, notifier);
    $setuphold (negedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (negedge CLK, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (negedge CLK, negedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (negedge CLK, negedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (negedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (negedge CLK, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (negedge CLK, posedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (negedge CLK, posedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge CE, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CE_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CNTVALUEIN_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge INC, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, INC_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge LOAD, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, LOAD_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge CE, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CE_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CNTVALUEIN_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge INC, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, INC_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge LOAD, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, LOAD_delay);
    $setuphold (posedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (posedge CLK, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (posedge CLK, negedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (posedge CLK, negedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (posedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (posedge CLK, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (posedge CLK, posedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (posedge CLK, posedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $width (negedge BIT_CTRL_IN, 0:0:0, 0, notifier);
    $width (negedge CLK, 0:0:0, 0, notifier);
    $width (posedge BIT_CTRL_IN, 0:0:0, 0, notifier);
    $width (posedge CLK, 0:0:0, 0, notifier);
`endif
    specparam PATHPULSE$ = 0;
  endspecify

endmodule

`endcelldefine
