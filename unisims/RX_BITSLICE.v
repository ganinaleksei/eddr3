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
// /___/   /\      Filename    : RX_BITSLICE.v
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
module RX_BITSLICE #(
  `ifdef XIL_TIMING //Simprim 
  parameter LOC = "UNPLACED",  
  `endif
  parameter CASCADE = "FALSE",
  parameter DATA_TYPE = "NONE",
  parameter integer DATA_WIDTH = 8,
  parameter DELAY_FORMAT = "TIME",
  parameter DELAY_TYPE = "FIXED",
  parameter integer DELAY_VALUE = 0,
  parameter integer DELAY_VALUE_EXT = 0,
  parameter FIFO_SYNC_MODE = "FALSE",
  parameter [0:0] IS_CLK_EXT_INVERTED = 1'b0,
  parameter [0:0] IS_CLK_INVERTED = 1'b0,
  parameter [0:0] IS_RST_DLY_EXT_INVERTED = 1'b0,
  parameter [0:0] IS_RST_DLY_INVERTED = 1'b0,
  parameter [0:0] IS_RST_INVERTED = 1'b0,
  parameter real REFCLK_FREQUENCY = 300.0,
  parameter UPDATE_MODE = "ASYNC",
  parameter UPDATE_MODE_EXT = "ASYNC"
)(
  output [34:0] BIT_CTRL_OUT,
  output [28:0] BIT_CTRL_OUT_EXT,
  output [8:0] CNTVALUEOUT,
  output [8:0] CNTVALUEOUT_EXT,
  output FIFO_EMPTY,
  output FIFO_WRCLK_OUT,
  output [7:0] Q,

  input [23:0] BIT_CTRL_IN,
  input [14:0] BIT_CTRL_IN_EXT,
  input CE,
  input CE_EXT,
  input CLK,
  input CLK_EXT,
  input [8:0] CNTVALUEIN,
  input [8:0] CNTVALUEIN_EXT,
  input DATAIN,
  input EN_VTC,
  input EN_VTC_EXT,
  input FIFO_RD_CLK,
  input FIFO_RD_EN,
  input INC,
  input INC_EXT,
  input LOAD,
  input LOAD_EXT,
  input RST,
  input RST_DLY,
  input RST_DLY_EXT
);
  
// define constants
  localparam MODULE_NAME = "RX_BITSLICE";
  localparam in_delay    = 0;
  localparam out_delay   = 0;
  localparam inclk_delay    = 0;
  localparam outclk_delay   = 0;

