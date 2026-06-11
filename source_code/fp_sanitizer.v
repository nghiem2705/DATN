
module fp_sanitizer #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,
    input  wire in_valid,
    input  wire [PRECISION-1:0] fp_in,
    input  wire [PRECISION-1:0] fallback, 

    output reg  out_valid,
    output reg  [PRECISION-1:0] fp_out,
    output reg  was_invalid       
);

// ---------------------------------------------------------------------------
// IEEE 754 single precision fields
// ---------------------------------------------------------------------------
wire        sign     = fp_in[31];
wire [7:0]  exponent = fp_in[30:23];
wire [22:0] fraction = fp_in[22:0];

// ---------------------------------------------------------------------------
// Phân lo?i
// ---------------------------------------------------------------------------
wire is_nan      = (exponent == 8'hFF) && (fraction != 23'h0);
wire is_inf      = (exponent == 8'hFF) && (fraction == 23'h0);
wire is_denormal = (exponent == 8'h00) && (fraction != 23'h0);
wire is_zero     = (exponent == 8'h00) && (fraction == 23'h0);
wire is_invalid  = is_nan | is_inf | is_denormal | is_zero;


localparam [PRECISION-1:0] CLAMP_MIN = 32'h3F000000; // 0.5
localparam [PRECISION-1:0] CLAMP_MAX = 32'h3F7FFFFF; // ~1.0

wire [30:0] mag_in  = fp_in[30:0];
wire [30:0] mag_min = CLAMP_MIN[30:0];
wire [30:0] mag_max = CLAMP_MAX[30:0];

wire below_min = (mag_in < mag_min);
wire above_max = (mag_in > mag_max);

reg [PRECISION-1:0] candidate;
reg                 candidate_valid;
reg                 flag_invalid;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        candidate       <= {PRECISION{1'b0}};
        candidate_valid <= 1'b0;
        flag_invalid    <= 1'b0;
    end else begin
        candidate_valid <= in_valid;
        if (in_valid) begin
            if (is_nan || is_zero) begin
                // NaN ho?c zero: dùng fallback t? TRNG
                // Fallback ??m b?o h?p l? (?ã qua trng_seed_accumulator)
                candidate    <= fallback;
                flag_invalid <= 1'b1;
            end else if (is_inf) begin
                // Inf: clamp v? CLAMP_MAX, gi? sign
                candidate    <= {sign, CLAMP_MAX[30:0]};
                flag_invalid <= 1'b1;
            end else if (is_denormal) begin
                // Denormal: flush to CLAMP_MIN, gi? sign
                candidate    <= {sign, CLAMP_MIN[30:0]};
                flag_invalid <= 1'b1;
            end else begin
                // Giá tr? bình th??ng, pass through ?? clamp
                candidate    <= fp_in;
                flag_invalid <= 1'b0;
            end
        end else begin
            flag_invalid <= 1'b0;
        end
    end
end

wire        cand_sign = candidate[31];
wire [30:0] cand_mag  = candidate[30:0];
wire        cand_below = (cand_mag < mag_min);
wire        cand_above = (cand_mag > mag_max);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        fp_out      <= {PRECISION{1'b0}};
        out_valid   <= 1'b0;
        was_invalid <= 1'b0;
    end else begin
        out_valid   <= candidate_valid;
        was_invalid <= flag_invalid;
        if (candidate_valid) begin
            if (cand_below)
                fp_out <= {cand_sign, CLAMP_MIN[30:0]};
            else if (cand_above)
                fp_out <= {cand_sign, CLAMP_MAX[30:0]};
            else
                fp_out <= candidate;
        end
    end
end

endmodule


module prng_output_guard #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,

    input  wire in_valid,
    input  wire [PRECISION-1:0] x_in0,
    input  wire [PRECISION-1:0] x_in1,
    input  wire [PRECISION-1:0] x_in2,

    // Fallback: seed g?c t? TRNG (luôn h?p l?)
    input  wire [PRECISION-1:0] seed0,
    input  wire [PRECISION-1:0] seed1,
    input  wire [PRECISION-1:0] seed2,

    output wire out_valid,
    output wire [PRECISION-1:0] x_out0,
    output wire [PRECISION-1:0] x_out1,
    output wire [PRECISION-1:0] x_out2,
    output wire any_invalid       // HIGH n?u b?t k? kênh nào b? sanitize
);

wire valid0, valid1, valid2;
wire inv0, inv1, inv2;

fp_sanitizer #(.PRECISION(PRECISION)) san0 (
    .clk(clk), .reset_n(reset_n),
    .in_valid(in_valid),
    .fp_in(x_in0),
    .fallback(seed0),
    .out_valid(valid0),
    .fp_out(x_out0),
    .was_invalid(inv0)
);

fp_sanitizer #(.PRECISION(PRECISION)) san1 (
    .clk(clk), .reset_n(reset_n),
    .in_valid(in_valid),
    .fp_in(x_in1),
    .fallback(seed1),
    .out_valid(valid1),
    .fp_out(x_out1),
    .was_invalid(inv1)
);

fp_sanitizer #(.PRECISION(PRECISION)) san2 (
    .clk(clk), .reset_n(reset_n),
    .in_valid(in_valid),
    .fp_in(x_in2),
    .fallback(seed2),
    .out_valid(valid2),
    .fp_out(x_out2),
    .was_invalid(inv2)
);

assign out_valid   = valid0 & valid1 & valid2;
assign any_invalid = inv0 | inv1 | inv2;

endmodule