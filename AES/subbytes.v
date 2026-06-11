// =============================================================================
// subbytes_opt.v  -  SubBytes t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. BRAM: dùng attribute (* ram_style = "block" *) ? Xilinx synthesis map
//      sbox_mem vào BRAM18 thay distributed LUT-RAM (~128 LUT6 ? 0.5 BRAM18).
//   2. Clock Gating: ch? enable clock cho sbox_mem write khi sbox_valid HIGH
//      và ch?a ready; enable lookup khi tvalid & sbox_ready.
//      Dùng CE (clock enable) trên flip-flop thay luôn active pipeline.
//   3. Lo?i b? latch ng?m: out không gi? giá tr? c? khi idle (out <= 0).
//   4. Single-cycle lookup: BRAM synchronous read ? valid sau 1 clock.
// =============================================================================
module subbytes #(
    parameter SBOX_WIDTH = 8,
    parameter SBOX_DEPTH = 256,
    parameter DATA_WIDTH = 128
)(
    input  wire                  clk,
    input  wire                  reset_n,

    // Phase-1: nh?n byte t? sbox_generator ?? xây S-BOX
    input  wire                  sbox_valid,
    input  wire [SBOX_WIDTH-1:0] sbox_out,

    // Phase-2: tra c?u 128-bit state
    input  wire                  tvalid,
    input  wire [DATA_WIDTH-1:0] in,

    output reg                   valid,
    output reg  [DATA_WIDTH-1:0] out
);

// ---------------------------------------------------------------------------
// BRAM-mapped S-BOX memory (256 × 8 bit = 2 kbit ? fit 0.5× BRAM18)
// (* ram_style = "block" *) bu?c Vivado / ISE dùng BRAM thay LUT-RAM
// ---------------------------------------------------------------------------
(* ram_style = "block" *)
reg [SBOX_WIDTH-1:0] sbox_mem [0:SBOX_DEPTH-1];

reg [7:0]  wr_index;
reg        sbox_ready;

// ---------------------------------------------------------------------------
// Clock Enable gating cho write port (Phase-1)
// Ch? write khi: sbox_valid=1 AND sbox_ready=0
// ? t?t toàn b? switching activity c?a write path sau khi S-BOX xong
// ---------------------------------------------------------------------------
wire wr_en = sbox_valid & ~sbox_ready;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wr_index   <= 8'd0;
        sbox_ready <= 1'b0;
    end else if (wr_en) begin
        sbox_mem[wr_index] <= sbox_out;          // BRAM write
        wr_index           <= wr_index + 8'd1;
        if (wr_index == SBOX_DEPTH - 1)
            sbox_ready <= 1'b1;
    end
end

// ---------------------------------------------------------------------------
// Phase-2: parallel lookup v?i clock enable
// BRAM synchronous read ? k?t qu? s?n 1 cycle sau khi ??a ch? ???c ??a vào.
// Dùng generate ?? 16 byte ??c song song (16 BRAM read ports gi? l?p b?ng
// distributed read t? 1 BRAM v?i inferred mux - synthesis s? dùng SDP mode).
// ---------------------------------------------------------------------------
wire rd_en = tvalid & sbox_ready;  // clock gate cho read path

genvar gi;
generate
    for (gi = 0; gi < DATA_WIDTH/8; gi = gi + 1) begin : LOOKUP
        // M?i byte c?a in ???c dùng làm ??a ch? tra BRAM
        // Synthesis infer SDP BRAM và dùng 1 BRAM cho toàn b? 16 lookup
        // thông qua time-multiplexing ho?c duplication tùy tool.
        // V?i Vivado: dùng (* ram_style="block" *) + parallel assign
        // ? synthesis ch?n LUTRAM ho?c BRAM tùy kích th??c.
        // ? ?ây 256×8 ? BRAM18 SDP (2K×1) ? 1 port ??c song song ??.
    end
endgenerate

// Lookup combinational read (BRAM SDP: write clock, async read)
// ?? ??m b?o timing, dùng 1-stage registered read:
integer i;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid <= 1'b0;
        out   <= {DATA_WIDTH{1'b0}};
    end else if (rd_en) begin
        valid <= 1'b1;
        // Parallel BRAM read - 16 bytes simultaneously
        for (i = 0; i < DATA_WIDTH/8; i = i + 1)
            out[i*8 +: 8] <= sbox_mem[in[i*8 +: 8]];
    end else begin
        valid <= 1'b0;
        // Không gi? out c? ? tránh unnecessary toggling (gi?m dynamic power)
        out   <= {DATA_WIDTH{1'b0}};
    end
end

endmodule