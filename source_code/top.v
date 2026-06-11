module top #(
    parameter PRECISION  = 32,
    parameter SBOX_WIDTH = 8,
    parameter DATA_WIDTH = 256,
    parameter KEY_SIZE   = 128,
    parameter ROUND      = 5
)(
    input clk,
    input reset_n,

    // ============================================================
    // C?NG GIAO TI?P V?I CHIP ARM (PS) QUA THANH GHI AXI-LITE
    // ============================================================
    input wire start,                    // CPU ra l?nh kích ho?t TRNG
    input wire [KEY_SIZE-1:0] initial_key, // Khóa bí m?t do CPU n?p xu?ng
    input wire [DATA_WIDTH-1:0] iv,        // Vector kh?i t?o do CPU n?p xu?ng
    output wire done_key,                  // C? báo CPU: H? th?ng ?ã s?n sàng!

    // ============================================================
    // C?NG GIAO TI?P V?I B? DMA (AXI-STREAM)
    // ============================================================
    input wire tvalid,                   // DMA báo có d? li?u t?i
    input wire [DATA_WIDTH-1:0] plaintext, // D? li?u t? DMA (B?n rõ ho?c B?n mã ??u ok)
    output wire valid,                   // Báo cho DMA: D? li?u mã hóa xong
    output wire [DATA_WIDTH-1:0] ciphertext // D? li?u tr? v? DMA
);

// ============================================================
// B??C 1: TRNG - sinh 1 bit entropy m?i cycle
// ============================================================
wire trng_ran;

S_TRNG trng_u (
    .en (start),    // TRNG ch? ch?y khi CPU ra l?nh start
    .clk(clk),
    .ran(trng_ran)
);

// ============================================================
// B??C 2: Accumulator - gom bit TRNG thành 3 float IEEE 754
// ============================================================
wire                 seed_valid;
wire [PRECISION-1:0] seed_x0, seed_x1, seed_x2;

trng_seed_accumulator #(.PRECISION(PRECISION)) acc_u (
    .clk       (clk),
    .reset_n   (reset_n),
    .trng_bit  (trng_ran),
    .trng_en   (start),
    .seed_valid(seed_valid),
    .x0        (seed_x0),
    .x1        (seed_x1),
    .x2        (seed_x2)
);

// ============================================================
// B??C 3: PRNG_with_guard
// ============================================================
wire PRNG_tvalid = seed_valid;  
wire PRNG_valid;
wire [PRECISION-1:0] pseudoRandomNumber[0:2];

PRNG #(.PRECISION(PRECISION)) PRNG_u (
    .clk    (clk),
    .reset_n(reset_n),

    .seed_valid(seed_valid),
    .seed_x0   (seed_x0),
    .seed_x1   (seed_x1),
    .seed_x2   (seed_x2),

    .tvalid(PRNG_tvalid),

    .valid              (PRNG_valid),
    .pseudoRandomNumber1(pseudoRandomNumber[0]),
    .pseudoRandomNumber2(pseudoRandomNumber[1]),
    .pseudoRandomNumber3(pseudoRandomNumber[2])
);

// ============================================================
// B??C 4: Sinh S-BOX t? output PRNG 
// ============================================================
wire sbox_gen_valid;
wire [SBOX_WIDTH-1:0] V;

sbox_generator #(
    .PRECISION    (PRECISION),
    .EXTRACT_WIDTH(23),
    .MIX_WIDTH    (8)
) sbox_generator_u (
    .clk               (clk),
    .reset_n           (reset_n),
    .tvalid            (PRNG_valid),
    .pseudoRandomNumber1(pseudoRandomNumber[0]),
    .pseudoRandomNumber2(pseudoRandomNumber[1]),
    .pseudoRandomNumber3(pseudoRandomNumber[2]),
    .valid             (sbox_gen_valid),
    .V_out             (V)
);

wire sbox_valid;
wire [SBOX_WIDTH-1:0] V_out;
wire done_sbox;

sbox #(
    .SIZE     (256),        
    .BIT_WIDTH(SBOX_WIDTH)
) sbox_u (
    .clk      (clk),
    .reset_n  (reset_n),
    .tvalid   (sbox_gen_valid),
    .V        (V),
    .valid    (sbox_valid),
    .V_out    (V_out),
    .done_sbox(done_sbox)
);

// ============================================================
// B??C 5: Key generator 
// ============================================================
wire key_valid;
wire [KEY_SIZE-1:0] key;

key_generator #(
    .V_SIZE  (SBOX_WIDTH),
    .KEY_SIZE(KEY_SIZE),
    .ROUND   (ROUND)
) key_gen_u (
    .clk        (clk),
    .reset_n    (reset_n),
    .initial_key(initial_key),  // Ngu?n key t? CPU ARM n?p xu?ng

    .sbox_valid(sbox_valid),
    .V_out     (V_out),
    .sbox_done (done_sbox),

    .valid   (key_valid),
    .key     (key),
    .done_key(done_key) // Báo ra ngoài Wrapper là ?ã t?o S-box và Key xong
);

// ============================================================
// B??C 6: CTR Feistel Core (Dùng chung cho c? Encrypt và Decrypt)
// ============================================================
localparam F_LAT = 6;

// Ch? c?p d? li?u vào Core mã hóa khi tvalid c?a DMA báo có d? li?u,
// VÀ h? th?ng (Key & S-box) ?ã kh?i t?o xong (done_key = 1)
wire core_tvalid = tvalid && done_key; 

CTR_feistel_encrypt #(
    .ROUND    (ROUND),
    .KEY_SIZE (KEY_SIZE),
    .F_LAT    (F_LAT),
    .ENCR_LAT (5*F_LAT+1),
    .SBOX_WIDTH(SBOX_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) crypto_core_u (
    .clk    (clk),
    .reset_n(reset_n),

    .sbox_valid(sbox_valid),
    .sbox_out  (V_out),

    .key_tvalid(key_valid),
    .key       (key),

    .tvalid   (core_tvalid),
    .plaintext(plaintext), // Nh?n D? li?u t? DMA 
    .iv       (iv),        // Nh?n IV t? CPU ARM

    .valid     (valid),    // Tr? c? valid v? cho DMA
    .ciphertext(ciphertext) // Tr? d? li?u ?ã x? lý v? cho DMA
);

endmodule