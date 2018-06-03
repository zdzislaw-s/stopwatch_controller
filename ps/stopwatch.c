#include "xil_io.h"
#include "stopwatch_controller.h"
#include "xparameters.h"

/*
 * Define the base memory addresses of the stopwatch_controller IP core.
 */
#define SW_BASE         XPAR_STOPWATCH_CONTROLLER_0_S00_AXI_BASEADDR
#define SSD_ADDR        STOPWATCH_CONTROLLER_S00_AXI_SLV_REG0_OFFSET
#define LED_ADDR        STOPWATCH_CONTROLLER_S00_AXI_SLV_REG1_OFFSET
#define SWITCH_ADDR     STOPWATCH_CONTROLLER_S00_AXI_SLV_REG2_OFFSET
#define BTN_ADDR        STOPWATCH_CONTROLLER_S00_AXI_SLV_REG3_OFFSET
#define ENC_ADDR        STOPWATCH_CONTROLLER_S00_AXI_SLV_REG4_OFFSET
#define ENC_SW_ADDR     STOPWATCH_CONTROLLER_S00_AXI_SLV_REG5_OFFSET
#define ENC_BTN_ADDR    STOPWATCH_CONTROLLER_S00_AXI_SLV_REG6_OFFSET
#define TIMER_ADDR      STOPWATCH_CONTROLLER_S00_AXI_SLV_REG7_OFFSET
#define BTN_C           16
#define BTN_D           8
#define BTN_R           4
#define BTN_U           2
#define BTN_L           1

int main(void) {

    /* Initialization section */
    u32 ssd_val = 0;
    u32 led_val = 0;
    u32 switch_val = 0;
    u32 btn_val = 0;
    u32 enc_val = 0;
    u32 enc_sw_val = 0;
    u32 enc_btn_val = 0;
    u32 timer_val = 0;
    u32 btn_val_prev = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, BTN_ADDR);
    u32 timer_zero = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, TIMER_ADDR);
    u32 stopped = 0;

    while (1) {
        /* Input section */
        switch_val = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, SWITCH_ADDR);
        btn_val = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, BTN_ADDR);
        enc_val = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, ENC_ADDR);
        enc_sw_val = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, ENC_SW_ADDR);
        enc_btn_val = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, ENC_BTN_ADDR);
        u32 btn_val_rise = ~btn_val_prev & btn_val;

        if (!stopped)
            timer_val =
                STOPWATCH_CONTROLLER_mReadReg(SW_BASE, TIMER_ADDR) - timer_zero;

        /* Computation section */
        if (enc_sw_val) { /* encoder display */
            ssd_val = enc_val;
            led_val = enc_val;
        } 
        else { /* stopwatch functions */
            u32 hundredths = (timer_val / 10) % 100;
            u32 seconds = (timer_val / 1000) % 60;
            u32 minutes = (timer_val / (60 * 1000)) % 60;
            u32 hours = (timer_val / (60 * 60 * 1000)) % 24;
            u32 days = (timer_val / (24 * 60 * 60 * 1000));

            u32 time = hundredths;
            if (switch_val & 1)
                time = seconds;
            if (switch_val & 2)
                time = minutes;
            if (switch_val & 4)
                time = hours;
            if (switch_val & 8)
                time = days;

            led_val = time;
            ssd_val = ((time / 10) << 4) | (time % 10);
        }

        if (btn_val_rise & BTN_C) {
            if (stopped) {
                stopped = 0;
                timer_zero =
                    STOPWATCH_CONTROLLER_mReadReg(SW_BASE, TIMER_ADDR) - timer_val;
            } 
            else {
                timer_zero = STOPWATCH_CONTROLLER_mReadReg(SW_BASE, TIMER_ADDR);
                stopped = 1;
            }
        }

        /* Output section */
        STOPWATCH_CONTROLLER_mWriteReg(SW_BASE, SSD_ADDR, ssd_val);
        STOPWATCH_CONTROLLER_mWriteReg(SW_BASE, LED_ADDR, led_val);
        btn_val_prev = btn_val;
    }

    return 1;
}
