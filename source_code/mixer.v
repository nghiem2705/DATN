module mixer( //include step 5 (modulo) and step 6 (mix)
	input clk,
	input reset_n,
	input tvalid,
	input [22:0] ex1,
	input [22:0] ex2,
	input [22:0] ex3,
	output reg valid,
	output reg [7:0] V
);

reg [22:0] D1, D2, D3;
reg modulo_valid;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
        	D1 <= 22'b0;
        	D2 <= 22'b0;
        	D3 <= 22'b0;
		modulo_valid <= 0;
    	end else if(tvalid) begin
//		D1 <= ex1 % 8'hFF;
//		D2 <= ex2 % 8'hFF;
//		D3 <= ex3 % 8'hFF;
        D1 <= ex1[7:0];     
        D2 <= ex2[7:0]; 
        D3 <= ex3[7:0]; 
		modulo_valid <= 1;
    	end else begin
		modulo_valid <= 0;
	end
end

always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		valid 	<= 0;
		V 	<= 23'b0;
	end else if(modulo_valid) begin
		valid 	<= 1;
		V 	<= D1 ^ D2 ^ D3;
	end else begin
		valid 	<= 0;
	end
end

endmodule
