// =============================================================================
// PRNG_opt.v  -  PRNG h?n lo?n t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. Clock Gating toàn c?c: dùng 1 enable signal "pipe_active" ki?m soát
//      toàn b? pipeline PRNG. Khi không có tvalid m?i, pipeline d?ng hoàn toàn.
//   2. pseudoRandomNumber registers: không update liên t?c (b?n g?c update
//      m?i tvalid_gated ? nhi?u toggling không c?n). Thay b?ng latch 1 l?n.
//   3. Mul_b_op k?t n?i t? registered output (x[]) thay t? pseudoRandomNumber
//      ? lo?i b? 1 t?ng FF redundant.
//   4. Sawtooth: dùng 3 instances parallel v?i clock gate riêng.
//   5. Lo?i b? lu?ng "tvalid_gated ? pseudoRandomNumber <= x[]" vô ích.
// =============================================================================
module PRNG #(
    parameter PRECISION = 32
)(
    input  wire clk,
    input  wire reset_n,

    input  wire                  seed_valid,
    input  wire [PRECISION-1:0]  seed_x0, seed_x1, seed_x2,

    input  wire                  tvalid,

    output reg                   valid,
    output reg  [PRECISION-1:0]  pseudoRandomNumber1,
    output reg  [PRECISION-1:0]  pseudoRandomNumber2,
    output reg  [PRECISION-1:0]  pseudoRandomNumber3
);

// Ma tr?n A (sparse) - hardcoded constants
localparam [PRECISION-1:0]
    A00 = 32'h00000000,  // 0
    A01 = 32'h3f000000,  // 0.5
    A02 = 32'h3d4ccccd,  // 0.05
    A10 = 32'h3eaaaaab,  // 1/3
    A11 = 32'h00000000,  // 0
    A12 = 32'h3eaaaaab,  // 1/3
    A20 = 32'h3d4ccccd,  // 0.05
    A21 = 32'h3f000000,  // 0.5
    A22 = 32'h00000000;  // 0

