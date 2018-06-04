#ifndef IS_BARE_METAL // TODO: rename to platform/architecture/os/...
#  error "Please define IS_BARE_METAL, either to 0 or 1, in your project settings."
#endif // IS_BARE_METAL

#if IS_BARE_METAL == 1
#include "xil_io.h"
#include "stopwatch_controller.h"
#include "xparameters.h"

#define OFFSET(reg) ((reg) << 2) // offset = register number * (32 / 8)

typedef u32 UInt32;

UInt32 ReadRegBareMetal(UInt32 reg) {
    return
        STOPWATCH_CONTROLLER_mReadReg(
            XPAR_STOPWATCH_CONTROLLER_0_S00_AXI_BASEADDR,
            OFFSET(reg)
        );
}

void WriteRegBareMetal(UInt32 reg, UInt32 val) {
    STOPWATCH_CONTROLLER_mWriteReg(
        XPAR_STOPWATCH_CONTROLLER_0_S00_AXI_BASEADDR,
		OFFSET(reg),
		val

    );
}

#else

#include <fcntl.h>
#include <sys/mman.h>
#include <stddef.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

#define XPAR_STOPWATCH_CONTROLLER_0_S00_AXI_BASEADDR 0x43C00000

typedef __uint32_t UInt32;

static UInt32 *stopwatch_ctlr;

UInt32 ReadRegLinux(UInt32 reg) {
    return *(stopwatch_ctlr + reg);
}

void WriteRegLinux(UInt32 reg, UInt32 val) {
    *(stopwatch_ctlr + reg) = val;
}

#endif // IS_BARE_METAL == 1

/*
 * Define the registers of the stopwatch_controller IP core.
 */
#define SSD_REG         0
#define LED_REG         1
#define SWITCH_REG      2
#define BTN_REG         3
#define ENC_REG         4
#define ENC_SW_REG      5
#define ENC_BTN_REG     6
#define TIMER_REG       7

#define BTN_C           16
#define BTN_D           8
#define BTN_R           4
#define BTN_U           2
#define BTN_L           1

typedef UInt32 (*ReadRegFn)(UInt32);
typedef void (*WriteRegFn)(UInt32, UInt32);

typedef struct StopWatch {
    ReadRegFn   ReadReg;
    WriteRegFn  WriteReg;
}
    StopWatch;

void Initialise(void) {

#if IS_BARE_METAL == 1
    /* Do nothing. */
#else
    // TODO: install signal handlers

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        printf("[ERROR] open() with /dev/mem failed.\n");
        exit(errno);
    }

    stopwatch_ctlr =
        (UInt32 *)
        mmap(
            NULL,
            getpagesize(),
            PROT_READ | PROT_WRITE,
            MAP_SHARED,
            fd,
            XPAR_STOPWATCH_CONTROLLER_0_S00_AXI_BASEADDR
        );
    if (stopwatch_ctlr == MAP_FAILED) {
        printf("[ERROR] mmap() with SW_BASE.\n");
        exit(errno);
    }

#endif // IS_BARE_METAL == 1
}

int main(void) {

    /* Initialization section */
    StopWatch sw = {
#if IS_BARE_METAL == 1
        ReadRegBareMetal,
        WriteRegBareMetal
#else
        ReadRegLinux,
        WriteRegLinux
#endif // IS_BARE_METAL == 1
    };

    Initialise();

    UInt32 ssd_val = 0;
    UInt32 led_val = 0;
    UInt32 switch_val = 0;
    UInt32 btn_val = 0;
    UInt32 enc_val = 0;
    UInt32 enc_sw_val = 0;
    UInt32 timer_val = 0;
    UInt32 btn_val_prev = sw.ReadReg(BTN_REG);
    UInt32 timer_zero = sw.ReadReg(TIMER_REG);
    UInt32 stopped = 0;

    while (1) {
        /* Input section */
        switch_val = sw.ReadReg(SWITCH_REG);
        btn_val = sw.ReadReg(BTN_REG);
        enc_val = sw.ReadReg(ENC_REG);
        enc_sw_val = sw.ReadReg(ENC_SW_REG);
        UInt32 btn_val_rise = ~btn_val_prev & btn_val;

        if (!stopped)
            timer_val = sw.ReadReg(TIMER_REG) - timer_zero;

        /* Computation section */
        if (enc_sw_val) {
            /* encoder display */
            ssd_val = enc_val;
            led_val = enc_val;
        } 
        else {
            /* stopwatch functions */
            UInt32 hundredths = (timer_val / 10) % 100;
            UInt32 seconds = (timer_val / 1000) % 60;
            UInt32 minutes = (timer_val / (60 * 1000)) % 60;
            UInt32 hours = (timer_val / (60 * 60 * 1000)) % 24;
            UInt32 days = (timer_val / (24 * 60 * 60 * 1000));

            UInt32 time = hundredths;
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
                    sw.ReadReg(TIMER_REG) - timer_val;
            } 
            else {
                timer_zero = sw.ReadReg(TIMER_REG);
                stopped = 1;
            }
        }

        /* Output section */
        sw.WriteReg(SSD_REG, ssd_val);
        sw.WriteReg(LED_REG, led_val);
        btn_val_prev = btn_val;
    }
    // TODO: release allocated resources

    return 1;
}
