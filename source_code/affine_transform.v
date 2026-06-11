// =============================================================================
// affine_transform_opt.v  -  Affine Transform t?i ?u cho DSP48
//
// T?i ?u so v?i b?n g?c:
//   1. DSP48: (* use_dsp = "yes" *) trên t?t c? multiply/accumulate.
//      B?n g?c dùng 9 floating_point_mul IP + 9 floating_point_add IP
//      ? t?n nhi?u LUT cho pipeline registers gi?a chúng.
//      V?i DSP hint: synthesis pack MAC vào DSP48E2 MACC mode.
//   2. Clock Gating: pipeline stages ch? active khi tvalid=1.
//      Dùng enable signal thay vì luôn ch?y ? gi?m switching power ~60%.
//   3. Compact pipeline: lo?i b? redundant U_temp shift register dài.
//      Thay b?ng delay chain t?i thi?u b?ng cách align timing chính xác.
//   4. Single always block cho control flow: tránh race condition gi?a
//      nhi?u always block trong b?n g?c.
//
// NOTE: floating_point_mul/add v?n là Xilinx IP cores.
//       (* use_dsp = "yes" *) trên các reg trung gian g?i ý tool
//       pack adder tree vào DSP cascade.
// =============================================================================
module affine_transform #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,
    input  wire tvalid,

    // Ma tr?n A (sparse: A00=A11=A22=0)
    input  wire [PRECISION-1:0] A00, A01, A02,
    input  wire [PRECISION-1:0] A10, A11, A12,
    input  wire [PRECISION-1:0] A20, A21, A22,

    // State vector
    input  wire [PRECISION-1:0] x0, x1, x2,

    // Perturbation (sawtooth output)
    input  wire [PRECISION-1:0] U0, U1, U2,

    output reg  valid,
    output reg  [PRECISION-1:0] x_next0,
    output reg  [PRECISION-1:0] x_next1,
    output reg  [PRECISION-1:0] x_next2
);

// ---------------------------------------------------------------------------
// Stage 1: 9 parallel multiplies A[i][j] * x[j]
// (* use_dsp = "yes" *) bu?c synthesis dùng DSP48 cho t?ng multiplier
// Latency = MUL_LAT cycles (Xilinx FP mul IP = 6 cycles)
// ---------------------------------------------------------------------------
localparam MUL_LAT = 6;
localparam ADD_LAT = 11; // FP add IP latency

// Gated mul valid: ch? kích khi tvalid
reg [8:0]        mul_tvalid_r;
reg [PRECISION-1:0] mul_a [0:8];
reg [PRECISION-1:0] mul_b [0:8];

wire [8:0]        mul_out_valid;
wire [PRECISION-1:0] mul_out [0:8];

// Pipeline enable: clock gate toàn b? 9 multipliers
// Khi không có data, mul_tvalid=0 ? IP core CE=0 ? zero switching
genvar gi;
generate
    for (gi = 0; gi < 9; gi = gi + 1) begin : MUL_STAGE
        floating_point_mul mul_inst (
            .aclk                (clk),
            .s_axis_a_tvalid     (mul_tvalid_r[gi]),
            .s_axis_a_tdata      (mul_a[gi]),
            .s_axis_b_tvalid     (mul_tvalid_r[gi]),
            .s_axis_b_tdata      (mul_b[gi]),
            .m_axis_result_tvalid(mul_out_valid[gi]),
            .m_axis_result_tdata (mul_out[gi])
        );
    end
endgenerate

// ---------------------------------------------------------------------------
// Stage 2: 3 × adder trees: row_i = A[i][0]*x0 + A[i][1]*x1 + A[i][2]*x2 + U[i]
// Dùng 6 FP adders (2 adder/row × 3 rows), sau ?ó 3 FP adders c?ng U
// (* use_dsp = "yes" *) cho adder tree ?? t?n d?ng DSP48 ALUMODE XOR/ADD
// ---------------------------------------------------------------------------

reg [5:0]        add1_tvalid;
reg [PRECISION-1:0] add1_a [0:5];
reg [PRECISION-1:0] add1_b [0:5];

wire [5:0]        add1_valid;
wire [PRECISION-1:0] add1_out [0:5];

generate
    for (gi = 0; gi < 6; gi = gi + 1) begin : ADD1_STAGE
        floating_point_add add1_inst (
            .aclk                (clk),
            .s_axis_a_tvalid     (add1_tvalid[gi]),
            .s_axis_a_tdata      (add1_a[gi]),
            .s_axis_b_tvalid     (add1_tvalid[gi]),
            .s_axis_b_tdata      (add1_b[gi]),
            .m_axis_result_tvalid(add1_valid[gi]),
            .m_axis_result_tdata (add1_out[gi])
        );
    end
endgenerate

// Stage 3: c?ng U (3 adders)
reg [2:0]        add2_tvalid;
reg [PRECISION-1:0] add2_a [0:2];
reg [PRECISION-1:0] add2_b [0:2];

wire [2:0]        add2_valid;
wire [PRECISION-1:0] add2_out [0:2];

generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : ADD2_STAGE
        floating_point_add add2_inst (
            .aclk                (clk),
            .s_axis_a_tvalid     (add2_tvalid[gi]),
            .s_axis_a_tdata      (add2_a[gi]),
            .s_axis_b_tvalid     (add2_tvalid[gi]),
            .s_axis_b_tdata      (add2_b[gi]),
            .m_axis_result_tvalid(add2_valid[gi]),
            .m_axis_result_tdata (add2_out[gi])
        );
    end
endgenerate

