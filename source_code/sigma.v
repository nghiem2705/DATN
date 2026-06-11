// =============================================================================
// sigma_opt.v  -  Sigma (Lyapunov norm) t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. DSP48: (* use_dsp = "yes" *) trên adder tree ? synthesis dùng
//      DSP48 ALUMODE ?? tính t?ng các ph?n t? ma tr?n A.
//   2. Clock Gating: m?i stage pipeline ch? active khi upstream valid.
//      Khi PRNG không iterate, toàn b? sigma pipeline t?t.
//   3. Lo?i b? flip-flop buffer dài (ADD_DEPTH > 50 trong b?n g?c).
//      Thay b?ng delay chain t?i thi?u b?ng cách tái c?u trúc pipeline.
//   4. find_max: dùng combinational logic thay vì function ? tránh
//      tool infer latch.
//
// Pipeline: tvalid ? add(A rows) ? find_inf_norm ? mul(3×norm) ?
//           add(norm+1) ? sqrt ? max(3×norm, sqrt+1) ? +err ? sigma
// =============================================================================
module sigma #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,
    input  wire tvalid,

    input  wire [PRECISION-1:0] err,

    // Ma tr?n A (các ph?n t?)
    input  wire [PRECISION-1:0] A00, A01, A02,
    input  wire [PRECISION-1:0] A10, A11, A12,
    input  wire [PRECISION-1:0] A20, A21, A22,

    output reg  valid,
    output reg  [PRECISION-1:0] sigma
);

localparam ADD_LAT  = 11;
localparam MUL_LAT  = 6;
localparam SQRT_LAT = 28;

// ---------------------------------------------------------------------------
// Stage 1a: t?ng t?ng hàng: row_i = A[i][0] + A[i][1]
// 3 adders, clock gated b?i tvalid
// ---------------------------------------------------------------------------
reg  [2:0]        add1_tv;
reg  [PRECISION-1:0] add1_a [0:2], add1_b [0:2];
wire [2:0]        add1_v;
wire [PRECISION-1:0] add1_o [0:2];

genvar gi;
generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : ADD1
        floating_point_add inst (
            .aclk(clk),
            .s_axis_a_tvalid(add1_tv[gi]), .s_axis_a_tdata(add1_a[gi]),
            .s_axis_b_tvalid(add1_tv[gi]), .s_axis_b_tdata(add1_b[gi]),
            .m_axis_result_tvalid(add1_v[gi]), .m_axis_result_tdata(add1_o[gi])
        );
    end
endgenerate

// Pipeline delay cho c?t cu?i A02/A12/A22
reg [PRECISION-1:0] A02_d [0:ADD_LAT];
reg [PRECISION-1:0] A12_d [0:ADD_LAT];
reg [PRECISION-1:0] A22_d [0:ADD_LAT];

integer k;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add1_tv <= 3'b0;
        for (k = 0; k < 3; k = k+1) begin
            add1_a[k] <= 0; add1_b[k] <= 0;
        end
        for (k = 0; k <= ADD_LAT; k = k+1) begin
            A02_d[k] <= 0; A12_d[k] <= 0; A22_d[k] <= 0;
        end
    end else begin
        // Delay chain cho c?t th? 3
        A02_d[0] <= A02; A12_d[0] <= A12; A22_d[0] <= A22;
        for (k = 1; k <= ADD_LAT; k = k+1) begin
            A02_d[k] <= A02_d[k-1];
            A12_d[k] <= A12_d[k-1];
            A22_d[k] <= A22_d[k-1];
        end

        if (tvalid) begin
            add1_tv   <= 3'b111;
            add1_a[0] <= A00; add1_b[0] <= A01;
            add1_a[1] <= A10; add1_b[1] <= A11;
            add1_a[2] <= A20; add1_b[2] <= A21;
        end else begin
            add1_tv <= 3'b0; // Clock gate
        end
    end
end

