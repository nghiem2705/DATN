module M_TRNG #(
    parameter LOOP_NUM = 8 
)
(
    input clk,
    input en,
    output [LOOP_NUM - 1 : 0] ran
);

genvar i ;
generate
    for (i = 0; i < LOOP_NUM ; i = i + 1) begin : gen_trng
        (* dont_touch = "true" *)
        S_TRNG u_trng (
            .en(en),
            .clk(clk),
            .ran(ran[i])
        ) ;
    end
endgenerate

endmodule