#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"

#define TRNG_BASE XPAR_TRNG_IP_0_S00_AXI_BASEADDR

int main() {
    init_platform();
    uint32_t random_val;
    uint32_t en = 1;
    uint32_t ready_flag;

    xil_printf("Da ket noi voi SDK");

    Xil_Out32(TRNG_BASE + 8, en) ;

    for (int i = 0; i < 1000; i++) {
    	do {
    		ready_flag = Xil_In32(TRNG_BASE + 4) ;
    	} while (ready_flag == 0);

    	random_val = Xil_In32(TRNG_BASE) ;
    	for (int j = 31; j >= 0; j--) {
    		uint32_t bit = (random_val >> i) & 1 ;
    		xil_printf("%lu", bit) ;
    	}

    	xil_printf("\r\n");

    	for (int i = 0; i < 1000; i++) {

    	}
    }

    cleanup_platform();
    return 0;
}

