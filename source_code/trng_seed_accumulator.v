module trng_seed_accumulator #(
    parameter PRECISION = 32  // IEEE 754 single
)(
    input  wire clk,
    input  wire reset_n,

    // T? S_TRNG
    input  wire trng_bit,     // 1 bit entropy m?i chu k? clock
    input  wire trng_en,      // HIGH khi TRNG ?ang ch?y (en c?a S_TRNG)

    // ??u ra seed cho PRNG
    output reg  seed_valid,          // HIGH 1 cycle khi 3 seed ?ã s?n sàng
    output reg  [PRECISION-1:0] x0,  // seed cho pseudoRandomNumber1
    output reg  [PRECISION-1:0] x1,  // seed cho pseudoRandomNumber2
    output reg  [PRECISION-1:0] x2   // seed cho pseudoRandomNumber3
);

// ---------------------------------------------------------------------------
// H?ng s? IEEE 754
// Exponent = 8'h7E ? bias 127, th?c = -1 ? 2^(-1) = 0.5
// T?t c? seed ??u là: 0_01111110_xxxxxxxxxxxxxxxxxxxxxxx
// Nên giá tr? float = 0.5 + fraction/2^24 ? [0.5, 1.0)
// ?ây là vùng an toàn cho chaotic map d?ng MRCO
// ---------------------------------------------------------------------------
localparam [7:0]  FIXED_EXP  = 8'h7E;
localparam [31:0] FIXED_SIGN_EXP = {1'b0, FIXED_EXP, 23'h0}; // template

// ---------------------------------------------------------------------------
// FSM states
// ---------------------------------------------------------------------------
localparam S_COLLECT_X0   = 3'd0;  // Thu 23 bit cho fraction c?a x0
localparam S_CHECK_X0     = 3'd1;  // Ki?m tra fraction x0 ? 0
localparam S_COLLECT_X1   = 3'd2;
localparam S_CHECK_X1     = 3'd3;
localparam S_COLLECT_X2   = 3'd4;
localparam S_CHECK_X2     = 3'd5;
localparam S_DONE         = 3'd6;  // Phát seed_valid 1 cycle, r?i quay v? S_COLLECT_X0

reg [2:0] state;

// ---------------------------------------------------------------------------
// Shift registers thu bit entropy (23 bit fraction m?i seed)
// ---------------------------------------------------------------------------
reg [22:0] frac_shift;   // shift register ?ang accumulate
reg [4:0]  bit_cnt;      // ??m s? bit ?ã thu (0..22)

// Fraction ?ã xác nh?n cho t?ng seed
reg [22:0] frac0, frac1, frac2;

