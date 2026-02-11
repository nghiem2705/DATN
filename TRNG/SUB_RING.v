(* dont_touch = "true" *)
module sub_ring_1(
    input en,
    output out
);
    (* keep = "true" *) wire ring_wire;
    LUT2 #( .INIT(4'h7) ) nand_gate (.I0(ring_wire), .I1(en), .O(ring_wire) ) ;
    
    assign out = ring_wire;
    
endmodule

(* dont_touch = "true" *)
module sub_ring_3(
    input en,
    output out
);
    (* keep = "true" *) wire w1 , w2 , w3;
    LUT2 #( .INIT(4'h7) ) nand_gate (.I0(out), .I1(en), .O(w1));
    LUT1 #( .INIT(2'h1) ) not1 (.I0(w1), .O(w2)) ;
    LUT1 #( .INIT(2'h1) ) not2 (.I0(w2), .O(w3)) ;
    
    assign out = w3 ;

endmodule
