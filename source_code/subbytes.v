// =============================================================================
// subbytes.v  -  T?i ?u hóa BRAM Inference (Fix l?i Async Reset)
// =============================================================================
module subbytes #(
    parameter SBOX_WIDTH = 8,
    parameter SBOX_DEPTH = 256,
    parameter DATA_WIDTH = 128
)(
    input  wire                  clk,
    input  wire                  reset_n,

    input  wire                  sbox_valid,
    input  wire [SBOX_WIDTH-1:0] sbox_out,

    input  wire                  tvalid,
    input  wire [DATA_WIDTH-1:0] in,

    output reg                   valid,
    output wire [DATA_WIDTH-1:0] out // Chuy?n thành wire ?? gom tín hi?u
);

reg [7:0]  wr_index;
reg        sbox_ready;
wire wr_en = sbox_valid & ~sbox_ready;

// Kh?i qu?n lý tr?ng thái Ghi S-BOX (Có Reset bình th??ng)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        wr_index   <= 8'd0;
        sbox_ready <= 1'b0;
    end else if (wr_en) begin
        wr_index <= wr_index + 8'd1;
        if (wr_index == SBOX_DEPTH - 1)
            sbox_ready <= 1'b1;
    end
end

wire rd_en = tvalid & sbox_ready;

// Kh?i qu?n lý c? Valid (Có Reset bình th??ng)
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) valid <= 1'b0;
    else          valid <= rd_en;
end

// ============================================================
// T?O 16 KH?I BRAM V?T LÝ (TUY?T ??I KHÔNG DÙNG ASYNC RESET)
// ============================================================
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : BRAM_BLOCK
        (* ram_style = "block" *)
        reg [SBOX_WIDTH-1:0] mem [0:SBOX_DEPTH-1];
        reg [SBOX_WIDTH-1:0] read_data;

        // BRAM b?t bu?c ph?i dùng always @(posedge clk) THU?N TÚY
        always @(posedge clk) begin
            // Port Ghi
            if (wr_en) begin
                mem[wr_index] <= sbox_out;
            end
            
            // Port ??c
            if (rd_en) begin
                read_data <= mem[in[i*8 +: 8]];
            end
        end
        
        // N?i d? li?u ??c ???c ra dây output t?ng
        assign out[i*8 +: 8] = read_data;
    end
endgenerate

endmodule