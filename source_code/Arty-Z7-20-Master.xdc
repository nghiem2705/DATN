# =============================================================================
# power_opt.xdc  -  Vivado Constraints cho Clock Gating, Power Optimization
#                   & Pin/Timing Assignments
# Áp d?ng cho design v?i top module: top_opt
# =============================================================================

# ---------------------------------------------------------------------------
# 1. CLOCK GATING: Cho phép Vivado t? ??ng chèn ICG (Integrated Clock Gate)
#    t? Clock Enable (CE) trên flip-flop.
#    -> Gi?m switching power c?a clock tree khi CE=0.
# ---------------------------------------------------------------------------
# ?Ã B?: Không h? tr? set tr?c ti?p qua XDC. B?t tính n?ng này trong 
# Settings -> Synthesis -> More Options: thêm "-gated_clock_conversion auto"

# ---------------------------------------------------------------------------
# 2. POWER OPTIMIZATION: Ch?y power_opt_design sau opt_design
#    Thêm vào Tcl flow:
#      synth_design -> opt_design -> power_opt_design -> place_design -> ...
# ---------------------------------------------------------------------------
# (L?nh này ch?y trong Vivado Tcl, không ph?i XDC)
# power_opt_design

# ---------------------------------------------------------------------------
# 3. BRAM Power Mode: dùng SLEEP mode cho BRAM khi không access
#    Áp d?ng cho các BRAM instance (sbox_mem, K_mem)
# ---------------------------------------------------------------------------
# Sau place_design, set BRAM sleep:
# set_property POWER_OPT_MODE LOW_POWER [get_cells -hierarchical -filter {PRIMITIVE_TYPE =~ BMEM.*}]

# ---------------------------------------------------------------------------
# 4. DSP48 Power: Cascade mode ?? tránh routing qua global fabric
# ---------------------------------------------------------------------------
set_property USE_DSP yes [get_cells -hierarchical -filter {NAME =~ *mul_inst*}]

# ---------------------------------------------------------------------------
# 5. Clock Buffer: BUFGCE thay BUFG ?? h? tr? gating
# ---------------------------------------------------------------------------
# ?Ã B?: Gây l?i [Opt 31-316]. Zynq-7000 không h? tr? gán BUFGCE tr?c ti?p 
# lên port clk t? XDC. Vivado s? t? ??ng dùng BUFG an toàn.

# ---------------------------------------------------------------------------
# 6. Multi-Vt Cells: dùng HVT (High-Vt) cho các path không critical
#    -> Gi?m leakage power (~20%)
# ---------------------------------------------------------------------------
# set_multi_vt_cells -high_vt [get_cells -hierarchical -filter {SLACK > 2.0}]

# ---------------------------------------------------------------------------
# 7. Fanout limit: gi?m fanout c?a valid signals ?? gi?m switching
# ---------------------------------------------------------------------------
set_property MAX_FANOUT 16 [get_nets -hierarchical -filter {NAME =~ *valid*}]
set_property MAX_FANOUT 8  [get_nets -hierarchical -filter {NAME =~ *tvalid*}]


# =============================================================================
# PIN PLANNING & TIMING CONSTRAINTS
# =============================================================================

# ---------------------------------------------------------------------------
# 8. Timing constraint & Gán chân (Pin Planning)
#    Zynq-7020: max ~250 MHz PL, th?c t? target 100-150 MHz cho FP pipeline
# ---------------------------------------------------------------------------
# Clock Pin (Ví d? H16 là chân clock m?c ??nh trên board c?a b?n)
#set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { clk }];
#create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports clk]

# Tvalid Pin (Fix l?i DRC NSTD-1 và UCIO-1)
# L?U Ý: Vui lòng thay 'T16' b?ng tên chân th?c t? trên board Arty-Z7 c?a b?n 
# (Ví d?: m?t chân n?i v?i nút b?m, switch ho?c GPIO)
#set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { tvalid }];


# =============================================================================
# BYPASS L?I DRC & COMBINATORIAL LOOPS (CHO M?CH TRNG)
# =============================================================================

# ---------------------------------------------------------------------------
# 9. Cho phép các vòng l?p t? h?p (Combinatorial Loops) c?a Ring Oscillator
#    (?ã s?a ???ng d?n filter theo ?úng log t?ng h?p c?a Vivado ?? tránh l?i LUTLP-1)
# ---------------------------------------------------------------------------

# Cho phép các vòng l?p ring_wire trong các sub_ring c?a b? TRNG (trng_u)
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*ring_wire*}]

# Cho phép các vòng l?p w2 trong các sub_ring_3 c?a b? TRNG
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*w2*}]

# Cho phép các vòng l?p ph?n h?i chéo t?i các c?ng XOR c?a TRNG
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*xor1*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*xor2*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*xor3*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *trng_u*xor4*}]

# C?u hình d? phòng b?t các xor loop n?u b? ??y ra ngoài scope trng_u
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *xor1*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *xor2*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *xor3*}]
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *xor4*}]

# H? th?p m?c ?? nghiêm tr?ng c?a l?i DRC LUTLP-1 xu?ng m?c C?nh báo (Warning) ?? có th? t?o Bitstream
set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]

# (Tùy ch?n) H? severity cho l?i ch?a gán chân n?u b?n ch? mu?n build th? mà ch?a có m?ch th?t
# set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
# set_property SEVERITY {Warning} [get_drc_checks UCIO-1]