`timescale 1ns / 1ps
// =============================================================================
// axi_crypto_wrapper.v
// K?t n?i top.v v?i PS (ARM) qua AXI4-Lite + AXI4-Stream
// REGISTER MAP (AXI-Lite, word-addressed qua [5:2]):
//   WRITE:
//     0x00 (word 0) : start[0]          - CPU b?t TRNG & h? th?ng
//     0x08 (word 2) : epsilon[31:0]      - tham s? ? (m?c ??nh 0x3D4CCCCD = 0.05)
//     0x0C (word 3) : init_key[31:0]
//     0x10 (word 4) : init_key[63:32]
//     0x14 (word 5) : init_key[95:64]
//     0x18 (word 6) : init_key[127:96]
//     0x1C (word 7) : iv[31:0]
//     0x20 (word 8) : iv[63:32]
//     0x24 (word 9) : iv[95:64]
//     0x28 (word 10): iv[127:96]
//     0x2C (word 11): iv[159:128]
//     0x30 (word 12): iv[191:160]
//     0x34 (word 13): iv[223:192]
//     0x38 (word 14): iv[255:224]
//   READ:
//     0x00 (word 0) : start[0]
//     0x04 (word 1) : done_key[0]        - h? th?ng s?n sàng
// =============================================================================
module axi_crypto_wrapper (
    // Clock & Reset
    input  wire        aclk,
    input  wire        aresetn,

    // AXI4-Lite Slave (ARM ghi c?u hình / ??c tr?ng thái)
    input  wire [5:0]  s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,
    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,
    input  wire [5:0]  s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,
    output reg  [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output reg         s_axi_rvalid,
    input  wire        s_axi_rready,

    // AXI4-Stream Slave (DMA ? Crypto, nh?n plaintext)
    input  wire [255:0] s_axis_tdata,
    input  wire         s_axis_tvalid,
    output wire         s_axis_tready,
    input  wire         s_axis_tlast,

    // AXI4-Stream Master (Crypto ? DMA, g?i ciphertext)
    output wire [255:0] m_axis_tdata,
    output wire         m_axis_tvalid,
    input  wire         m_axis_tready,
    output wire         m_axis_tlast
);

// =============================================================================
// THANH GHI C?U HÌNH
// =============================================================================
reg        start_reg;
reg [127:0] init_key_reg;
reg [255:0] iv_reg;
reg [31:0]  epsilon_reg;

// =============================================================================
// AXI4-Lite WRITE - always ready (single-cycle handshake)
// =============================================================================
assign s_axi_awready = 1'b1;
assign s_axi_wready  = 1'b1;
assign s_axi_bresp   = 2'b00; // OKAY
assign s_axi_bvalid  = s_axi_awvalid & s_axi_wvalid;

always @(posedge aclk) begin
    if (!aresetn) begin
        start_reg    <= 1'b0;
        epsilon_reg  <= 32'h3D4CCCCD; // 0.05
        init_key_reg <= 128'd0;
        iv_reg       <= 256'd0;
    end else if (s_axi_awvalid && s_axi_wvalid) begin
        case (s_axi_awaddr[5:2])
            4'd0:  start_reg            <= s_axi_wdata[0];
            4'd2:  epsilon_reg          <= s_axi_wdata;
            4'd3:  init_key_reg[31:0]   <= s_axi_wdata;
            4'd4:  init_key_reg[63:32]  <= s_axi_wdata;
            4'd5:  init_key_reg[95:64]  <= s_axi_wdata;
            4'd6:  init_key_reg[127:96] <= s_axi_wdata;
            4'd7:  iv_reg[31:0]         <= s_axi_wdata;
            4'd8:  iv_reg[63:32]        <= s_axi_wdata;
            4'd9:  iv_reg[95:64]        <= s_axi_wdata;
            4'd10: iv_reg[127:96]       <= s_axi_wdata;
            4'd11: iv_reg[159:128]      <= s_axi_wdata;
            4'd12: iv_reg[191:160]      <= s_axi_wdata;
            4'd13: iv_reg[223:192]      <= s_axi_wdata;
            4'd14: iv_reg[255:224]      <= s_axi_wdata;
            default: ;
        endcase
    end
end

// =============================================================================
// AXI4-Lite READ
// =============================================================================
wire done_key_wire;

assign s_axi_arready = 1'b1;
assign s_axi_rresp   = 2'b00;

// rvalid: set khi arvalid, clear khi rready
always @(posedge aclk) begin
    if (!aresetn)
        s_axi_rvalid <= 1'b0;
    else if (s_axi_arvalid)
        s_axi_rvalid <= 1'b1;
    else if (s_axi_rready)
        s_axi_rvalid <= 1'b0;
end

always @(posedge aclk) begin
    if (!aresetn)
        s_axi_rdata <= 32'd0;
    else if (s_axi_arvalid) begin
        case (s_axi_araddr[5:2])
            4'd0: s_axi_rdata <= {31'd0, start_reg};
            4'd1: s_axi_rdata <= {31'd0, done_key_wire};
            default: s_axi_rdata <= 32'd0;
        endcase
    end
end

// =============================================================================
// AXI4-Stream - tlast delay pipeline
// Latency t? plaintext vào ??n ciphertext ra: FEISTEL_LAT = 31 cycles
// =============================================================================
assign s_axis_tready = 1'b1;

localparam FEISTEL_LAT = 31;
reg [FEISTEL_LAT-1:0] tlast_shift;

always @(posedge aclk) begin
    if (!aresetn)
        tlast_shift <= {FEISTEL_LAT{1'b0}};
    else
        tlast_shift <= {tlast_shift[FEISTEL_LAT-2:0], s_axis_tlast};
end

assign m_axis_tlast = tlast_shift[FEISTEL_LAT-1];

// =============================================================================
// INSTANTIATE top.v
// =============================================================================
wire         crypto_valid;
wire [255:0] crypto_ciphertext;

top #(
    .PRECISION (32),
    .SBOX_WIDTH(8),
    .DATA_WIDTH(256),
    .KEY_SIZE  (128),
    .ROUND     (5)
) u_top (
    .clk        (aclk),
    .reset_n    (aresetn),
    .start      (start_reg),
    .initial_key(init_key_reg),
    .iv         (iv_reg),
    // Ch? chuy?n data khi start ?ã set
    .tvalid    (s_axis_tvalid & start_reg),
    .plaintext (s_axis_tdata),
    .valid     (crypto_valid),
    .ciphertext(crypto_ciphertext),
    .done_key  (done_key_wire)
);

// =============================================================================
// AXI4-Stream Master output - register slice v?i AXI handshake ?úng chu?n
//
// FIX: b?n g?c clear m_valid_reg khi m_axis_tready=1 b?t k? valid,
//      d?n ??n m?t beat n?u tready lên tr??c crypto_valid.
//      S?a: ch? clear khi C? HAI valid=1 và ready=1 cùng lúc (handshake).
// =============================================================================
reg [255:0] m_data_reg;
reg         m_valid_reg;

always @(posedge aclk) begin
    if (!aresetn) begin
        m_data_reg  <= 256'd0;
        m_valid_reg <= 1'b0;
    end else begin
        if (crypto_valid) begin
            // Có k?t qu? m?i t? pipeline
            m_data_reg  <= crypto_ciphertext;
            m_valid_reg <= 1'b1;
        end else if (m_valid_reg && m_axis_tready) begin
            // Handshake hoàn t?t (valid=1 & ready=1) ? clear ?? nh?n beat ti?p
            m_valid_reg <= 1'b0;
        end
        // N?u crypto_valid=0 và ch?a handshake: gi? nguyên (hold for DMA)
    end
end

assign m_axis_tdata  = m_data_reg;
assign m_axis_tvalid = m_valid_reg;

endmodule