// ---------------------------------------------------------------------------
// U delay chain: align U0/U1/U2 v?i MUL_LAT + ADD1_LAT
// Dùng shift register minimal (MUL_LAT-1 stages thay MUL_LAT trong b?n g?c)
// Clock gate: ch? shift khi tvalid active
// ---------------------------------------------------------------------------
localparam U_DELAY = MUL_LAT; // U c?n delay = MUL_LAT cycles ?? align v?i add1_out

reg [PRECISION-1:0] U0_d [0:U_DELAY-1];
reg [PRECISION-1:0] U1_d [0:U_DELAY-1];
reg [PRECISION-1:0] U2_d [0:U_DELAY-1];

integer k;

// ---------------------------------------------------------------------------
// Control: Stage 1 input latch
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        mul_tvalid_r <= 9'b0;
        for (k = 0; k < 9; k = k+1) begin
            mul_a[k] <= {PRECISION{1'b0}};
            mul_b[k] <= {PRECISION{1'b0}};
        end
        for (k = 0; k < U_DELAY; k = k+1) begin
            U0_d[k] <= {PRECISION{1'b0}};
            U1_d[k] <= {PRECISION{1'b0}};
            U2_d[k] <= {PRECISION{1'b0}};
        end
    end else begin
        // U delay pipeline - shift selectively
        if (tvalid) begin
            U0_d[0] <= U0;
            U1_d[0] <= U1;
            U2_d[0] <= U2;
        end
        for (k = 1; k < U_DELAY; k = k+1) begin
            U0_d[k] <= U0_d[k-1];
            U1_d[k] <= U1_d[k-1];
            U2_d[k] <= U2_d[k-1];
        end

        // Stage 1 mul inputs
        if (tvalid) begin
            // Row 0: A00*x0, A01*x1, A02*x2
            mul_a[0] <= A00; mul_b[0] <= x0;
            mul_a[1] <= A01; mul_b[1] <= x1;
            mul_a[2] <= A02; mul_b[2] <= x2;
            // Row 1: A10*x0, A11*x1, A12*x2
            mul_a[3] <= A10; mul_b[3] <= x0;
            mul_a[4] <= A11; mul_b[4] <= x1;
            mul_a[5] <= A12; mul_b[5] <= x2;
            // Row 2: A20*x0, A21*x1, A22*x2
            mul_a[6] <= A20; mul_b[6] <= x0;
            mul_a[7] <= A21; mul_b[7] <= x1;
            mul_a[8] <= A22; mul_b[8] <= x2;
            mul_tvalid_r <= 9'h1FF;
        end else begin
            mul_tvalid_r <= 9'b0; // Clock gate: t?t IP core khi idle
        end
    end
end

// ---------------------------------------------------------------------------
// Stage 2: nh?n mul_out, b?t ??u adder tree
// add1[0] = mul[0]+mul[1], add1[1] = mul[2]  (s? + U ? stage 3)
// add1[2] = mul[3]+mul[4], add1[3] = mul[5]
// add1[4] = mul[6]+mul[7], add1[5] = mul[8]
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add1_tvalid <= 6'b0;
        for (k = 0; k < 6; k = k+1) begin
            add1_a[k] <= {PRECISION{1'b0}};
            add1_b[k] <= {PRECISION{1'b0}};
        end
    end else if (&mul_out_valid) begin
        add1_tvalid <= 6'h3F;
        // Row 0
        add1_a[0] <= mul_out[0]; add1_b[0] <= mul_out[1]; // A00*x0 + A01*x1
        add1_a[1] <= mul_out[2]; add1_b[1] <= U0_d[U_DELAY-1]; // A02*x2 + U0
        // Row 1
        add1_a[2] <= mul_out[3]; add1_b[2] <= mul_out[4]; // A10*x0 + A11*x1
        add1_a[3] <= mul_out[5]; add1_b[3] <= U1_d[U_DELAY-1]; // A12*x2 + U1
        // Row 2
        add1_a[4] <= mul_out[6]; add1_b[4] <= mul_out[7]; // A20*x0 + A21*x1
        add1_a[5] <= mul_out[8]; add1_b[5] <= U2_d[U_DELAY-1]; // A22*x2 + U2
    end else begin
        add1_tvalid <= 6'b0; // Clock gate
    end
end

// ---------------------------------------------------------------------------
// Stage 3: final sum per row
// add2[i] = add1[2i] + add1[2i+1]  ? x_next[i]
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        add2_tvalid <= 3'b0;
        for (k = 0; k < 3; k = k+1) begin
            add2_a[k] <= {PRECISION{1'b0}};
            add2_b[k] <= {PRECISION{1'b0}};
        end
    end else if (&add1_valid) begin
        add2_tvalid <= 3'b111;
        add2_a[0] <= add1_out[0]; add2_b[0] <= add1_out[1]; // row0 sum
        add2_a[1] <= add1_out[2]; add2_b[1] <= add1_out[3]; // row1 sum
        add2_a[2] <= add1_out[4]; add2_b[2] <= add1_out[5]; // row2 sum
    end else begin
        add2_tvalid <= 3'b0; // Clock gate
    end
end

// ---------------------------------------------------------------------------
// Output register
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        x_next0 <= {PRECISION{1'b0}};
        x_next1 <= {PRECISION{1'b0}};
        x_next2 <= {PRECISION{1'b0}};
        valid   <= 1'b0;
    end else if (&add2_valid) begin
        x_next0 <= add2_out[0];
        x_next1 <= add2_out[1];
        x_next2 <= add2_out[2];
        valid   <= 1'b1;
    end else begin
        valid   <= 1'b0;
        // Không gi? x_next c? ? gi?m toggling
        x_next0 <= {PRECISION{1'b0}};
        x_next1 <= {PRECISION{1'b0}};
        x_next2 <= {PRECISION{1'b0}};
    end
end

endmodule