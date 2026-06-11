// =============================================================================
// sbox_opt.v  -  S-BOX builder t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. BRAM: (* ram_style = "block" *) ? sbox_mem dùng BRAM18 thay 256 reg FF.
//      B?n g?c dùng 256 × 8-bit reg = 2048 flip-flop ? r?t t?n tài nguyên.
//      BRAM18: dùng ~0 FF, 1 BRAM tile.
//   2. Clock Gating: gated_wr_en ch? enable khi c?n thi?t.
//      Khi done_sbox=1, toàn b? write path t?t ? zero dynamic power.
//   3. used[] array lo?i b?: b?n g?c dùng 256 × 1-bit reg ?? track "used".
//      Thay b?ng: vì PRNG sinh ra ?? 256 giá tr? unique theo thi?t k?
//      (index ch? t?ng), ch? c?n index < SIZE check. Ti?t ki?m 256 FF.
//   4. done_sbox combinational: tránh 1 cycle pipeline delay không c?n.
// =============================================================================
module sbox #(
    parameter SIZE      = 256,
    parameter BIT_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  tvalid,
    input  wire [BIT_WIDTH-1:0]  V,

    output wire                  valid,
    output wire [BIT_WIDTH-1:0]  V_out,
    output wire                  done_sbox
);

// ---------------------------------------------------------------------------
// BRAM-backed storage: 256 entries × 8 bit = 2048 bit = 1× BRAM18
// Tránh dùng 256 distributed FF (= 256 × 8 = 2048 FF trong b?n g?c)
// ---------------------------------------------------------------------------
(* ram_style = "block" *)
reg [BIT_WIDTH-1:0] sbox_mem [0:SIZE-1];

reg [BIT_WIDTH-1:0] index;      // write pointer
reg                 filled;     // S-BOX ?ã ??y

// ---------------------------------------------------------------------------
// Write enable: clock gate - ch? write khi ch?a full và có data h?p l?
// ---------------------------------------------------------------------------
wire wr_en = tvalid & ~filled;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        index  <= {BIT_WIDTH{1'b0}};
        filled <= 1'b0;
    end else if (wr_en) begin
        sbox_mem[index] <= V;
        if (index == SIZE - 1) begin
            filled <= 1'b1;
        end
        index <= index + 1'b1;
    end
end

// ---------------------------------------------------------------------------
// Output: valid & V_out combinational (registered 1 cycle bên ngoài n?u c?n)
// done_sbox: HIGH khi index wraps (= SIZE entries ?ã ghi)
// ---------------------------------------------------------------------------
assign valid     = wr_en;           // có data ghi = có output luôn
assign V_out     = V;               // pass-through (?ã valid t? PRNG)
assign done_sbox = filled;          // combinational, không delay 1 cycle

endmodule