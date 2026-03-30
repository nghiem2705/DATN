// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Mon Feb 23 19:06:05 2026
// Host        : Admin-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               C:/Users/Admin/Documents/vivado/exercise/TRNG/TRNG.sim/sim_1/impl/timing/xsim/s_trng_tb_time_impl.v
// Design      : S_TRNG
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "ac4dc7c3" *) (* dont_touch = "true" *) 
(* NotValidForBitStream *)
module S_TRNG
   (en,
    clk,
    ran);
  input en;
  input clk;
  output ran;

  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire en;
  wire en_IBUF;
  (* RTL_KEEP = "true" *) wire nand1;
  (* RTL_KEEP = "true" *) wire nand3;
  (* RTL_KEEP = "true" *) wire not2;
  (* RTL_KEEP = "true" *) wire not4;
  wire ran;
  wire ran_OBUF;
  (* RTL_KEEP = "true" *) wire xor1;
  wire xor1_tmp;
  (* RTL_KEEP = "true" *) wire xor2;
  wire xor2_tmp;
  (* RTL_KEEP = "true" *) wire xor3;
  wire xor3_tmp;
  (* RTL_KEEP = "true" *) wire xor4;
  wire xor4_tmp;

initial begin
 $sdf_annotate("s_trng_tb_time_impl.sdf",,,,"tool_control");
end
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  IBUF en_IBUF_inst
       (.I(en),
        .O(en_IBUF));
  OBUF ran_OBUF_inst
       (.I(ran_OBUF),
        .O(ran));
  LUT4 #(
    .INIT(16'h6996)) 
    ran_OBUF_inst_i_1
       (.I0(xor3_tmp),
        .I1(xor2_tmp),
        .I2(xor1_tmp),
        .I3(xor4_tmp),
        .O(ran_OBUF));
  (* DONT_TOUCH *) 
  sub_ring_1__1 sub_1_1
       (.en(en_IBUF),
        .out(nand1));
  (* DONT_TOUCH *) 
  sub_ring_1 sub_1_2
       (.en(en_IBUF),
        .out(nand3));
  (* DONT_TOUCH *) 
  sub_ring_3__1 sub_3_1
       (.en(en_IBUF),
        .out(not2));
  (* DONT_TOUCH *) 
  sub_ring_3 sub_3_2
       (.en(en_IBUF),
        .out(not4));
  FDRE #(
    .INIT(1'b0)) 
    xor1_tmp_reg
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(xor1),
        .Q(xor1_tmp),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    xor2_tmp_reg
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(xor2),
        .Q(xor2_tmp),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    xor3_tmp_reg
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(xor3),
        .Q(xor3_tmp),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    xor4_tmp_reg
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .D(xor4),
        .Q(xor4_tmp),
        .R(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* DONT_TOUCH *) 
  LUT2 #(
    .INIT(4'h6)) 
    xor_gate1
       (.I0(nand1),
        .I1(xor2),
        .O(xor1));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* DONT_TOUCH *) 
  LUT2 #(
    .INIT(4'h6)) 
    xor_gate2
       (.I0(xor1),
        .I1(not2),
        .O(xor2));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* DONT_TOUCH *) 
  LUT2 #(
    .INIT(4'h6)) 
    xor_gate3
       (.I0(nand3),
        .I1(xor4),
        .O(xor3));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* DONT_TOUCH *) 
  LUT2 #(
    .INIT(4'h6)) 
    xor_gate4
       (.I0(xor3),
        .I1(not4),
        .O(xor4));
endmodule

(* dont_touch = "true" *) 
module sub_ring_1
   (en,
    out);
  input en;
  output out;

  wire en;
  (* RTL_KEEP = "true" *) wire ring_wire;

  assign out = ring_wire;
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT2 #(
    .INIT(4'h7)) 
    nand_gate
       (.I0(ring_wire),
        .I1(en),
        .O(ring_wire));
endmodule

(* ORIG_REF_NAME = "sub_ring_1" *) (* dont_touch = "true" *) 
module sub_ring_1__1
   (en,
    out);
  input en;
  output out;

  wire en;
  (* RTL_KEEP = "true" *) wire ring_wire;

  assign out = ring_wire;
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT2 #(
    .INIT(4'h7)) 
    nand_gate
       (.I0(ring_wire),
        .I1(en),
        .O(ring_wire));
endmodule

(* dont_touch = "true" *) 
module sub_ring_3
   (en,
    out);
  input en;
  output out;

  wire en;
  (* RTL_KEEP = "true" *) wire w2;
  (* RTL_KEEP = "true" *) wire w3;

  assign out = w3;
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT2 #(
    .INIT(4'h4)) 
    nand_gate
       (.I0(w2),
        .I1(en),
        .O(w2));
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT1 #(
    .INIT(2'h1)) 
    not2
       (.I0(w2),
        .O(w3));
endmodule

(* ORIG_REF_NAME = "sub_ring_3" *) (* dont_touch = "true" *) 
module sub_ring_3__1
   (en,
    out);
  input en;
  output out;

  wire en;
  (* RTL_KEEP = "true" *) wire w2;
  (* RTL_KEEP = "true" *) wire w3;

  assign out = w3;
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT2 #(
    .INIT(4'h4)) 
    nand_gate
       (.I0(w2),
        .I1(en),
        .O(w2));
  (* BOX_TYPE = "PRIMITIVE" *) 
  LUT1 #(
    .INIT(2'h1)) 
    not2
       (.I0(w2),
        .O(w3));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