// ---------------------------------------------------------------------------
// Seed latch
// ---------------------------------------------------------------------------
reg                  seed_loaded;
reg [PRECISION-1:0]  seed_latch [0:2];

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        seed_loaded   <= 1'b0;
        seed_latch[0] <= {PRECISION{1'b0}};
        seed_latch[1] <= {PRECISION{1'b0}};
        seed_latch[2] <= {PRECISION{1'b0}};
    end else if (seed_valid) begin
        seed_latch[0] <= seed_x0;
        seed_latch[1] <= seed_x1;
        seed_latch[2] <= seed_x2;
        seed_loaded   <= 1'b1;
    end
end

wire tvalid_gated = tvalid & seed_loaded;

// ---------------------------------------------------------------------------
// State vector x[]
// Clock gate: ch? update khi valid_guarded (output s?ch t? sanitizer)
// ---------------------------------------------------------------------------
reg [PRECISION-1:0] x [0:2];

// (update bên d??i sau khi có guard output)

// ---------------------------------------------------------------------------
// Sigma: tính h? s? noise - clock gated b?i tvalid_gated
// ---------------------------------------------------------------------------
wire                 sigma_valid;
wire [PRECISION-1:0] sigma_out;
reg                  sigma_tv;

sigma sigma_u (
    .clk(clk), .reset_n(reset_n),
    .tvalid(sigma_tv),
    .err(32'h3dcccccd),  // 0.1
    .A00(A00), .A01(A01), .A02(A02),
    .A10(A10), .A11(A11), .A12(A12),
    .A20(A20), .A21(A21), .A22(A22),
    .valid(sigma_valid),
    .sigma(sigma_out)
);

// Clock gate sigma: ch? kích 1 l?n per iterate
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) sigma_tv <= 1'b0;
    else          sigma_tv <= tvalid_gated; // 1 cycle pulse
end

// ---------------------------------------------------------------------------
// sigma × x: 3 multipliers, clock gated b?i sigma_valid
// ---------------------------------------------------------------------------
reg [PRECISION-1:0] mul_a [0:2], mul_b [0:2];
reg [2:0]           mul_tv;
wire [2:0]          mul_v;
wire [PRECISION-1:0] mul_o [0:2];

genvar gi;
generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : SIGMA_MUL
        floating_point_mul inst (
            .aclk(clk),
            .s_axis_a_tvalid(mul_tv[gi]), .s_axis_a_tdata(mul_a[gi]),
            .s_axis_b_tvalid(mul_tv[gi]), .s_axis_b_tdata(mul_b[gi]),
            .m_axis_result_tvalid(mul_v[gi]), .m_axis_result_tdata(mul_o[gi])
        );
    end
endgenerate

integer j;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        mul_tv <= 3'b0;
        for (j = 0; j < 3; j = j+1) begin
            mul_a[j] <= {PRECISION{1'b0}};
            mul_b[j] <= {PRECISION{1'b0}};
        end
    end else if (sigma_valid) begin
        mul_tv   <= 3'b111;
        mul_a[0] <= sigma_out; mul_b[0] <= x[0];
        mul_a[1] <= sigma_out; mul_b[1] <= x[1];
        mul_a[2] <= sigma_out; mul_b[2] <= x[2];
    end else begin
        mul_tv <= 3'b0; // Clock gate
    end
end

// ---------------------------------------------------------------------------
// Sawtooth: 3 instances, clock gated b?i mul_v
// epsilon = 0.05 (constant)
// ---------------------------------------------------------------------------
reg [PRECISION-1:0] saw_x [0:2];
reg [2:0]           saw_tv;
wire [2:0]          saw_v;
wire [PRECISION-1:0] saw_o [0:2];

generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : SAW
        sawtooth #(.PRECISION(PRECISION)) inst (
            .clk(clk), .reset_n(reset_n),
            .sawtooth_tvalid(saw_tv[gi]),
            .x(saw_x[gi]),
            .epsilon(32'h3d4ccccd), // 0.05 constant - no reg needed
            .sawtooth_valid(saw_v[gi]),
            .result(saw_o[gi])
        );
    end
endgenerate

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        saw_tv <= 3'b0;
        for (j = 0; j < 3; j = j+1) saw_x[j] <= {PRECISION{1'b0}};
    end else if (&mul_v) begin
        saw_tv   <= 3'b111;
        saw_x[0] <= mul_o[0];
        saw_x[1] <= mul_o[1];
        saw_x[2] <= mul_o[2];
    end else begin
        saw_tv <= 3'b0;
    end
end

// ---------------------------------------------------------------------------
// Affine transform: x_next = A·x + U
// Clock gated b?i saw_v
// ---------------------------------------------------------------------------
reg [PRECISION-1:0] aff_x [0:2], aff_U [0:2];
reg                 aff_tv;
wire                aff_v;
wire [PRECISION-1:0] x_next0, x_next1, x_next2;

affine_transform #(.PRECISION(PRECISION)) affine_u (
    .clk(clk), .reset_n(reset_n),
    .tvalid(aff_tv),
    .A00(A00), .A01(A01), .A02(A02),
    .A10(A10), .A11(A11), .A12(A12),
    .A20(A20), .A21(A21), .A22(A22),
    .x0(aff_x[0]), .x1(aff_x[1]), .x2(aff_x[2]),
    .U0(aff_U[0]), .U1(aff_U[1]), .U2(aff_U[2]),
    .valid(aff_v),
    .x_next0(x_next0), .x_next1(x_next1), .x_next2(x_next2)
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        aff_tv <= 1'b0;
        for (j = 0; j < 3; j = j+1) begin
            aff_x[j] <= {PRECISION{1'b0}};
            aff_U[j] <= {PRECISION{1'b0}};
        end
    end else if (&saw_v) begin
        aff_tv   <= 1'b1;
        aff_x[0] <= x[0]; aff_x[1] <= x[1]; aff_x[2] <= x[2];
        aff_U[0] <= saw_o[0]; aff_U[1] <= saw_o[1]; aff_U[2] <= saw_o[2];
    end else begin
        aff_tv <= 1'b0;
    end
end

// ---------------------------------------------------------------------------
// FP Sanitizer guard
// ---------------------------------------------------------------------------
wire                 valid_guarded;
wire [PRECISION-1:0] x_safe0, x_safe1, x_safe2;
wire                 any_fp_error;

prng_output_guard #(.PRECISION(PRECISION)) guard_u (
    .clk(clk), .reset_n(reset_n),
    .in_valid(aff_v),
    .x_in0(x_next0), .x_in1(x_next1), .x_in2(x_next2),
    .seed0(seed_latch[0]), .seed1(seed_latch[1]), .seed2(seed_latch[2]),
    .out_valid(valid_guarded),
    .x_out0(x_safe0), .x_out1(x_safe1), .x_out2(x_safe2),
    .any_invalid(any_fp_error)
);

// ---------------------------------------------------------------------------
// State update: clock gate - ch? update khi valid_guarded
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        x[0] <= {PRECISION{1'b0}};
        x[1] <= {PRECISION{1'b0}};
        x[2] <= {PRECISION{1'b0}};
    end else if (seed_valid) begin
        x[0] <= seed_x0;
        x[1] <= seed_x1;
        x[2] <= seed_x2;
    end else if (valid_guarded) begin
        // CE=1 ch? khi có k?t qu? m?i ? không toggle lúc idle
        x[0] <= x_safe0;
        x[1] <= x_safe1;
        x[2] <= x_safe2;
    end
    // else: CE=0 ? gi? nguyên, không toggle
end

// ---------------------------------------------------------------------------
// Output: clock gate - ch? update khi valid_guarded
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid               <= 1'b0;
        pseudoRandomNumber1 <= {PRECISION{1'b0}};
        pseudoRandomNumber2 <= {PRECISION{1'b0}};
        pseudoRandomNumber3 <= {PRECISION{1'b0}};
    end else if (valid_guarded) begin
        valid               <= 1'b1;
        // Output giá tr? s?ch
        pseudoRandomNumber1 <= x_safe0;
        pseudoRandomNumber2 <= x_safe1;
        pseudoRandomNumber3 <= x_safe2;
    end else begin
        valid <= 1'b0;
        // Không clear pseudoRandomNumber ? gi?m toggling
        // (gi? giá tr? c? cho ??n l?n next valid)
    end
end

endmodule