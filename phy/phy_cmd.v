/*******************************************************************************
 * Module: phy_cmd
 * Date:2014-05-15  
 * Author: Andrey Filippov
 * Description: Executes a stream of commands to DDR3 phy at 1/2 ddr3 clock, global
 * (also proveides r/w interface to the x64 external buffer)
 *
 * Copyright (c) 2014 Elphel, Inc.
 * phy_cmd.v is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 *  phy_cmd.v is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/> .
 *******************************************************************************/
`timescale 1ns/1ps

module  phy_cmd#(
    parameter ADDRESS_NUMBER = 15,
    parameter PHASE_WIDTH =     8,
    parameter SLEW_DQ =         "SLOW",
    parameter SLEW_DQS =        "SLOW",
    parameter SLEW_CMDA =       "SLOW",
    parameter SLEW_CLK =       "SLOW",
    parameter IBUF_LOW_PWR =    "TRUE",
    parameter real REFCLK_FREQUENCY = 300.0,
    parameter HIGH_PERFORMANCE_MODE = "FALSE",
    parameter CLKIN_PERIOD          = 10, //ns >1.25, 600<Fvco<1200
    parameter CLKFBOUT_MULT =       8, // Fvco=Fclkin*CLKFBOUT_MULT_F/DIVCLK_DIVIDE, Fout=Fvco/CLKOUT#_DIVIDE
    parameter CLKFBOUT_MULT_REF =   9, // Fvco=Fclkin*CLKFBOUT_MULT_F/DIVCLK_DIVIDE, Fout=Fvco/CLKOUT#_DIVIDE
    parameter CLKFBOUT_DIV_REF =    3, // To get 300MHz for the reference clock
    parameter DIVCLK_DIVIDE=        1,
    parameter CLKFBOUT_PHASE =      0.000,
    parameter ICLK_PHASE =          0.000,
    parameter CLK_PHASE =           0.000,
    parameter CLK_DIV_PHASE =       0.000,
    parameter MCLK_PHASE =          90.000,
    parameter REF_JITTER1 =         0.010,
    parameter SS_EN =              "FALSE",
    parameter SS_MODE =      "CENTER_HIGH",
    parameter SS_MOD_PERIOD =       10000,
    parameter CMD_PAUSE_BITS=       6, // numer of (address) bits to encode pause
    parameter CMD_DONE_BIT=         6  // bit number (address) to signal sequence done
)(
    // DDR3 interface
    output                       SDCLK, // DDR3 clock differential output, positive
    output                       SDNCLK,// DDR3 clock differential output, negative
    output  [ADDRESS_NUMBER-1:0] SDA,   // output address ports (14:0) for 4Gb device
    output                 [2:0] SDBA,  // output bank address ports
    output                       SDWE,  // output WE port
    output                       SDRAS, // output RAS port
    output                       SDCAS, // output CAS port
    output                       SDCKE, // output Clock Enable port
    output                       SDODT, // output ODT port

    inout                 [15:0] SDD,       // DQ  I/O pads
    inout                        SDDML,      // LDM  I/O pad (actually only output)
    inout                        DQSL,     // LDQS I/O pad
    inout                        NDQSL,    // ~LDQS I/O pad
    inout                        SDDMU,      // UDM  I/O pad (actually only output)
    inout                        DQSU,     // UDQS I/O pad
    inout                        NDQSU,    // ~UDQS I/O pad
// clocks, reset
    input                        clk_in,
    input                        rst_in,
    output                       mclk,     // global clock, half DDR3 clock, synchronizes all I/O thorough the command port
// inteface to control I/O delays and mmcm
    input                  [7:0] dly_data, // delay value (3 LSB - fine delay)
    input                  [6:0] dly_addr, // select which delay to program
    input                        ld_delay, // load delay data to selected iodelayl (clk_div synchronous)
    input                        set,       // clk_div synchronous set all delays from previously loaded values
    output                       locked,
    output                       ps_rdy,
    output     [PHASE_WIDTH-1:0] ps_out, 
// command port
//    input                 [35:0] phy_cmd,
    input                 [31:0] phy_cmd_word,
    output                       phy_cmd_nop,
    output  [CMD_PAUSE_BITS-1:0] pause_len,
    output                       sequence_done,
// external memory buffer (cs- channel select, high addresses- page addresses are decoded externally)
//    output                [ 6:0] buf_addr,
    output                [63:0] buf_wdata, // data to be written to the buffer (from DDR3), valid @ negedge mclk
    input                 [63:0] buf_rdata, // data read from the buffer (to DDR3)
    output                       buf_wr,    // write buffer (next cycle!)
    output                       buf_rd,     // read buffer  (ready next cycle)
    // extras
    input                        cmda_tri, // tristate command and address lines // not likely to be used
    input                        inv_clk_div,
    input                 [7:0]  dqs_pattern, // 8'h55
    input                 [7:0]  dqm_pattern  // 8'h00
);
    localparam DQSTRI_FIRST=    4'h3; // DQS tri-state control word, first when enabling output 
    localparam DQSTRI_LAST=     4'hc; // DQS tri-state control word, first after disabling output
    localparam DQTRI_FIRST=     4'h7; // DQ tri-state control word, first when enabling output 
    localparam DQTRI_LAST=      4'he;  // DQ tri-state control word, first after disabling output

// Decoding phy_cmd[35:0] into individual fields;
    wire    [ADDRESS_NUMBER-1:0] phy_addr_in;  // also provides pause length when the command is NOP
    wire                  [ 2:0] phy_bank_in;
    wire                  [ 2:0] phy_rcw_in; // {ras,cas,we}
    wire                         phy_odt_in; // may be optimized?
    wire                         phy_cke_in; // may be optimized?
    wire                         phy_sel_in; // fitst/second half-cycle, oter will be nop (cke+odt applicable to both)
    wire                         phy_dq_tri_in;   // tristate DQ  lines (internal timing sequencer for 0->1 and 1->0)
    wire                         phy_dqs_tri_in;  // tristate DQS lines (internal timing sequencer for 0->1 and 1->0)
    wire                         phy_dci_in;      // DCI disable, both DQ and DQS lines (internal logic and timing sequencer for 0->1 and 1->0)
//    wire                  [ 6:0] phy_buf_addr; // connect to extrenal buffer
    wire                         phy_buf_wr;   // connect to extrenal buffer
    wire                         phy_buf_rd;   // connect to extrenal buffer
    
//    wire                         clk;
    wire                         clk_div;

    reg                    [7:0] dly_data_r; // delay value (3 LSB - fine delay)
    reg                    [6:0] dly_addr_r; // select which delay to program
    reg                          ld_delay_r; // load delay data to selected iodelayl (clk_div synchronous)
    reg                          set_r;       // clk_div synchronous set all delays from previously loaded values

    wire  [2*ADDRESS_NUMBER-1:0] phy_addr;  // also provides pause length when the command is NOP
    wire                  [ 5:0] phy_bank;
    wire                  [ 5:0] phy_rcw; // {ras,cas,we}
    wire                   [1:0] phy_odt; // may be optimized?
    wire                   [1:0] phy_cke; // may be optimized?
    wire                   [7:0] phy_dq_tri;   // tristate DQ  lines (internal timing sequencer for 0->1 and 1->0)
    wire                   [7:0] phy_dqs_tri;  // tristate DQS lines (internal timing sequencer for 0->1 and 1->0)
    wire                         phy_dci_dis_dq; 
    wire                         phy_dci_dis_dqs;
        
    reg                          dqs_tri_prev, dq_tri_prev;
    wire                         phy_locked;
    wire                         phy_ps_rdy;
    wire       [PHASE_WIDTH-1:0] phy_ps_out; 
    reg                          locked_r1,locked_r2;
    reg                          ps_rdy_r1,ps_rdy_r2;
    reg        [PHASE_WIDTH-1:0] ps_out_r1,ps_out_r2; 
    wire                  [63:0] phy_rdata; // data read from ddr3 iserdese2 at posedge clk_div
    reg                   [63:0] phy_rdata_r; // registered @ posedge mclk
//    output                [63:0] buf_wdata, // data to be written to the buffer (from DDR3)
    // SuppressWarnings VEditor 
  (* keep = "true" *)  wire  [2:0] phy_spare;
    assign {
        phy_addr_in,
        phy_bank_in,
        phy_rcw_in,      // {ras,cas,we}
        phy_odt_in,      // may be optimized?
        phy_cke_in,      // may be optimized?
        phy_sel_in,      // fitst/second half-cycle, oter will be nop (cke+odt applicable to both)
        phy_dq_tri_in,   // tristate DQ  lines (internal timing sequencer for 0->1 and 1->0)
        phy_dqs_tri_in,  // tristate DQS lines (internal timing sequencer for 0->1 and 1->0)
        phy_dci_in,      // DCI disable, both DQ and DQS lines (internal logic and timing sequencer for 0->1 and 1->0)
//        phy_buf_addr, // connect to external buffer (is it needed? maybe just autoincrement?)
        phy_buf_wr,   // connect to external buffer (but only if not paused)
        phy_buf_rd,    // connect to external buffer (but only if not paused)
        phy_spare      // Reserved for future use
    } = phy_cmd_word;
    assign phy_cmd_nop=   (phy_rcw_in==0);
    assign sequence_done= (phy_rcw_in==0) && phy_addr_in[CMD_DONE_BIT];
    assign pause_len=      phy_addr_in[CMD_PAUSE_BITS-1:0];
    
//    assign buf_addr = phy_buf_addr;
    assign buf_wr =   phy_buf_wr;
    assign buf_rd =   phy_buf_rd;
    
    assign  phy_addr=   {phy_addr_in,phy_addr_in};       // also provides pause length when the command is NOP
    assign  phy_bank=   {phy_bank_in,phy_bank_in};
    assign  phy_rcw=    {phy_sel_in?phy_rcw_in:3'h0, phy_sel_in?3'h0:phy_rcw_in}; // {ras,cas,we}
    assign  phy_odt=    {phy_odt_in,phy_odt_in};         // may be optimized?
    assign  phy_cke=    {phy_cke_in,phy_cke_in};         // may be optimized?
    
    // tristate DQ  lines (internal timing sequencer for 0->1 and 1->0)
    assign  phy_dq_tri= (dq_tri_prev==phy_dq_tri_in)?{{8{phy_dq_tri_in}}}:
                          (dq_tri_prev?{DQTRI_FIRST,DQTRI_FIRST}:{DQTRI_LAST,DQTRI_LAST});
    // tristate DQS  lines (internal timing sequencer for 0->1 and 1->0)
    assign  phy_dqs_tri= (dqs_tri_prev==phy_dqs_tri_in)?{{8{phy_dqs_tri_in}}}:
                          (dqs_tri_prev?{DQSTRI_FIRST,DQSTRI_FIRST}:{DQSTRI_LAST,DQSTRI_LAST});
    assign  phy_dci_dis_dq =   phy_dci_in;         // DCI disable, both DQ and DQS lines (internal logic and timing sequencer for 0->1 and 1->0)
    assign  phy_dci_dis_dqs =  phy_dci_in;        // DCI disable, both DQ and DQS lines (internal logic and timing sequencer for 0->1 and 1->0)
    
    assign  locked = locked_r2;
    assign  ps_rdy = ps_rdy_r2;
    assign  ps_out = ps_out_r2;
    
    assign buf_wdata[63:0] = phy_rdata_r[63:0];
    
    always @ (posedge mclk) begin
        dqs_tri_prev <= phy_dqs_tri_in;
        dq_tri_prev  <= phy_dq_tri_in;
    end 
    
// cross clock boundary posedge mclk -> posedge clk_div (mclk is later than clk_div)    
    always @ (posedge clk_div or posedge rst_in) begin
        if (rst_in) begin
            dly_data_r <= 0;
            dly_addr_r <= 0;
            ld_delay_r <= 0;
            set_r      <= 0;
        end else begin
            dly_data_r <= dly_data;
            dly_addr_r <= dly_addr;
            ld_delay_r <= ld_delay;
            set_r      <= set;
        end
    end
    
    
// cross clock boundary posedge posedge clk_div->negedge clk_div -> posedge mclk  (mclk is later than clk_div)    
    always @ (negedge clk_div) begin
        locked_r1 <=   phy_locked;
        ps_rdy_r1 <=   phy_ps_rdy;
        ps_out_r1 <=   phy_ps_out; 
    end
    always @ (posedge mclk) begin
        locked_r2 <=   locked_r1;
        ps_rdy_r2 <=   ps_rdy_r1;
        ps_out_r2 <=   ps_out_r1; 
    end


    always @ (negedge mclk) begin
        phy_rdata_r[63:0] <= phy_rdata[63:0];
    end


/*
phy_rdata

    wire                         phy_locked;
    wire                         phy_ps_rdy;
    wire       [PHASE_WIDTH-1:0] phy_ps_out; 


    output                       locked,
    output                       ps_rdy,
    output     [PHASE_WIDTH-1:0] ps_out, 

*/


    phy_top #(
        .IOSTANDARD_DQ      ("SSTL15_T_DCI"),
        .IOSTANDARD_DQS     ("DIFF_SSTL15_T_DCI"),
        .IOSTANDARD_CMDA    ("SSTL15"),
        .IOSTANDARD_CLK     ("DIFF_SSTL15"),
        .SLEW_DQ          (SLEW_DQ),
        .SLEW_DQS         (SLEW_DQS),
        .SLEW_CMDA        (SLEW_CMDA),
        .SLEW_CLK         (SLEW_CLK),
        .IBUF_LOW_PWR     (IBUF_LOW_PWR),
        .IODELAY_GRP        ("IODELAY_MEMORY"),
        .REFCLK_FREQUENCY (REFCLK_FREQUENCY),
        .HIGH_PERFORMANCE_MODE(HIGH_PERFORMANCE_MODE),
        .ADDRESS_NUMBER   (ADDRESS_NUMBER),
        .PHASE_WIDTH        (8),
        .BANDWIDTH        ("OPTIMIZED"),
        .CLKIN_PERIOD     (CLKIN_PERIOD),
        .CLKFBOUT_MULT    (CLKFBOUT_MULT),
        .CLKFBOUT_MULT_REF(CLKFBOUT_MULT_REF),
        .CLKFBOUT_DIV_REF (CLKFBOUT_DIV_REF),
        .DIVCLK_DIVIDE    (DIVCLK_DIVIDE),
        .CLKFBOUT_PHASE   (CLKFBOUT_PHASE),
        .ICLK_PHASE       (ICLK_PHASE),
        .CLK_PHASE        (CLK_PHASE),
        .CLK_DIV_PHASE    (CLK_DIV_PHASE),
        .MCLK_PHASE       (MCLK_PHASE),
        .REF_JITTER1         (REF_JITTER1),
        .SS_EN            (SS_EN),
        .SS_MODE          (SS_MODE),
        .SS_MOD_PERIOD    (SS_MOD_PERIOD)
    ) phy_top_i (
        .ddr3_clk        (SDCLK), // output
        .ddr3_nclk       (SDNCLK), // output
        .ddr3_a          (SDA[ADDRESS_NUMBER-1:0]), // output[14:0] 
        .ddr3_ba         (SDBA[2:0]), // output[2:0] 
        .ddr3_we         (SDWE), // output
        .ddr3_ras        (SDRAS), // output
        .ddr3_cas        (SDCAS), // output
        .ddr3_cke        (SDCKE), // output
        .ddr3_odt        (SDODT), // output
        .dq              (SDD[15:0]), // inout[15:0] 
        .dml             (SDDML), // inout
        .dqsl            (DQSL), // inout
        .ndqsl           (NDQSL), // inout
        .dmu             (SDDMU), // inout
        .dqsu            (DQSU), // inout
        .ndqsu           (NDQSU), // inout
        .clk_in          (clk_in), // input
//        .clk             (clk), // output
        .clk             (), // output
        .clk_div         (clk_div), // output
        .mclk            (mclk), // output
        .rst_in          (rst_in), // input
        .in_a            (phy_addr[2*ADDRESS_NUMBER-1:0]), // input[29:0] 
        .in_ba           (phy_bank[5:0]), // input[5:0] 
        .in_we           ({phy_rcw[3],phy_rcw[0]}), // input[1:0] 
        .in_ras          ({phy_rcw[5],phy_rcw[2]}), // input[1:0] 
        .in_cas          ({phy_rcw[4],phy_rcw[1]}), // input[1:0] 
        .in_cke          (phy_cke), // input[1:0] 
        .in_odt          (phy_odt), // input[1:0] 
        .in_tri          (cmda_tri), // input
        .din             (buf_rdata[63:0]), // input[63:0] 
        .din_dm          (dqm_pattern[7:0]), // input[7:0] 
        .tin_dq          (phy_dq_tri[7:0]), // input[7:0] 
        .din_dqs         (dqs_pattern[7:0]), // input[7:0] 
        .tin_dqs         (phy_dqs_tri[7:0]), // input[7:0] 
        .dout            (phy_rdata[63:0]), // output[63:0] @posedge clk_div
        .inv_clk_div     (inv_clk_div), // input
        .dci_disable_dqs (phy_dci_dis_dqs), // input
        .dci_disable_dq  (phy_dci_dis_dq), // input
        .dly_data        (dly_data_r), // input[7:0] 
        .dly_addr        (dly_addr_r), // input[6:0] 
        .ld_delay        (ld_delay_r), // input
        .set             (set_r), // input
        .locked          (phy_locked), // output
        .ps_rdy          (phy_ps_rdy), // output
        .ps_out          (phy_ps_out) // output[7:0] 
    );

endmodule
