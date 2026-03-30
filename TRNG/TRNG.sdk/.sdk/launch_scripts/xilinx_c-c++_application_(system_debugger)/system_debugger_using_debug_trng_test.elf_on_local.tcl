connect -url tcp:127.0.0.1:3121
source C:/Users/Admin/Documents/vivado/exercise/TRNG/TRNG.sdk/ZC702_hw_platform/ps7_init.tcl
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Arty Z7 003017B3FA2FA"} -index 0
loadhw -hw C:/Users/Admin/Documents/vivado/exercise/TRNG/TRNG.sdk/ZC702_hw_platform/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent Arty Z7 003017B3FA2FA"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Arty Z7 003017B3FA2FA"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Arty Z7 003017B3FA2FA"} -index 0
dow C:/Users/Admin/Documents/vivado/exercise/TRNG/TRNG.sdk/TRNG_TEST/Debug/TRNG_TEST.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Arty Z7 003017B3FA2FA"} -index 0
con
