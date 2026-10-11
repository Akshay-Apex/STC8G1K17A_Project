#include <stdint.h>
#include "fw_hal.h"

#define Led_red   P32
#define Led_green P55

void gpio_init(void) {
  GPIO_P5_SetMode(GPIO_Pin_5, GPIO_Mode_Output_PP); 
  GPIO_P3_SetMode(GPIO_Pin_2, GPIO_Mode_Output_PP); 
  GPIO_P3_SetMode(GPIO_Pin_3, GPIO_Mode_Input_HIP);
  GPIO_P5_SetMode(GPIO_Pin_4, GPIO_Mode_Input_HIP);
}

void exti_init(void) {
  EXTI_Int1_SetIntState(1);
  EXTI_Int1_SetTrigByFall;
  EXTI_Int1_SetIntPriority(EXTI_IntPriority_Lowest);
  EA = 1;
}

void adc_init(void) {
  ADC_SetPowerState(1);
  ADC_SetChannel(4);
  ADC_SetResultAlignmentRight();
  ADC_SetClockPrescaler(0);
  ADC_SetChannelSwitchTime(0);
  ADC_SetChannelHoldTime(1);
  ADC_SetSampleTime(10);    
}

void uart_init(void) {
  UART1_SwitchPort(UART1_AlterPort_P30_P31);
  UART1_Config8bitUart(UART1_BaudSource_Timer1, 1, 115200);
}

uint8_t mode = 0;

int main(void) {
  //SYS_SetClock();
  gpio_init();
  exti_init(); 
  adc_init();
  uart_init();  
  
  uint8_t switch_led = 0;

  while(1) {    
    uint16_t adc_val = ADC_ConvertHP();
    UART1_TxString("ADC Value: ");
    UART1_TxInteger(adc_val);
    UART1_TxString("\r\n");    

    adc_val += 1;

    switch(mode) {
      case 0:
        Led_red = RESET;        
        Led_green = SET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        Led_green = RESET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        break;

      case 1:
        Led_green = RESET;
        Led_red = SET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        Led_red = RESET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        break;

      case 2:
        Led_green = SET;
        Led_red = SET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        Led_green = RESET;
        Led_red = RESET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        break;

      case 3:
        if(switch_led) {
          Led_green = RESET;
          for(uint8_t i = 0; i < 4; i++) {
            Led_red = SET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
            Led_red = RESET;
            // SYS_Delay(100);  
            SYS_Delay(adc_val);
          }
        
          switch_led = 0;          
        } else {
          Led_red = RESET;  
          for(uint8_t i = 0; i < 4; i++) {      
            Led_green = SET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
            Led_green = RESET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
          }
          switch_led = 1;
        }        
        break;

      case 4:
        Led_red = RESET;
        Led_green = SET;
        SYS_Delay(500);
        Led_red = SET;
        Led_green = RESET;
        SYS_Delay(500);
        break;

      case 5:
        Led_red = RESET;
        Led_green = SET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        Led_red = SET;
        Led_green = RESET;
        // SYS_Delay(100);
        SYS_Delay(adc_val);
        break;

      case 6:
        if(switch_led) {          
          for(uint8_t i = 0; i < 9; i++) {
            if((i % 3) == 0) {
              Led_green = SET;              
            } else {
              Led_green = RESET;
            }

            Led_red = SET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
            Led_red = RESET;
            // SYS_Delay(100);  
            SYS_Delay(adc_val);
          }
        
          switch_led = 0;          
        } else {
          Led_red = RESET;  
          for(uint8_t i = 0; i < 9; i++) {     
            if((i % 3) == 0) {
              Led_red = SET;  
            } else {
              Led_red = RESET;  
            }

            Led_green = SET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
            Led_green = RESET;
            // SYS_Delay(100);
            SYS_Delay(adc_val);
          }
          switch_led = 1;
        }  
        break;
      
      default:
        break;
      }          
  }    
}


void handle_func(void) __interrupt (EXTI_VectInt1) {
  mode = (mode + 1) % 7;
}
