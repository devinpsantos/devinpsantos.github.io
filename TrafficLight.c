// TrafficLight.c
// Runs TM4C123
// Index implementation of a Moore finite state machine to operate
// a traffic light.
// Your Name: Devin Santos 
// created: 10-7-19
// last modified: 
// 

// include headers 
#include <stdio.h>
#include "tm4c123gh6pm.h"



// Linked data structure
struct state{
	int dlights;  // port d light output
	int clights;  // port c light output
	int wait;     // time to stay in state before switching states
	
	struct state *next[16];  // next state based off 16 different possible inputs
};

typedef struct state stype;

stype sstate[6];

//define your states here e.g. #define stateName 0, etc.
#define IG          &sstate[0]
#define IY          &sstate[1]
#define FG          &sstate[2]
#define FY          &sstate[3]
#define IG_FW       &sstate[4]
#define BR_BW       &sstate[5]

//Declare your states here 
//FSM
stype sstate[6] = {
	{ 0x0C, 0x00, 70, {IG,IG,IY,IY,IY,IY,IY,IY,IG_FW,IG_FW,IY,IY,IY,IY,IY,IY} },
  { 0x0A, 0x00, 20, {FG,FG,FG,FG,BR_BW,BR_BW,BR_BW,BR_BW,BR_BW,BR_BW,FG,FG,BR_BW,BR_BW,BR_BW,FG} },
  { 0x01, 0x20, 70, {FY,FY,FG,FY,FY,FY,FY,FY,FY,FY,FY,FY,FY,FY,FY,FY} },
  { 0x01, 0x10, 20, {IG,IG,IG,IG,BR_BW,IG,BR_BW,IG,IG_FW,IG_FW,IG_FW,IG_FW,BR_BW,BR_BW,BR_BW,BR_BW} },
  { 0x8C, 0x40, 70, {IG,IG,IY,IY,IY,IY,IY,IY,IG_FW,IG_FW,IY,IY,IY,IY,IY,IY} },
  { 0xC9, 0x40, 40, {IG,IG,FG,IG,BR_BW,IG,FG,IG,IG_FW,IG_FW,FG,IG,BR_BW,IG,FG,IG} }
}; 
									

void SysTick_Init(void);
void SysTick_Wait(unsigned long delay);
void SysTick_Wait10ms(unsigned long delay);
//void PLL_Init(void);
void PortD_Init(void);
void PortB_Init(void);
void PortC_Init(void); 	

									
	



int main(void){ volatile unsigned long delay;

	// initialize Ports, SysTick and PLL here . 
	  
	  stype *ptr;
	  ptr = IG;
	
	
	  PortD_Init();
	  PortC_Init();
	  PortB_Init();
	  //PLL_Init();
	  SysTick_Init();
	  
	  
	
	
	
  while(1){
  //your code goes here to move from one state to another. 
		
		int sensor; 
		
		GPIO_PORTD_DATA_R = ptr->dlights;  // current state outputs lights from port d
		
		GPIO_PORTC_DATA_R = ptr->clights;  // current state outputs lights from port c 
		
		SysTick_Wait10ms(ptr->wait);       // waits the amount of time that is necessary for that state
		
		sensor = GPIO_PORTB_DATA_R;    // reads the input from cars and walk
		
		ptr = ptr->next[sensor];          // ptr gets address of next state based on input
		
		
		
		
  }
}


void PortD_Init(void) {
	 unsigned long delay;
	 SYSCTL_RCGC2_R |= 0x08;  // enables port d 
	 delay = 5;
	 delay = 4; 
	 GPIO_PORTD_DIR_R |= 0xCF; // d7,d6,d3,d2,d1,d0 outputs
	 GPIO_PORTD_DEN_R |= 0xCF; // outputs are digital 
	 GPIO_PORTD_AMSEL_R = 0x00;
	 GPIO_PORTD_AFSEL_R = 0x00; 
	
	}

	
void PortC_Init(void) {
	unsigned long delay; 
	SYSCTL_RCGC2_R |= 0x04; // enables port c 
	delay = 1;
	delay = 2; 
	GPIO_PORTC_DIR_R |= 0x70; // c4,c5,c6 outputs
	GPIO_PORTC_DEN_R |= 0x70; 
	GPIO_PORTC_AMSEL_R = 0x00;
	GPIO_PORTC_AFSEL_R = 0x00; 
	
	
}

void PortB_Init(void) {
	unsigned long delay; 
	SYSCTL_RCGC2_R |= 0x02; // enables port b
	delay = 5; 
	delay = 1; 
	GPIO_PORTB_DIR_R &= 0xF0; // pb0,pb1,pb2,pb3 inputs
	GPIO_PORTB_DEN_R |= 0x0F; // digital enable
	GPIO_PORTB_AMSEL_R = 0x00;
	GPIO_PORTB_AFSEL_R = 0x00; 
	
}