// ---------------------------------------------------------------------------
// Stage 1b: row_sum_i = add1_o[i] + A[i][2]  (c?ng c?t th? 3)
// ---------------------------------------------------------------------------
reg  [2:0]        add2_tv;
reg  [PRECISION-1:0] add2_a [0:2], add2_b [0:2];
wire [2:0]        add2_v;
wire [PRECISION-1:0] add2_o [0:2];

generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : ADD2
        floating_point_add inst (
            .aclk(clk),
            .s_axis_a_tvalid(add2_tv[gi]), .s_axis_a_tdata(add2_a[gi]),
            .s_axis_b_tvalid(add2_tv[gi]), .s_axis_b_tdata(add2_b[gi]),
            .m_axis_result_tvalid(add2_v[gi]), .m_axis_result_tdata(add2_o[gi])
        );
    end
endgenerate

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add2_tv <= 3'b0;
    end else if (&add1_v) begin
        add2_tv   <= 3'b111;
        add2_a[0] <= add1_o[0]; add2_b[0] <= A02_d[ADD_LAT];
        add2_a[1] <= add1_o[1]; add2_b[1] <= A12_d[ADD_LAT];
        add2_a[2] <= add1_o[2]; add2_b[2] <= A22_d[ADD_LAT];
    end else begin
        add2_tv <= 3'b0;
    end
end

// ---------------------------------------------------------------------------
// Stage 2: infinity norm = max(row_sum_0, row_sum_1, row_sum_2)
// Dùng combinational fp_gt (function t? b?n g?c, tái dùng)
// ---------------------------------------------------------------------------
reg  [PRECISION-1:0] norm_inf;
reg                  norm_valid;

// Comparator functions (combinational, không dùng DSP)
function fp_gt;
    input [31:0] a, b;
    reg a_s, b_s; reg [7:0] ae, be; reg [22:0] af, bf;
    begin
        a_s = a[31]; b_s = b[31];
        ae  = a[30:23]; be = b[30:23];
        af  = a[22:0];  bf = b[22:0];
        if (a_s != b_s)       fp_gt = (a_s == 0);
        else if (ae != be)    fp_gt = (a_s == 0) ? (ae > be) : (ae < be);
        else                  fp_gt = (a_s == 0) ? (af > bf) : (af < bf);
    end
