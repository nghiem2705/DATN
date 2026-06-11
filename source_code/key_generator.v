// =============================================================================
// key_generator_opt.v  -  Key Generator t?i ?u (?ã fix l?i Multi-Driven)
// =============================================================================
module key_generator #(
    parameter V_SIZE   = 8,
    parameter KEY_SIZE = 128,
    parameter ROUND    = 5
)(
    input  wire                clk,
    input  wire                reset_n,
    input  wire [KEY_SIZE-1:0] initial_key,

    input  wire                sbox_valid,
    input  wire [V_SIZE-1:0]   V_out,

    input  wire                sbox_done,

    output reg                 valid,
    output reg  [KEY_SIZE-1:0] key,
    output reg                 done_key
);

// ---------------------------------------------------------------------------
// RCONST ROM - BRAM-backed
// ---------------------------------------------------------------------------
(* rom_style = "block" *)
reg [KEY_SIZE-1:0] RCONST [0:ROUND-1];

initial begin
    RCONST[0] = 128'h7AF39C1255EEB961C4882D21E712F84B;
    RCONST[1] = 128'hE91A447F08D93C6FE0B7AC1D3F22998C;
    RCONST[2] = 128'h4B8D1F0EFA77C20539D6258BB74493A1;
    RCONST[3] = 128'h99F63C2910ADEB883302197DA5FE6614;
    RCONST[4] = 128'h12C5E99ABBA0451F7F8D4C1E3360AA78;
end

// ---------------------------------------------------------------------------
// SubBytes instance - clock gated
// ---------------------------------------------------------------------------
reg                  sb_tv;
reg  [KEY_SIZE-1:0]  key_in;
wire                 sb_v;
wire [KEY_SIZE-1:0]  key_out;

subbytes #(
    .SBOX_WIDTH(8),
    .SBOX_DEPTH(256),
    .DATA_WIDTH(KEY_SIZE)
) u_sub (
    .clk      (clk),
    .reset_n  (reset_n),
    .sbox_valid(sbox_valid),
    .sbox_out  (V_out),
    .tvalid    (sb_tv),
    .in        (key_in),
    .valid     (sb_v),
    .out       (key_out)
);

// ---------------------------------------------------------------------------
// Control FSM
// ---------------------------------------------------------------------------
reg [2:0] r;
reg       all_done;

// Kh?i 1: Ch? qu?n lý ngõ vào c?a SubBytes (Không gán all_done ? ?ây n?a)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        sb_tv    <= 1'b0;
        key_in   <= {KEY_SIZE{1'b0}};
    end else if (sbox_done && !all_done) begin
        // B?t ??u: round ??u tiên t? initial_key
        sb_tv  <= 1'b1;
        key_in <= initial_key;
    end else if (sb_v && r < ROUND && !all_done) begin
        // Ti?p t?c: dùng key v?a t?o làm input cho round ti?p
        sb_tv  <= 1'b1;
        key_in <= key; 
    end else begin
        sb_tv <= 1'b0; // Clock gate: idle
    end
end

// ---------------------------------------------------------------------------
// Key output + round counter
// ---------------------------------------------------------------------------
function [KEY_SIZE-1:0] rot_word;
    input [KEY_SIZE-1:0] k;
    begin
        rot_word = {k[KEY_SIZE-1-32 : 0], k[KEY_SIZE-1 : KEY_SIZE-32]};
    end
endfunction

// Kh?i 2: Qu?n lý ngõ ra, b? ??m r và c? tr?ng thái all_done
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid    <= 1'b0;
        key      <= {KEY_SIZE{1'b0}};
        r        <= 3'd0;
        done_key <= 1'b0;
        all_done <= 1'b0; // all_done CH? ???c reset và set ? kh?i này
    end else if (sb_v && !all_done) begin
        valid <= 1'b1;
        key   <= rot_word(key_out) ^ RCONST[r];
        r     <= r + 3'd1;
        if (r == ROUND - 1) begin
            done_key <= 1'b1;
            all_done <= 1'b1;
        end
    end else begin
        valid    <= 1'b0;
        done_key <= 1'b0;
    end
end

endmodule