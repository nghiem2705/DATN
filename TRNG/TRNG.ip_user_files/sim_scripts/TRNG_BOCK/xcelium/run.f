-makelib xcelium_lib/xilinx_vip -sv \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Users/Admin/Documents/vivado/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/TRNG_BOCK/ip/TRNG_BOCK_S_TRNG_0_0/sim/TRNG_BOCK_S_TRNG_0_0.v" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/smartconnect_v1_0 -sv \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/5bb9/hdl/sc_util_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/axi_protocol_checker_v2_0_3 -sv \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/03a9/hdl/axi_protocol_checker_v2_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/axi_vip_v1_1_3 -sv \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/b9a8/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/processing_system7_vip_v1_0_5 -sv \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/70fd/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/TRNG_BOCK/ip/TRNG_BOCK_processing_system7_0_0/sim/TRNG_BOCK_processing_system7_0_0.v" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_12 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/f86a/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/TRNG_BOCK/ip/TRNG_BOCK_rst_ps7_0_100M_0/sim/TRNG_BOCK_rst_ps7_0_100M_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/TRNG_BOCK/ipshared/26bf/hdl/TRNG_IP_v1_0_S00_AXI.v" \
  "../../../bd/TRNG_BOCK/ipshared/26bf/hdl/TRNG_IP_v1_0.v" \
  "../../../bd/TRNG_BOCK/ip/TRNG_BOCK_TRNG_IP_0_1/sim/TRNG_BOCK_TRNG_IP_0_1.v" \
  "../../../bd/TRNG_BOCK/sim/TRNG_BOCK.v" \
-endlib
-makelib xcelium_lib/generic_baseblocks_v2_1_0 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/7aff/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_2 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/7aff/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/axi_data_fifo_v2_1_16 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/247d/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_17 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/6020/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_protocol_converter_v2_1_17 \
  "../../../../TRNG.srcs/sources_1/bd/TRNG_BOCK/ipshared/ccfb/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/TRNG_BOCK/ip/TRNG_BOCK_auto_pc_0/sim/TRNG_BOCK_auto_pc_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

