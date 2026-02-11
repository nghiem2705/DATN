(* dont_touch = "true" *)

module S_TRNG (
    input en,
    input clk, 
    output ran
);

// tang 1 
(* keep = "true" *) wire nand1 ;
sub_ring_1 sub_1_1 (.en(en), .out(nand1)) ;

(* keep = "true" *) wire not2 ;
sub_ring_3 sub_3_1 (.en(en), .out(not2)) ;

(* keep = "true" *) wire xor1 , xor2 ;

(* dont_touch = "true" *)
LUT2 #( .INIT(4'h6) ) xor_gate1 (.I0(nand1), .I1(xor2), .O(xor1)) ;

(* dont_touch = "true" *)
LUT2 #( .INIT(4'h6) ) xor_gate2 (.I0(xor1), .I1(not2), .O(xor2)) ;

// tang 2 
(* keep = "true" *) wire nand3 ;
sub_ring_1 sub_1_2 (.en(en), .out(nand3)) ;

(* keep = "true" *) wire not4 ;
sub_ring_3 sub_3_2 (.en(en), .out(not4)) ;

(* keep = "true" *) wire xor3, xor4 ;

(* dont_touch = "true" *)
LUT2 #( .INIT(4'h6) ) xor_gate3 (.I0(nand3), .I1(xor4), .O(xor3));

(* dont_touch = "true" *)
LUT2 #( .INIT(4'h6) ) xor_gate4 (.I0(xor3), .I1(not4), .O(xor4)) ;

reg xor1_tmp ;
reg xor2_tmp ;
reg xor3_tmp ;
reg xor4_tmp ;

always @ (posedge clk) begin
    xor1_tmp <= xor1 ;
end

always @ (posedge clk) begin
    xor2_tmp <= xor2 ;
end

always @ (posedge clk) begin
    xor3_tmp <= xor3 ;
end

always @ (posedge clk) begin
    xor4_tmp <= xor4 ;
end


assign ran = xor1_tmp ^ xor2_tmp ^ xor3_tmp ^ xor4_tmp ;

endmodule