// ---------------------------------------------------------------------------
// Hàm ki?m tra fraction h?p l?:
//   ? 0 ? ??m b?o không ph?i 0.5 chính xác
// ---------------------------------------------------------------------------
wire frac_nonzero = (frac_shift != 23'h0);

// ---------------------------------------------------------------------------
// FSM chính
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state      <= S_COLLECT_X0;
        frac_shift <= 23'h0;
        bit_cnt    <= 5'd0;
        frac0      <= 23'h0;
        frac1      <= 23'h0;
        frac2      <= 23'h0;
        seed_valid <= 1'b0;
        x0         <= 32'h0;
        x1         <= 32'h0;
        x2         <= 32'h0;
    end else begin
        seed_valid <= 1'b0; // m?c ??nh

        case (state)

            // ------------------------------------------------------------------
            // Thu 23 bit entropy ? fraction c?a x0
            // ------------------------------------------------------------------
            S_COLLECT_X0: begin
                if (trng_en) begin
                    frac_shift <= {frac_shift[21:0], trng_bit};
                    bit_cnt    <= bit_cnt + 1'b1;
                    if (bit_cnt == 5'd22) begin
                        bit_cnt <= 5'd0;
                        state   <= S_CHECK_X0;
                    end
                end
            end

            // ------------------------------------------------------------------
            // Ki?m tra fraction x0 ? 0
            // N?u = 0: ti?p t?c XOR thêm bit vào frac_shift cho ??n khi ? 0
            // ------------------------------------------------------------------
            S_CHECK_X0: begin
                if (frac_nonzero) begin
                    frac0  <= frac_shift;
                    state  <= S_COLLECT_X1;
                end else begin
                    // fraction toàn 0 ? XOR bit TRNG vào LSB ?? phá zero
                    if (trng_en) begin
                        frac_shift <= {frac_shift[21:0], trng_bit};
                    end
                end
            end

            // ------------------------------------------------------------------
            S_COLLECT_X1: begin
                if (trng_en) begin
                    frac_shift <= {frac_shift[21:0], trng_bit};
                    bit_cnt    <= bit_cnt + 1'b1;
                    if (bit_cnt == 5'd22) begin
                        bit_cnt <= 5'd0;
                        state   <= S_CHECK_X1;
                    end
                end
            end

            S_CHECK_X1: begin
                if (frac_nonzero) begin
                    frac1  <= frac_shift;
                    state  <= S_COLLECT_X2;
                end else begin
                    if (trng_en) begin
                        frac_shift <= {frac_shift[21:0], trng_bit};
                    end
                end
            end

            // ------------------------------------------------------------------
            S_COLLECT_X2: begin
                if (trng_en) begin
                    frac_shift <= {frac_shift[21:0], trng_bit};
                    bit_cnt    <= bit_cnt + 1'b1;
                    if (bit_cnt == 5'd22) begin
                        bit_cnt <= 5'd0;
                        state   <= S_CHECK_X2;
                    end
                end
            end

            S_CHECK_X2: begin
                if (frac_nonzero) begin
                    frac2  <= frac_shift;
                    state  <= S_DONE;
                end else begin
                    if (trng_en) begin
                        frac_shift <= {frac_shift[21:0], trng_bit};
                    end
                end
            end

            // ------------------------------------------------------------------
            // L?p ráp 3 float và phát seed_valid 1 cycle
            // ------------------------------------------------------------------
            S_DONE: begin
                // L?p float: sign=0, exp=0x7E, fraction=fracN
                x0 <= {1'b0, FIXED_EXP, frac0};
                x1 <= {1'b0, FIXED_EXP, frac1};
                x2 <= {1'b0, FIXED_EXP, frac2};
                seed_valid <= 1'b1;

                // Quay l?i thu seed m?i ngay (continuous re-seeding)
                frac_shift <= 23'h0;
                state      <= S_COLLECT_X0;
            end

            default: state <= S_COLLECT_X0;
        endcase
    end
end

endmodule


// =============================================================================
// Module : top_trng_prng_bridge
// K?t n?i S_TRNG ? trng_seed_accumulator ? PRNG
// Thay th? ph?n TRNG_valid + PRNG_tvalid trong top.v
// =============================================================================
module top_trng_prng_bridge #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,
    input  wire start,        // Tín hi?u b?t ??u t? bên ngoài (= tvalid c?)

    // ??u ra cho PRNG (k?t n?i tr?c ti?p vào PRNG module)
    output wire PRNG_tvalid,
    output wire [PRECISION-1:0] prng_x0,
    output wire [PRECISION-1:0] prng_x1,
    output wire [PRECISION-1:0] prng_x2
);

// ---------- S_TRNG ----------
wire trng_ran;
wire trng_en = start; // TRNG ch?y khi h? th?ng b?t ??u

S_TRNG trng_inst (
    .en (trng_en),
    .clk(clk),
    .ran(trng_ran)
);

// ---------- Accumulator ----------
wire seed_valid;
wire [PRECISION-1:0] x0_seed, x1_seed, x2_seed;

trng_seed_accumulator #(.PRECISION(PRECISION)) acc_inst (
    .clk        (clk),
    .reset_n    (reset_n),
    .trng_bit   (trng_ran),
    .trng_en    (trng_en),
    .seed_valid (seed_valid),
    .x0         (x0_seed),
    .x1         (x1_seed),
    .x2         (x2_seed)
);

// ---------- Gi? seed cho PRNG ----------
// PRNG c?n seed ?n ??nh khi tvalid HIGH.
// seed_valid ch? HIGH 1 cycle ? latch l?i.
reg [PRECISION-1:0] x0_latch, x1_latch, x2_latch;
reg prng_ready;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        x0_latch   <= 32'h3dcccccd; // fallback: 0.1 (gi?ng PRNG hardcode c?)
        x1_latch   <= 32'h3c23d70a; // fallback: 0.01
        x2_latch   <= 32'h3d4ccccd; // fallback: 0.05
        prng_ready <= 1'b0;
    end else if (seed_valid) begin
        x0_latch   <= x0_seed;
        x1_latch   <= x1_seed;
        x2_latch   <= x2_seed;
        prng_ready <= 1'b1;
    end
end

// PRNG_tvalid: HIGH 1 cycle khi seed m?i v?a ???c latch
assign PRNG_tvalid = seed_valid & prng_ready;
assign prng_x0     = x0_latch;
assign prng_x1     = x1_latch;
assign prng_x2     = x2_latch;

endmodule