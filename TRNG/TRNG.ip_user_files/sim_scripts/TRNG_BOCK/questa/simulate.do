onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib TRNG_BOCK_opt

do {wave.do}

view wave
view structure
view signals

do {TRNG_BOCK.udo}

run -all

quit -force
