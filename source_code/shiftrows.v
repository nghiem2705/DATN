module shiftrows(
    input  wire [127:0] sb,
    output wire  [127:0] out
);
    // Row 0: no shift
    assign out[127:120] = sb[127:120];
    assign out[95:88]   = sb[95:88];
    assign out[63:56]   = sb[63:56];
    assign out[31:24]   = sb[31:24];

    // Row 1: shift left by 1 byte
    assign out[119:112] = sb[87:80];
    assign out[87:80]   = sb[55:48];
    assign out[55:48]   = sb[23:16];
    assign out[23:16]   = sb[119:112];

    // Row 2: shift left by 2 bytes
    assign out[111:104] = sb[47:40];
    assign out[79:72]   = sb[15:8];
    assign out[47:40]   = sb[111:104];
    assign out[15:8]    = sb[79:72];

    // Row 3: shift left by 3 bytes
    assign out[103:96]  = sb[7:0];
    assign out[71:64]   = sb[103:96];
    assign out[39:32]   = sb[71:64];
    assign out[7:0]     = sb[39:32];
endmodule
