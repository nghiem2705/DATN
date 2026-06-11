module extractor(
	input clk,
	input reset_n,
	input enable_extract,

	input [31:0] val1,
	input [31:0] val2,
	input [31:0] val3,

	output reg valid_extract,
	output reg [22:0] ex1,
	output reg [22:0] ex2,
	output reg [22:0] ex3
);

reg [7:0] exponent [0:2];
reg [22:0] fraction [0:2];
reg [23:0] mantissa [0:2];
reg [55:0] tmp [0:2]; 
reg [55:0] tmp1 [0:2];
reg [31:0] val [0:2]; 

integer E [0:2];
integer i;

reg assign_valid;
always @(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		for(i = 0; i < 3; i = i + 1) val[i] <= 0;
		assign_valid <= 0;
	end else if(enable_extract) begin
		val[0] <= val1; 
		val[1] <= val2;
		val[2] <= val3; 
		assign_valid <= 1;
	end else begin
		assign_valid <= 0;
	end
end

reg extract_valid;
always @(posedge clk or negedge reset_n) begin
	if(!reset_n) begin
		extract_valid <= 0;
		for (i = 0; i < 3; i = i + 1) begin
			exponent[i] <= 8'd0;
			fraction[i] <= 23'd0;
	    	end
	end else if(assign_valid) begin  
		extract_valid <= 1;
	    	for (i = 0; i < 3; i = i + 1) begin
			exponent[i] <= val[i][30:23];
			fraction[i] <= val[i][22:0];
	    	end
	end else begin
		extract_valid <= 0;
	end
end

reg calMant_valid;
always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
		calMant_valid <= 0;
            	for (i = 0; i < 3; i = i + 1) mantissa[i] <= 24'd0;
        end else if(extract_valid) begin
		calMant_valid <= 1;
		for (i = 0; i < 3; i = i + 1) begin
			if (exponent[i] == 8'd0) mantissa[i] <= {1'b0, fraction[i]}; 	// denormalized
                	else mantissa[i] <= {1'b1, fraction[i]}; 			// normalized
            	end
	end else begin
		calMant_valid <= 0;
	end
end

reg calE_valid;
always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
		calE_valid <= 0;
            	for (i = 0; i < 3; i = i + 1) E[i] <= 0;
        end else if(calMant_valid) begin
		calE_valid <= 1;
            	for (i = 0; i < 3; i = i + 1) begin
		    	if (exponent[i] == 8'd0) E[i] <= -126; // bias cho sá»' denormalized
		    	else E[i] <= exponent[i] - 127;
            	end
	end else begin
		calE_valid <= 0;
	end
end

reg shiltMant_valid;
always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
		shiltMant_valid <= 0;
            	for (i = 0; i < 3 ; i = i + 1) tmp[i] <= 56'd0;
        end else if(calE_valid) begin
		shiltMant_valid <= 1;
            	for (i = 0; i < 3; i = i + 1) begin
                	if (E[i] >= 0) tmp[i] <= mantissa[i] << E[i];
                	else tmp[i] <= mantissa[i] >> (-E[i]);
            	end 
	end else begin
		shiltMant_valid <= 0;
	end
end

reg mul_valid;
always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
		mul_valid <= 0;
            	for (i = 0; i < 3; i = i + 1) tmp1[i] <= 56'd0;
        end else if(shiltMant_valid) begin
		mul_valid <= 1;
            	for (i = 0; i < 3; i = i + 1) tmp1[i] <= (tmp[i] * 56'd1000000) >> 23;
	end else begin
		mul_valid <= 0;
	end
end

always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            	ex1 <= 23'd0;
            	ex2 <= 23'd0;
            	ex3 <= 23'd0;
		valid_extract <= 0;
        end else if(mul_valid) begin
            	ex1 <= tmp1[0] % 1000; 
            	ex2 <= tmp1[1] % 1000;
            	ex3 <= tmp1[2] % 1000;
		valid_extract <= 1;
	end else begin
		valid_extract <= 0;
	end
end

endmodule