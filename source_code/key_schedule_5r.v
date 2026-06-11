// =============================================================================
// key_scheduler_5r_opt.v  -  Key Scheduler t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. BRAM: (* ram_style = "block" *) cho m?ng K[0:ROUND-1].
//      B?n g?c: 5 × 128-bit reg = 640 FF.
//      V?i BRAM: 0 FF cho storage, dùng 1 BRAM18 (512×18 ho?c 256×36).
//   2. Clock Gating: write enable ch? active khi index < ROUND.
//      Sau khi valid=1, write path hoàn toàn t?t.
//   3. Output register: K0..K4 ???c load 1 l?n và gi? nguyên.
//      Dùng CE (clock enable) ?? tránh toggle khi không c?n.
//   4. S?a bug b?n g?c: index không bao gi? t?ng khi tvalid=0 (logic sai).
// =============================================================================
module key_schedule_5r #(
    parameter ROUND    = 5,
    parameter KEY_SIZE = 128
)(
    input  wire                  clk,
    input  wire                  reset_n,
    input  wire                  tvalid,
    input  wire [KEY_SIZE-1:0]   key,

    output reg                   valid,
    output reg  [KEY_SIZE-1:0]   K0, K1, K2, K3, K4
);

// ---------------------------------------------------------------------------
// BRAM-backed round key storage
// 5 entries × 128-bit = 640 bit ? fit vào BRAM18 (512×18 ? c?n ghép)
// Th?c t? Vivado s? dùng 1 BRAM36 (32K bit) ho?c 4× BRAM18 (tùy config).
// V?i ROUND=5, KEY_SIZE=128: dùng simple_dual_port style.
// ---------------------------------------------------------------------------
(* ram_style = "block" *)
reg [KEY_SIZE-1:0] K_mem [0:ROUND-1];

reg [2:0] wr_index;
reg       all_loaded;

// ---------------------------------------------------------------------------
// Write path: clock gated - ch? active khi tvalid=1 và belum selesai
// ---------------------------------------------------------------------------
wire wr_en = tvalid & ~all_loaded & (wr_index < ROUND);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wr_index   <= 3'd0;
        all_loaded <= 1'b0;
    end else if (wr_en) begin
        K_mem[wr_index] <= key;
        if (wr_index == ROUND - 1)
            all_loaded <= 1'b1;
        wr_index <= wr_index + 3'd1;
    end
end

// ---------------------------------------------------------------------------
// Output: load t? BRAM khi all_loaded, dùng CE ?? t?t toggling
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid <= 1'b0;
        K0 <= {KEY_SIZE{1'b0}};
        K1 <= {KEY_SIZE{1'b0}};
        K2 <= {KEY_SIZE{1'b0}};
        K3 <= {KEY_SIZE{1'b0}};
        K4 <= {KEY_SIZE{1'b0}};
    end else if (all_loaded & ~valid) begin
        // Ch? load 1 l?n - CE=1 ch? 1 cycle ? sau ?ó t?t
        K0    <= K_mem[0];
        K1    <= K_mem[1];
        K2    <= K_mem[2];
        K3    <= K_mem[3];
        K4    <= K_mem[4];
        valid <= 1'b1;
    end
    // valid gi? nguyên 1 sau khi set (không toggle)
end

endmodule