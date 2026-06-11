module F(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        tvalid,
    
    input  wire [7:0]  sbox_out,   
    input  wire        sbox_valid,
    
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output reg [127:0] state_out,
    output reg valid
);

reg [127:0] sb_in;
reg [127:0] sr_in;
reg [127:0] mc_in;
wire [127:0] sb_out;
wire [127:0] sr_out;
wire [127:0] mc_out;
wire [127:0] ak_out;

reg sb_tvalid, mc_tvalid;
wire sb_valid, mc_valid;

// --- SubBytes ---
subbytes #(.SBOX_WIDTH(8), .SBOX_DEPTH(256), .DATA_WIDTH(128)) u_sub (
	.clk(clk),
	.reset_n(reset_n),
	.sbox_out(sbox_out),
	.sbox_valid(sbox_valid),
	.tvalid(tvalid),
	.in(state_in),
	.valid(sb_valid),
	.out(sb_out)
);

// --- ShiftRows ---
shiftrows u_shift (
	.sb(sb_out),
	.out(sr_out)
);

// --- MixColumns ---
mixcolumns u_mix (
	.clk(clk),
	.reset_n(reset_n),
	.tvalid(mc_tvalid),
	.state_in(mc_in),
	.valid(mc_valid),
	.state_out(mc_out)
);

// --- AddRoundKey ---
addroundkey u_add (
	.state_in(mc_out),
	.round_key(round_key),
	.state_out(ak_out)
);

always@(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		mc_in <= 0;
		mc_tvalid <= 0;
	end else if(sb_valid) begin
		mc_in <= sr_out;
		mc_tvalid <= 1;
	end else begin
		mc_tvalid <= 0;
	end
end

always@(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		valid <= 0;
		state_out <= 0;
	end else if(mc_valid) begin
		valid <= 1;
		state_out <= ak_out;
	end else begin
		valid <= 0;
	end
end

endmodule
