`timescale 1ns / 1ps
module CTR_feistel_decrypt #(
    parameter ROUND      = 5,
    parameter KEY_SIZE   = 128,
    parameter F_LAT      = 6,
    parameter ENCR_LAT   = 5*F_LAT+1,
    parameter SBOX_WIDTH = 8,
    parameter DATA_WIDTH = 256
)(
    input  wire                   clk,
    input  wire                   reset_n,
    input  wire                   sbox_valid,
    input  wire [7:0]             sbox_out,
    input  wire                   key_tvalid,
    input  wire [KEY_SIZE-1:0]    key,
    input  wire                   tvalid,
    input  wire [DATA_WIDTH-1:0]  ciphertext,
    input  wire [DATA_WIDTH-1:0]  iv,
    output reg                    valid,
    output reg  [DATA_WIDTH-1:0]  plaintext
);

wire                key_valid;
wire [KEY_SIZE-1:0] K [0:ROUND-1];

key_schedule_5r #(.ROUND(ROUND), .KEY_SIZE(KEY_SIZE)) key_sched_u (
    .clk    (clk),
    .reset_n(reset_n),
    .tvalid (key_tvalid),
    .key    (key),
    .valid  (key_valid),
    .K0(K[0]), .K1(K[1]), .K2(K[2]), .K3(K[3]), .K4(K[4])
);

reg [DATA_WIDTH-1:0] counter;
reg                  decr_tvalid;
wire                 decr_valid;
wire [DATA_WIDTH-1:0] decr_out;

feistel_encrypt #(
    .ROUND     (ROUND),
    .F_LAT     (F_LAT),
    .SBOX_WIDTH(SBOX_WIDTH),
    .KEY_SIZE  (KEY_SIZE),
    .DATA_WIDTH(DATA_WIDTH)
) feistel_u (
    .clk       (clk),
    .reset_n   (reset_n),
    .sbox_out  (sbox_out),
    .sbox_valid(sbox_valid),
    .key_valid (key_valid),
    .K0(K[0]), .K1(K[1]), .K2(K[2]), .K3(K[3]), .K4(K[4]),
    .tvalid    (decr_tvalid),
    .plaintext (counter),
    .valid     (decr_valid),
    .ciphertext(decr_out)
);

reg                   is_first_block;
reg [DATA_WIDTH-1:0]  ciphertext_t [0:ENCR_LAT];
integer i;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        decr_tvalid    <= 1'b0;
        is_first_block <= 1'b1;
        counter        <= {DATA_WIDTH{1'b0}};
        for (i = 0; i <= ENCR_LAT; i = i+1)
            ciphertext_t[i] <= {DATA_WIDTH{1'b0}};
    end else begin
        if (tvalid) begin
            decr_tvalid    <= 1'b1;
            counter        <= (is_first_block || (&counter)) ? iv : counter + 1;
            is_first_block <= 1'b0;
            ciphertext_t[0] <= ciphertext;
        end else begin
            decr_tvalid <= 1'b0;
        end
        for (i = 1; i <= ENCR_LAT; i = i+1)
            ciphertext_t[i] <= ciphertext_t[i-1];
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid     <= 1'b0;
        plaintext <= {DATA_WIDTH{1'b0}};
    end else if (decr_valid) begin
        valid     <= 1'b1;
        plaintext <= ciphertext_t[ENCR_LAT] ^ decr_out;
    end else begin
        valid <= 1'b0;
    end
end

endmodule