// Parameter encodings and registers

  `ifndef XIL_DR
  localparam [40:1] CASCADE_REG = CASCADE;
  localparam [112:1] DATA_TYPE_REG = DATA_TYPE;
  localparam [3:0] DATA_WIDTH_REG = DATA_WIDTH;
  localparam [40:1] DELAY_FORMAT_REG = DELAY_FORMAT;
  localparam [64:1] DELAY_TYPE_REG = DELAY_TYPE;
  localparam [10:0] DELAY_VALUE_REG = DELAY_VALUE;
  localparam [10:0] DELAY_VALUE_EXT_REG = DELAY_VALUE_EXT;
  localparam [40:1] FIFO_SYNC_MODE_REG = FIFO_SYNC_MODE;
  localparam [0:0] IS_CLK_EXT_INVERTED_REG = IS_CLK_EXT_INVERTED;
  localparam [0:0] IS_CLK_INVERTED_REG = IS_CLK_INVERTED;
  localparam [0:0] IS_RST_DLY_EXT_INVERTED_REG = IS_RST_DLY_EXT_INVERTED;
  localparam [0:0] IS_RST_DLY_INVERTED_REG = IS_RST_DLY_INVERTED;
  localparam [0:0] IS_RST_INVERTED_REG = IS_RST_INVERTED;
  localparam real REFCLK_FREQUENCY_REG = REFCLK_FREQUENCY;
  localparam [48:1] UPDATE_MODE_REG = UPDATE_MODE;
  localparam [48:1] UPDATE_MODE_EXT_REG = UPDATE_MODE_EXT;
  `endif

  localparam [0:0] DC_ADJ_EN_REG = 1'b0;
  localparam [0:0] DC_ADJ_EN_EXT_REG = 1'b0;
  localparam [40:1] DDR_DIS_DQS_REG = "TRUE";
  localparam [2:0] FDLY_REG = 3'b000;
  localparam [2:0] FDLY_EXT_REG = 3'b000;
  localparam [2:0] FDLY_RES_REG = 3'b000;
  localparam [2:0] FDLY_RES_EXT_REG = 3'b000;
  localparam [0:0] RECALIBRATE_EN_REG = 1'b0;
  reg [63:0] REFCLK_FREQUENCY_INT = REFCLK_FREQUENCY * 1000;
  localparam [64:1] TBYTE_CTL_REG = "T";
  localparam [40:1] XIPHY_BITSLICE_MODE_REG = "TRUE";

  wire IS_CLK_EXT_INVERTED_BIN;
  wire IS_CLK_INVERTED_BIN;
  wire IS_RST_DLY_EXT_INVERTED_BIN;
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
  `include "RX_BITSLICE_dr.v"
  `endif

  wire FIFO_EMPTY_out;
  wire FIFO_WRCLK_OUT_out;
  wire [28:0] BIT_CTRL_OUT_EXT_out;
  wire [34:0] BIT_CTRL_OUT_out;
  wire [7:0] Q_out;
  wire [8:0] CNTVALUEOUT_EXT_out;
  wire [8:0] CNTVALUEOUT_out;

  wire FIFO_EMPTY_delay;
  wire FIFO_WRCLK_OUT_delay;
  wire [28:0] BIT_CTRL_OUT_EXT_delay;
  wire [34:0] BIT_CTRL_OUT_delay;
  wire [7:0] Q_delay;
  wire [8:0] CNTVALUEOUT_EXT_delay;
  wire [8:0] CNTVALUEOUT_delay;

  wire CE_EXT_in;
  wire CE_in;
  wire CLK_EXT_in;
  wire CLK_in;
  wire DATAIN_in;
  wire EN_VTC_EXT_in;
  wire EN_VTC_in;
  wire FIFO_RD_CLK_in;
  wire FIFO_RD_EN_in;
  wire IFD_CE_in;
  wire INC_EXT_in;
  wire INC_in;
  wire LOAD_EXT_in;
  wire LOAD_in;
  wire OFD_CE_in;
  wire RST_DLY_EXT_in;
  wire RST_DLY_in;
  wire RST_in;
  wire RX_DATAIN1_in;
  wire TX_RST_in;
  wire T_in;
  wire [14:0] BIT_CTRL_IN_EXT_in;
  wire [23:0] BIT_CTRL_IN_in;
  wire [7:0] TX_D_in;
  wire [8:0] CNTVALUEIN_EXT_in;
  wire [8:0] CNTVALUEIN_in;

  wire CE_EXT_delay;
  wire CE_delay;
  wire CLK_EXT_delay;
  wire CLK_delay;
  wire DATAIN_delay;
  wire EN_VTC_EXT_delay;
  wire EN_VTC_delay;
  wire FIFO_RD_CLK_delay;
  wire FIFO_RD_EN_delay;
  wire INC_EXT_delay;
  wire INC_delay;
  wire LOAD_EXT_delay;
  wire LOAD_delay;
  wire RST_DLY_EXT_delay;
  wire RST_DLY_delay;
  wire RST_delay;
  wire [14:0] BIT_CTRL_IN_EXT_delay;
  wire [23:0] BIT_CTRL_IN_delay;
  wire [8:0] CNTVALUEIN_EXT_delay;
  wire [8:0] CNTVALUEIN_delay;

  wire IDELAY_DATAIN0_out;
  wire IDELAY_DATAOUT_out;
  
  assign #(out_delay) BIT_CTRL_OUT = BIT_CTRL_OUT_delay;
  assign #(out_delay) BIT_CTRL_OUT_EXT = BIT_CTRL_OUT_EXT_delay;
  assign #(out_delay) CNTVALUEOUT = CNTVALUEOUT_delay;
  assign #(out_delay) CNTVALUEOUT_EXT = CNTVALUEOUT_EXT_delay;
  assign #(out_delay) FIFO_EMPTY = FIFO_EMPTY_delay;
  assign #(out_delay) FIFO_WRCLK_OUT = FIFO_WRCLK_OUT_delay;
  assign #(out_delay) Q = Q_delay;
  
