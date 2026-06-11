module CTR_feistel_encrypt#(
	parameter ROUND 	= 5,
	parameter KEY_SIZE 	= 128,
	parameter F_LAT 	= 6,
	parameter ENCR_LAT  = 5*F_LAT+1,
	parameter SBOX_WIDTH 	= 8,
	parameter DATA_WIDTH 	= 256
)(
	input clk,
	input reset_n,

	input sbox_valid,
	input [7:0] sbox_out,

	input key_tvalid,
	input [KEY_SIZE-1:0] key,

	input tvalid,
	input [DATA_WIDTH-1:0] plaintext,
	input [DATA_WIDTH-1:0] iv,

	output reg valid,
	output reg [DATA_WIDTH-1:0] ciphertext
);

wire key_valid;
wire [KEY_SIZE-1:0] K[0:ROUND-1];
key_schedule_5r#(.ROUND(ROUND), .KEY_SIZE(KEY_SIZE)) key_schedule_5r_u(
	.clk(clk),
	.reset_n(reset_n),
	.tvalid(key_tvalid),
	.key(key),
	.valid(key_valid),
	.K0(K[0]),
	.K1(K[1]),
	.K2(K[2]),
	.K3(K[3]),
	.K4(K[4])
);


reg [DATA_WIDTH-1:0] counter;
reg encr_tvalid;
wire encr_valid;
wire [DATA_WIDTH-1:0] encr_out;

feistel_encrypt #(
    .ROUND(ROUND),
    .F_LAT(F_LAT),
    .SBOX_WIDTH(SBOX_WIDTH),
    .KEY_SIZE(KEY_SIZE),
    .DATA_WIDTH(DATA_WIDTH)
) feistel_encrypt_u (
    .clk(clk),
    .reset_n(reset_n),

    .sbox_out(sbox_out),
    .sbox_valid(sbox_valid),

    .key_valid(key_valid),
    .K0(K[0]), .K1(K[1]), .K2(K[2]), .K3(K[3]), .K4(K[4]),

    .tvalid(encr_tvalid),
    .plaintext(counter),

    .valid(encr_valid),
    .ciphertext(encr_out)
);
     
reg is_first_block;
reg [DATA_WIDTH-1:0] plaintext_t[0:ENCR_LAT];
integer i;
always@(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		encr_tvalid <= 0;
		is_first_block <= 1;
		counter <= 0;
		for(i = 0; i < ENCR_LAT+1; i = i+1) plaintext_t[i] <= 0;
	end else begin
		if(tvalid) begin
			encr_tvalid <= 1;
			counter <= (is_first_block || &counter) ? iv : counter + 1;
			is_first_block <= 0;
			plaintext_t[0] <= plaintext;
		end else begin
			encr_tvalid <= 0;
		end

		for(i = 1; i < ENCR_LAT+1; i = i+1) plaintext_t[i] <= plaintext_t[i-1];
	end
end


always@(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		valid <= 0;
		ciphertext <= 0;
	end else if(encr_valid) begin
		valid <= 1;
		ciphertext <= plaintext_t[ENCR_LAT] ^ encr_out;
	end else begin
		valid <= 0;
	end
end

endmodule
