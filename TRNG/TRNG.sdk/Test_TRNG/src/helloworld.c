#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h" // File này định nghĩa địa chỉ IP của bạn
#include "xil_io.h"      // Thư viện để đọc/ghi thanh ghi AXI

int main() {
    init_platform();
    print("--- TRNG Test Arty Z7 ---\n\r");

    uint32_t data;

    while(1) {
        // Đọc giá trị từ thanh ghi số 0 của IP TRNG
        // Tên XPAR_... có thể khác một chút, bạn có thể nhấn Ctrl+Space để SDK gợi ý
        data = Xil_In32(XPAR_TRNG_IP_0_S00_AXI_BASEADDR);

        // Lấy bit cuối cùng (ran)
        int bit_ngau_nhien = data & 0x01;

        xil_printf("Raw: 0x%08x | Bit: %d\r\n", data, bit_ngau_nhien);

        // Delay để nhìn cho kịp
        for(int i=0; i<1000000; i++);
    }

    cleanup_platform();
    return 0;
}
