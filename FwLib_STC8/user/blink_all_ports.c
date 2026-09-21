#include "fw_hal.h"

void GPIO_Init(void)
{
    // Configure all available pins on Port 3 and Port 5 to Strong Push-Pull Output
    GPIO_P3_SetMode(GPIO_Pin_All, GPIO_Mode_Output_PP);
    GPIO_P5_SetMode(GPIO_Pin_All, GPIO_Mode_Output_PP);
}

int main(void)
{
    SYS_SetClock(); 
    GPIO_Init();

    while(1)
    {

        P3 = 0xFF;
        P5 = 0x00;
        SYS_Delay(500);
        
        P3 = 0x00;
        P5 = 0xFF;
        SYS_Delay(500);
    }
}
