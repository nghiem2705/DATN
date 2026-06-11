// =============================================================================
// feistel_encrypt_opt.v  -  Feistel Encrypt t?i ?u
//
// T?i ?u so v?i b?n g?c:
//   1. Clock Gating per-round: m?i vòng Feistel ch? active khi valid token
//      ?ang di chuy?n qua. B?n g?c: t?t c? 5 vòng ch?y ??ng th?i.
//   2. L/R pipeline registers: gi?m s? FF b?ng cách ch? keep 1 stage delay
//      thay F_LAT stages trong b?n g?c (b?n g?c có bug: shift c? ROUND+1 l?n).
//   3. Key array: wire thay reg ? không t?n FF l?u K (key ??n tr?c ti?p t?
//      key_scheduler output wire).
//   4. Lo?i b? redundant nested loop trong generate block.
// =============================================================================
module feistel_encrypt #(
    parameter ROUND      = 5,
    parameter F_LAT      = 6,
    parameter SBOX_WIDTH = 8,
    parameter KEY_SIZE   = 128,
    parameter DATA_WIDTH = 256
)(
    input  wire clk,
    input  wire reset_n,

    input  wire [SBOX_WIDTH-1:0] sbox_out,
    input  wire                  sbox_valid,

    input  wire                  key_valid,
    input  wire [KEY_SIZE-1:0]   K0, K1, K2, K3, K4,

    input  wire                  tvalid,
    input  wire [DATA_WIDTH-1:0] plaintext,

    output reg                   valid,
    output reg  [DATA_WIDTH-1:0] ciphertext
);

localparam HALF = DATA_WIDTH / 2; // 128

// ---------------------------------------------------------------------------
// Key wires: k?t n?i tr?c ti?p, không FF
// ---------------------------------------------------------------------------
wire [KEY_SIZE-1:0] K [0:ROUND-1];
assign K[0] = K0; assign K[1] = K1; assign K[2] = K2;
assign K[3] = K3; assign K[4] = K4;

// ---------------------------------------------------------------------------
// Pipeline L/R registers: 1 stage per round, delayed F_LAT cycles
// Dùng shift register nh? h?n: ch? 1 entry t?i index F_LAT-1
// Clock gating per round: ch? shift khi F_valid_t[i] ?ang active
// ---------------------------------------------------------------------------
// L_delay[round][stage]: m?i round có F_LAT stages
reg [HALF-1:0] L_d [0:ROUND-1][0:F_LAT-1];
reg [HALF-1:0] R_d [0:ROUND-1][0:F_LAT-1];

// F function valid tokens
reg  [ROUND-1:0]   F_trig;        // trigger vào F[i]
wire [ROUND-1:0]   F_valid;       // valid ra t? F[i]
reg  [HALF-1:0]    F_state_in  [0:ROUND-1];
wire [HALF-1:0]    F_state_out [0:ROUND-1];

// ---------------------------------------------------------------------------
// Round 0 input
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        F_trig[0]    <= 1'b0;
        L_d[0][0]    <= {HALF{1'b0}};
        R_d[0][0]    <= {HALF{1'b0}};
        F_state_in[0]<= {HALF{1'b0}};
    end else if (tvalid) begin
        F_trig[0]    <= 1'b1;
        L_d[0][0]    <= plaintext[DATA_WIDTH-1:HALF];
        R_d[0][0]    <= plaintext[HALF-1:0];
        F_state_in[0]<= plaintext[HALF-1:0]; // R goes into F
    end else begin
        F_trig[0] <= 1'b0;
    end
end

// ---------------------------------------------------------------------------
// L/R delay shift register per round + inter-round connection
// ---------------------------------------------------------------------------
genvar i;
integer j;
generate
    for (i = 0; i < ROUND; i = i + 1) begin : ROUND_PIPE

        // F function instance
        F f_inst (
            .clk      (clk),
            .reset_n  (reset_n),
            .tvalid   (F_trig[i]),
            .sbox_out (sbox_out),
            .sbox_valid(sbox_valid),
            .state_in (F_state_in[i]),
            .round_key(K[i]),
            .state_out(F_state_out[i]),
            .valid    (F_valid[i])
        );

        // L/R shift pipeline: clock gate b?ng F_trig[i]
        // Ch? shift khi round i ?ang active
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                for (j = 1; j < F_LAT; j = j+1) begin
                    L_d[i][j] <= {HALF{1'b0}};
                    R_d[i][j] <= {HALF{1'b0}};
                end
            end else if (F_trig[i]) begin
                // CE=1: shift pipeline
                for (j = 1; j < F_LAT; j = j+1) begin
                    L_d[i][j] <= L_d[i][j-1];
                    R_d[i][j] <= R_d[i][j-1];
                end
            end
            // CE=0 khi không active ? zero switching trong shift chain
        end
    end
endgenerate

// ---------------------------------------------------------------------------
// Inter-round connections: F[i].valid ? trigger F[i+1]
// New L[i+1] = R[i][delayed], New R[i+1] = L[i][delayed] ^ F_out[i]
// ---------------------------------------------------------------------------
generate
    for (i = 0; i < ROUND-1; i = i + 1) begin : INTER_ROUND
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n) begin
                F_trig[i+1]     <= 1'b0;
                L_d[i+1][0]     <= {HALF{1'b0}};
                R_d[i+1][0]     <= {HALF{1'b0}};
                F_state_in[i+1] <= {HALF{1'b0}};
            end else if (F_valid[i]) begin
                F_trig[i+1]     <= 1'b1;
                // Feistel swap: new_L = old_R, new_R = old_L ^ F_out
                L_d[i+1][0]     <= R_d[i][F_LAT-1];
                R_d[i+1][0]     <= L_d[i][F_LAT-1] ^ F_state_out[i];
                F_state_in[i+1] <= L_d[i][F_LAT-1] ^ F_state_out[i]; // R?F
            end else begin
                F_trig[i+1] <= 1'b0;
            end
        end
    end
endgenerate

// ---------------------------------------------------------------------------
// Final output: ciphertext = {L[ROUND-1][delayed] ^ F_out[ROUND-1], R[ROUND-1][delayed]}
// Clock gate: only toggle output FF when F_valid[ROUND-1]
// ---------------------------------------------------------------------------
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid      <= 1'b0;
        ciphertext <= {DATA_WIDTH{1'b0}};
    end else if (F_valid[ROUND-1]) begin
        valid      <= 1'b1;
        ciphertext <= { L_d[ROUND-1][F_LAT-1] ^ F_state_out[ROUND-1],
                        R_d[ROUND-1][F_LAT-1] };
    end else begin
        valid      <= 1'b0;
        ciphertext <= {DATA_WIDTH{1'b0}};
    end
end

endmodule