`ifndef XIL_TIMING // inputs with timing checks
  assign #(inclk_delay) CLK_EXT_delay = CLK_EXT;
  assign #(inclk_delay) CLK_delay = CLK;

  assign #(in_delay) BIT_CTRL_IN_EXT_delay = BIT_CTRL_IN_EXT;
  assign #(in_delay) BIT_CTRL_IN_delay = BIT_CTRL_IN;
  assign #(in_delay) CE_EXT_delay = CE_EXT;
  assign #(in_delay) CE_delay = CE;
  assign #(in_delay) CNTVALUEIN_EXT_delay = CNTVALUEIN_EXT;
  assign #(in_delay) CNTVALUEIN_delay = CNTVALUEIN;
  assign #(in_delay) FIFO_RD_CLK_delay = FIFO_RD_CLK;
  assign #(in_delay) FIFO_RD_EN_delay = FIFO_RD_EN;
  assign #(in_delay) INC_EXT_delay = INC_EXT;
  assign #(in_delay) INC_delay = INC;
  assign #(in_delay) LOAD_EXT_delay = LOAD_EXT;
  assign #(in_delay) LOAD_delay = LOAD;
  assign #(in_delay) RST_DLY_EXT_delay = RST_DLY_EXT;
  assign #(in_delay) RST_DLY_delay = RST_DLY;
  assign #(in_delay) RST_delay = RST;
`endif //  `ifndef XIL_TIMING
// inputs with no timing checks

  assign #(in_delay) DATAIN_delay = DATAIN;
  assign #(in_delay) EN_VTC_EXT_delay = EN_VTC_EXT;
  assign #(in_delay) EN_VTC_delay = EN_VTC;

  assign BIT_CTRL_OUT_EXT_delay = BIT_CTRL_OUT_EXT_out;
  assign BIT_CTRL_OUT_delay = BIT_CTRL_OUT_out;
  assign CNTVALUEOUT_EXT_delay = CNTVALUEOUT_EXT_out;
  assign CNTVALUEOUT_delay = CNTVALUEOUT_out;
  assign FIFO_EMPTY_delay = FIFO_EMPTY_out;
  assign FIFO_WRCLK_OUT_delay = FIFO_WRCLK_OUT_out;
  assign Q_delay = Q_out;

  assign BIT_CTRL_IN_EXT_in = BIT_CTRL_IN_EXT_delay;
  assign BIT_CTRL_IN_in = BIT_CTRL_IN_delay;
  assign CE_EXT_in = CE_EXT_delay;
  assign CE_in = CE_delay;
  assign CLK_EXT_in = CLK_EXT_delay ^ IS_CLK_EXT_INVERTED_BIN;
  assign CLK_in = CLK_delay ^ IS_CLK_INVERTED_BIN;
  assign CNTVALUEIN_EXT_in = CNTVALUEIN_EXT_delay;
  assign CNTVALUEIN_in = CNTVALUEIN_delay;
  assign DATAIN_in = DATAIN_delay;
  assign EN_VTC_EXT_in = EN_VTC_EXT_delay;
  assign EN_VTC_in = EN_VTC_delay;
  assign FIFO_RD_CLK_in = FIFO_RD_CLK_delay;
  assign FIFO_RD_EN_in = FIFO_RD_EN_delay;
  assign INC_EXT_in = INC_EXT_delay;
  assign INC_in = INC_delay;
  assign LOAD_EXT_in = LOAD_EXT_delay;
  assign LOAD_in = LOAD_delay;
  assign RST_DLY_EXT_in = RST_DLY_EXT_delay ^ IS_RST_DLY_EXT_INVERTED_BIN;
  assign RST_DLY_in = RST_DLY_delay ^ IS_RST_DLY_INVERTED_BIN;
  assign RST_in = RST_delay ^ IS_RST_INVERTED_BIN;


  initial begin
  #1;
  trig_attr = ~trig_attr;
  end

  assign IS_CLK_EXT_INVERTED_BIN = IS_CLK_EXT_INVERTED_REG;

  assign IS_CLK_INVERTED_BIN = IS_CLK_INVERTED_REG;

  assign IS_RST_DLY_EXT_INVERTED_BIN = IS_RST_DLY_EXT_INVERTED_REG;

  assign IS_RST_DLY_INVERTED_BIN = IS_RST_DLY_INVERTED_REG;

  assign IS_RST_INVERTED_BIN = IS_RST_INVERTED_REG;

  always @ (trig_attr) begin
    #1;
    if ((CASCADE_REG != "FALSE") &&
        (CASCADE_REG != "TRUE")) begin
      $display("Attribute Syntax Error : The attribute CASCADE on %s instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE.", MODULE_NAME, CASCADE_REG);
      attr_err = 1'b1;
    end

    if ((DATA_TYPE_REG != "NONE") &&
        (DATA_TYPE_REG != "CLOCK") &&
        (DATA_TYPE_REG != "DATA") &&
        (DATA_TYPE_REG != "DATA_AND_CLOCK")) begin
      $display("Attribute Syntax Error : The attribute DATA_TYPE on %s instance %m is set to %s.  Legal values for this attribute are NONE, CLOCK, DATA or DATA_AND_CLOCK.", MODULE_NAME, DATA_TYPE_REG);
      attr_err = 1'b1;
    end

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

    if ((DELAY_VALUE_EXT_REG < 0) || (DELAY_VALUE_EXT_REG > 1250)) begin
      $display("Attribute Syntax Error : The attribute DELAY_VALUE_EXT on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1250.", MODULE_NAME, DELAY_VALUE_EXT_REG);
      attr_err = 1'b1;
    end

    if ((DELAY_VALUE_REG < 0) || (DELAY_VALUE_REG > 1250)) begin
      $display("Attribute Syntax Error : The attribute DELAY_VALUE on %s instance %m is set to %d.  Legal values for this attribute are  0 to 1250.", MODULE_NAME, DELAY_VALUE_REG);
      attr_err = 1'b1;
    end

    if ((FIFO_SYNC_MODE_REG != "FALSE") &&
        (FIFO_SYNC_MODE_REG != "TRUE")) begin
      $display("Attribute Syntax Error : The attribute FIFO_SYNC_MODE on %s instance %m is set to %s.  Legal values for this attribute are FALSE or TRUE.", MODULE_NAME, FIFO_SYNC_MODE_REG);
      attr_err = 1'b1;
    end

    if ((IS_CLK_EXT_INVERTED_REG < 1'b0) || (IS_CLK_EXT_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_CLK_EXT_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_CLK_EXT_INVERTED_REG);
      attr_err = 1'b1;
    end

    if ((IS_CLK_INVERTED_REG < 1'b0) || (IS_CLK_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_CLK_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_CLK_INVERTED_REG);
      attr_err = 1'b1;
    end

    if ((IS_RST_DLY_EXT_INVERTED_REG < 1'b0) || (IS_RST_DLY_EXT_INVERTED_REG > 1'b1)) begin
      $display("Attribute Syntax Error : The attribute IS_RST_DLY_EXT_INVERTED on %s instance %m is set to %b.  Legal values for this attribute are 1'b0 to 1'b1.", MODULE_NAME, IS_RST_DLY_EXT_INVERTED_REG);
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

    if ((UPDATE_MODE_EXT_REG != "ASYNC") &&
        (UPDATE_MODE_EXT_REG != "MANUAL") &&
        (UPDATE_MODE_EXT_REG != "SYNC")) begin
      $display("Attribute Syntax Error : The attribute UPDATE_MODE_EXT on %s instance %m is set to %s.  Legal values for this attribute are ASYNC, MANUAL or SYNC.", MODULE_NAME, UPDATE_MODE_EXT_REG);
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


  assign IFD_CE_in = 1'b0; // tie off
  assign OFD_CE_in = 1'b0; // tie off
  assign RX_DATAIN1_in = 1'b0; // tie off
  assign TX_D_in = 8'b00000000; // tie off
  assign TX_RST_in = 1'b1; // tie off
  assign T_in = 1'b1; // tie off

  SIP_RX_BITSLICE SIP_RX_BITSLICE_INST (
    .CASCADE (CASCADE_REG),
    .DATA_TYPE (DATA_TYPE_REG),
    .DATA_WIDTH (DATA_WIDTH_REG),
    .DC_ADJ_EN (DC_ADJ_EN_REG),
    .DC_ADJ_EN_EXT (DC_ADJ_EN_EXT_REG),
    .DDR_DIS_DQS (DDR_DIS_DQS_REG),
    .DELAY_FORMAT (DELAY_FORMAT_REG),
    .DELAY_TYPE (DELAY_TYPE_REG),
    .DELAY_VALUE (DELAY_VALUE_REG),
    .DELAY_VALUE_EXT (DELAY_VALUE_EXT_REG),
    .FDLY (FDLY_REG),
    .FDLY_EXT (FDLY_EXT_REG),
    .FDLY_RES (FDLY_RES_REG),
    .FDLY_RES_EXT (FDLY_RES_EXT_REG),
    .FIFO_SYNC_MODE (FIFO_SYNC_MODE_REG),
    .RECALIBRATE_EN (RECALIBRATE_EN_REG),
    .REFCLK_FREQUENCY (REFCLK_FREQUENCY_INT),
    .TBYTE_CTL (TBYTE_CTL_REG),
    .UPDATE_MODE (UPDATE_MODE_REG),
    .UPDATE_MODE_EXT (UPDATE_MODE_EXT_REG),
    .XIPHY_BITSLICE_MODE (XIPHY_BITSLICE_MODE_REG),
    .BIT_CTRL_OUT (BIT_CTRL_OUT_out),
    .BIT_CTRL_OUT_EXT (BIT_CTRL_OUT_EXT_out),
    .CNTVALUEOUT (CNTVALUEOUT_out),
    .CNTVALUEOUT_EXT (CNTVALUEOUT_EXT_out),
    .FIFO_EMPTY (FIFO_EMPTY_out),
    .FIFO_WRCLK_OUT (FIFO_WRCLK_OUT_out),
    .Q (Q_out),
    .BIT_CTRL_IN (BIT_CTRL_IN_in),
    .BIT_CTRL_IN_EXT (BIT_CTRL_IN_EXT_in),
    .CE (CE_in),
    .CE_EXT (CE_EXT_in),
    .CLK (CLK_in),
    .CLK_EXT (CLK_EXT_in),
    .CNTVALUEIN (CNTVALUEIN_in),
    .CNTVALUEIN_EXT (CNTVALUEIN_EXT_in),
    .DATAIN (DATAIN_in),
    .EN_VTC (EN_VTC_in),
    .EN_VTC_EXT (EN_VTC_EXT_in),
    .FIFO_RD_CLK (FIFO_RD_CLK_in),
    .FIFO_RD_EN (FIFO_RD_EN_in),
    .IFD_CE (IFD_CE_in),
    .INC (INC_in),
    .INC_EXT (INC_EXT_in),
    .LOAD (LOAD_in),
    .LOAD_EXT (LOAD_EXT_in),
    .OFD_CE (OFD_CE_in),
    .RST (RST_in),
    .RST_DLY (RST_DLY_in),
    .RST_DLY_EXT (RST_DLY_EXT_in),
    .RX_DATAIN1 (RX_DATAIN1_in),
    .T (T_in),
    .TX_D (TX_D_in),
    .TX_RST (TX_RST_in),
    .SIM_IDELAY_DATAIN0(IDELAY_DATAIN0_out),
    .SIM_IDELAY_DATAOUT(IDELAY_DATAOUT_out),
    .GSR (glblGSR)
  );

    specify
   (BIT_CTRL_IN *> Q) = (0:0:0, 0:0:0);
    (DATAIN *> BIT_CTRL_OUT) = (0:0:0, 0:0:0);
    (DATAIN *> Q) = (0:0:0, 0:0:0);
    (FIFO_RD_CLK *> Q) = (0:0:0, 0:0:0);
    (FIFO_RD_CLK => FIFO_EMPTY) = (0:0:0, 0:0:0);
    (negedge RST *> (Q +: 0)) = (0:0:0, 0:0:0);
    (posedge RST *> (Q +: 0)) = (0:0:0, 0:0:0);
`ifdef XIL_TIMING // Simprim
    $period (negedge BIT_CTRL_IN[21], 0:0:0, notifier);
    $period (negedge BIT_CTRL_IN_EXT[0], 0:0:0, notifier);
    $period (negedge CLK, 0:0:0, notifier);
    $period (negedge CLK_EXT, 0:0:0, notifier);
    $period (negedge FIFO_RD_CLK, 0:0:0, notifier);
    $period (posedge BIT_CTRL_IN[21], 0:0:0, notifier);
    $period (posedge BIT_CTRL_IN_EXT[0], 0:0:0, notifier);
    $period (posedge CLK, 0:0:0, notifier);
    $period (posedge CLK_EXT, 0:0:0, notifier);
    $period (posedge FIFO_RD_CLK, 0:0:0, notifier);
    $recrem ( negedge RST, posedge BIT_CTRL_IN, 0:0:0, 0:0:0, notifier,,, RST_delay, BIT_CTRL_IN_delay);
    $recrem ( negedge RST, posedge FIFO_RD_CLK, 0:0:0, 0:0:0, notifier,,, RST_delay, FIFO_RD_CLK_delay);
    $recrem ( negedge RST_DLY, negedge CLK, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, CLK_delay);
    $recrem ( negedge RST_DLY, posedge BIT_CTRL_IN, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, BIT_CTRL_IN_delay);
    $recrem ( negedge RST_DLY, posedge CLK, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, CLK_delay);
    $recrem ( negedge RST_DLY_EXT, negedge CLK_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, CLK_EXT_delay);
    $recrem ( negedge RST_DLY_EXT, posedge BIT_CTRL_IN_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, BIT_CTRL_IN_EXT_delay);
    $recrem ( negedge RST_DLY_EXT, posedge CLK_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, CLK_EXT_delay);
    $recrem ( posedge RST, posedge BIT_CTRL_IN, 0:0:0, 0:0:0, notifier,,, RST_delay, BIT_CTRL_IN_delay);
    $recrem ( posedge RST, posedge FIFO_RD_CLK, 0:0:0, 0:0:0, notifier,,, RST_delay, FIFO_RD_CLK_delay);
    $recrem ( posedge RST_DLY, negedge CLK, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, CLK_delay);
    $recrem ( posedge RST_DLY, posedge BIT_CTRL_IN, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, BIT_CTRL_IN_delay);
    $recrem ( posedge RST_DLY, posedge CLK, 0:0:0, 0:0:0, notifier,,, RST_DLY_delay, CLK_delay);
    $recrem ( posedge RST_DLY_EXT, negedge CLK_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, CLK_EXT_delay);
    $recrem ( posedge RST_DLY_EXT, posedge BIT_CTRL_IN_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, BIT_CTRL_IN_EXT_delay);
    $recrem ( posedge RST_DLY_EXT, posedge CLK_EXT, 0:0:0, 0:0:0, notifier,,, RST_DLY_EXT_delay, CLK_EXT_delay);
    $setuphold (negedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (negedge CLK, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (negedge CLK, negedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (negedge CLK, negedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (negedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (negedge CLK, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (negedge CLK, posedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (negedge CLK, posedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (negedge CLK_EXT, negedge CE_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CE_EXT_delay);
    $setuphold (negedge CLK_EXT, negedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (negedge CLK_EXT, negedge INC_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, INC_EXT_delay);
    $setuphold (negedge CLK_EXT, negedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, LOAD_EXT_delay);
    $setuphold (negedge CLK_EXT, posedge CE_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CE_EXT_delay);
    $setuphold (negedge CLK_EXT, posedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (negedge CLK_EXT, posedge INC_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, INC_EXT_delay);
    $setuphold (negedge CLK_EXT, posedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, LOAD_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge CE, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CE_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CNTVALUEIN_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge INC, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, INC_delay);
    $setuphold (posedge BIT_CTRL_IN, negedge LOAD, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, LOAD_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge CE, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CE_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, CNTVALUEIN_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge INC, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, INC_delay);
    $setuphold (posedge BIT_CTRL_IN, posedge LOAD, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_delay, LOAD_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, negedge CE_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, CE_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, negedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, negedge INC_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, INC_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, negedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, LOAD_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, posedge CE_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, CE_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, posedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, posedge INC_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, INC_EXT_delay);
    $setuphold (posedge BIT_CTRL_IN_EXT, posedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, BIT_CTRL_IN_EXT_delay, LOAD_EXT_delay);
    $setuphold (posedge CLK, negedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (posedge CLK, negedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (posedge CLK, negedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (posedge CLK, negedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (posedge CLK, posedge CE, 0:0:0, 0:0:0, notifier,,, CLK_delay, CE_delay);
    $setuphold (posedge CLK, posedge CNTVALUEIN, 0:0:0, 0:0:0, notifier,,, CLK_delay, CNTVALUEIN_delay);
    $setuphold (posedge CLK, posedge INC, 0:0:0, 0:0:0, notifier,,, CLK_delay, INC_delay);
    $setuphold (posedge CLK, posedge LOAD, 0:0:0, 0:0:0, notifier,,, CLK_delay, LOAD_delay);
    $setuphold (posedge CLK_EXT, negedge CE_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CE_EXT_delay);
    $setuphold (posedge CLK_EXT, negedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (posedge CLK_EXT, negedge INC_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, INC_EXT_delay);
    $setuphold (posedge CLK_EXT, negedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, LOAD_EXT_delay);
    $setuphold (posedge CLK_EXT, posedge CE_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CE_EXT_delay);
    $setuphold (posedge CLK_EXT, posedge CNTVALUEIN_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, CNTVALUEIN_EXT_delay);
    $setuphold (posedge CLK_EXT, posedge INC_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, INC_EXT_delay);
    $setuphold (posedge CLK_EXT, posedge LOAD_EXT, 0:0:0, 0:0:0, notifier,,, CLK_EXT_delay, LOAD_EXT_delay);
    $setuphold (posedge FIFO_RD_CLK, negedge FIFO_RD_EN, 0:0:0, 0:0:0, notifier,,, FIFO_RD_CLK_delay, FIFO_RD_EN_delay);
    $setuphold (posedge FIFO_RD_CLK, posedge FIFO_RD_EN, 0:0:0, 0:0:0, notifier,,, FIFO_RD_CLK_delay, FIFO_RD_EN_delay);
    $width (negedge BIT_CTRL_IN, 0:0:0, 0, notifier);
    $width (negedge BIT_CTRL_IN_EXT, 0:0:0, 0, notifier);
    $width (negedge CLK, 0:0:0, 0, notifier);
    $width (negedge CLK_EXT, 0:0:0, 0, notifier);
    $width (negedge FIFO_RD_CLK, 0:0:0, 0, notifier);
    $width (posedge BIT_CTRL_IN, 0:0:0, 0, notifier);
    $width (posedge BIT_CTRL_IN_EXT, 0:0:0, 0, notifier);
    $width (posedge CLK, 0:0:0, 0, notifier);
    $width (posedge CLK_EXT, 0:0:0, 0, notifier);
    $width (posedge FIFO_RD_CLK, 0:0:0, 0, notifier);
`endif
    specparam PATHPULSE$ = 0;
  endspecify

endmodule

`endcelldefine