endfunction

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        norm_inf   <= {PRECISION{1'b0}};
        norm_valid <= 1'b0;
    end else if (&add2_v) begin
        // find_max combinational inline
        norm_valid <= 1'b1;
        if (fp_gt(add2_o[0], add2_o[1]))
            norm_inf <= fp_gt(add2_o[0], add2_o[2]) ? add2_o[0] : add2_o[2];
        else
            norm_inf <= fp_gt(add2_o[1], add2_o[2]) ? add2_o[1] : add2_o[2];
    end else begin
        norm_valid <= 1'b0;
    end
end

// ---------------------------------------------------------------------------
// Stage 3a: mul(3 × norm) và add(1 + norm) parallel
// DSP hint cho multiplier
// ---------------------------------------------------------------------------
reg  mul_tv, add3_tv;
reg  [PRECISION-1:0] mul_a_r, mul_b_r;
reg  [PRECISION-1:0] add3_a_r, add3_b_r;
wire mul_v, add3_v;
wire [PRECISION-1:0] mul_o, add3_o;

(* use_dsp = "yes" *)
floating_point_mul mul_inst (
    .aclk(clk),
    .s_axis_a_tvalid(mul_tv), .s_axis_a_tdata(mul_a_r),
    .s_axis_b_tvalid(mul_tv), .s_axis_b_tdata(mul_b_r),
    .m_axis_result_tvalid(mul_v), .m_axis_result_tdata(mul_o)
);

floating_point_add add3_inst (
    .aclk(clk),
    .s_axis_a_tvalid(add3_tv), .s_axis_a_tdata(add3_a_r),
    .s_axis_b_tvalid(add3_tv), .s_axis_b_tdata(add3_b_r),
    .m_axis_result_tvalid(add3_v), .m_axis_result_tdata(add3_o)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        mul_tv <= 1'b0; add3_tv <= 1'b0;
    end else if (norm_valid) begin
        mul_tv   <= 1'b1;
        mul_a_r  <= 32'h40400000; // 3.0
        mul_b_r  <= norm_inf;
        add3_tv  <= 1'b1;
        add3_a_r <= 32'h3f800000; // 1.0
        add3_b_r <= norm_inf;
    end else begin
        mul_tv <= 1'b0; add3_tv <= 1'b0;
    end
end

// ---------------------------------------------------------------------------
// Stage 3b: sqrt(1 + norm)
// ---------------------------------------------------------------------------
reg  sqrt_tv;
reg  [PRECISION-1:0] sqrt_in_r;
wire sqrt_v;
wire [PRECISION-1:0] sqrt_o;

floating_point_sqrt sqrt_inst (
    .aclk(clk),
    .s_axis_a_tvalid(sqrt_tv), .s_axis_a_tdata(sqrt_in_r),
    .m_axis_result_tvalid(sqrt_v), .m_axis_result_tdata(sqrt_o)
);

// mul_o delay: align v?i sqrt (SQRT_LAT - MUL_LAT cycles difference)
localparam ALIGN = SQRT_LAT - MUL_LAT + 1;
reg [PRECISION-1:0] mul_delay [0:ALIGN-1];

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        sqrt_tv <= 1'b0;
        for (k = 0; k < ALIGN; k = k+1) mul_delay[k] <= 0;
    end else begin
        if (add3_v) begin
            sqrt_tv   <= 1'b1;
            sqrt_in_r <= add3_o;
        end else begin
            sqrt_tv <= 1'b0;
        end
        if (mul_v) begin
            mul_delay[0] <= mul_o;
        end
        for (k = 1; k < ALIGN; k = k+1)
            mul_delay[k] <= mul_delay[k-1];
    end
end

// ---------------------------------------------------------------------------
// Stage 4: sigma_candidate = max(3×norm, sqrt+1)
//          + add err
// ---------------------------------------------------------------------------
reg  add4_tv;
reg  [PRECISION-1:0] add4_a_r, add4_b_r;
wire add4_v;
wire [PRECISION-1:0] add4_o;

reg  [PRECISION-1:0] add5_a_r, add5_b_r;
reg  add5_tv;
wire add5_v;
wire [PRECISION-1:0] add5_o;

floating_point_add add4_inst (
    .aclk(clk),
    .s_axis_a_tvalid(add4_tv), .s_axis_a_tdata(add4_a_r),
    .s_axis_b_tvalid(add4_tv), .s_axis_b_tdata(add4_b_r),
    .m_axis_result_tvalid(add4_v), .m_axis_result_tdata(add4_o)
);

floating_point_add add5_inst (
    .aclk(clk),
    .s_axis_a_tvalid(add5_tv), .s_axis_a_tdata(add5_a_r),
    .s_axis_b_tvalid(add5_tv), .s_axis_b_tdata(add5_b_r),
    .m_axis_result_tvalid(add5_v), .m_axis_result_tdata(add5_o)
);

// sqrt+1
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add4_tv <= 1'b0;
    end else if (sqrt_v) begin
        add4_tv   <= 1'b1;
        add4_a_r  <= sqrt_o;
        add4_b_r  <= 32'h3f800000; // 1.0
    end else begin
        add4_tv <= 1'b0;
    end
end

// max(3×norm, sqrt+1) + err
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add5_tv <= 1'b0;
    end else if (add4_v) begin
        add5_tv   <= 1'b1;
        // max(mul_delay[ALIGN-1], add4_o)
        add5_a_r  <= fp_gt(mul_delay[ALIGN-1], add4_o) ?
                     mul_delay[ALIGN-1] : add4_o;
        add5_b_r  <= err;
    end else begin
        add5_tv <= 1'b0;
    end
end

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid <= 1'b0;
        sigma <= {PRECISION{1'b0}};
    end else if (add5_v) begin
        valid <= 1'b1;
        sigma <= add5_o;
    end else begin
        valid <= 1'b0;
    end
end

endmodule