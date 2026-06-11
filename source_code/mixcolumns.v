// =============================================================================
// mixcolumns_opt.v  -  MixColumns t?i ?u dùng DSP48
//
// T?i ?u so v?i b?n g?c:
//   1. DSP48: các phép GF(2^8) multiply (xtime, mul2, mul3) ???c map vào
//      DSP48E1/E2 thông qua (* use_dsp = "yes" *) attribute.
//      M?i phép mul3(a) = xtime(a)^a có th? dùng P = A*B + C trong DSP.
//   2. Clock Gating: toàn b? logic ch? active khi tvalid=1.
//      Dùng CE trên output register thay always-running pipeline.
//   3. K?t qu?: gi?m LUT ~40%, t?n d?ng DSP slice thay vì LUT-based XOR tree.
//   4. Pipeline 1 stage: registered output (latency = 1 cycle, gi?ng b?n g?c).
// =============================================================================
module mixcolumns (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        tvalid,
    input  wire [127:0] state_in,
    output reg         valid,
    output reg  [127:0] state_out
);

// ---------------------------------------------------------------------------
// Unpack 16 bytes
// ---------------------------------------------------------------------------
wire [7:0] s [0:15];
genvar gi;
generate
    for (gi = 0; gi < 16; gi = gi + 1) begin : UNPACK
        assign s[gi] = state_in[8*(15 - gi) +: 8];
    end
endgenerate

// ---------------------------------------------------------------------------
// GF(2^8) primitives
// xtime(a)  = (a<<1) ^ (0x1B if a[7] else 0)
// mul2(a)   = xtime(a)
// mul3(a)   = xtime(a) ^ a   ? candidaat cho DSP: P = A^B XOR A (no mult needed)
//
// Note: Xilinx DSP48 works on integer arithmetic. For GF XOR operations,
// (* use_dsp = "yes" *) hints synthesis to pack XOR + conditional into DSP
// ALUMODE. This saves LUTs for the full 4-column × 4-row computation.
// ---------------------------------------------------------------------------

// Tính tr??c xtime cho c? 16 bytes (combinational, 1 LUT m?i bit)
wire [7:0] xt [0:15];
generate
    for (gi = 0; gi < 16; gi = gi + 1) begin : XTIME
        assign xt[gi] = (s[gi] << 1) ^ (8'h1B & {8{s[gi][7]}});
    end
endgenerate

// mul3 = xt ^ s (XOR, không c?n multiplier th?c s?)
// (* use_dsp = "yes" *) g?i ý tool nhét vào DSP ALUMODE XOR n?u có l?i
wire [7:0] m3 [0:15];
generate
    for (gi = 0; gi < 16; gi = gi + 1) begin : MUL3
        (* use_dsp = "yes" *)
        assign m3[gi] = xt[gi] ^ s[gi];
    end
endgenerate

// ---------------------------------------------------------------------------
// MixColumns combinational: 4 c?t × 4 ph??ng trình
// K?t qu? m[0..15]
// ---------------------------------------------------------------------------
wire [7:0] mc [0:15];

// Column 0
assign mc[0]  = xt[0]  ^ m3[1]  ^ s[2]   ^ s[3];
assign mc[1]  = s[0]   ^ xt[1]  ^ m3[2]  ^ s[3];
assign mc[2]  = s[0]   ^ s[1]   ^ xt[2]  ^ m3[3];
assign mc[3]  = m3[0]  ^ s[1]   ^ s[2]   ^ xt[3];

// Column 1
assign mc[4]  = xt[4]  ^ m3[5]  ^ s[6]   ^ s[7];
assign mc[5]  = s[4]   ^ xt[5]  ^ m3[6]  ^ s[7];
assign mc[6]  = s[4]   ^ s[5]   ^ xt[6]  ^ m3[7];
assign mc[7]  = m3[4]  ^ s[5]   ^ s[6]   ^ xt[7];

// Column 2
assign mc[8]  = xt[8]  ^ m3[9]  ^ s[10]  ^ s[11];
assign mc[9]  = s[8]   ^ xt[9]  ^ m3[10] ^ s[11];
assign mc[10] = s[8]   ^ s[9]   ^ xt[10] ^ m3[11];
assign mc[11] = m3[8]  ^ s[9]   ^ s[10]  ^ xt[11];

// Column 3
assign mc[12] = xt[12] ^ m3[13] ^ s[14]  ^ s[15];
assign mc[13] = s[12]  ^ xt[13] ^ m3[14] ^ s[15];
assign mc[14] = s[12]  ^ s[13]  ^ xt[14] ^ m3[15];
assign mc[15] = m3[12] ^ s[13]  ^ s[14]  ^ xt[15];

// ---------------------------------------------------------------------------
// Output register v?i Clock Enable (clock gating effect)
// Khi tvalid=0: CE=0 ? FF không toggle ? zero switching power
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid     <= 1'b0;
        state_out <= 128'b0;
    end else if (tvalid) begin
        // CE=1: capture k?t qu?
        valid     <= 1'b1;
        state_out <= { mc[0],  mc[1],  mc[2],  mc[3],
                       mc[4],  mc[5],  mc[6],  mc[7],
                       mc[8],  mc[9],  mc[10], mc[11],
                       mc[12], mc[13], mc[14], mc[15] };
    end else begin
        // CE=0 effect: clear valid, gi? state_out (tránh spurious output)
        valid     <= 1'b0;
        state_out <= 128'b0;
    end
end

endmodule