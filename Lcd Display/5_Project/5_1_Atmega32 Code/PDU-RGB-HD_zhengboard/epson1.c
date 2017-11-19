//******************************************************************************
//! @file $RCSfile: epson1.c,v $
//!
//! 
//!
//! @brief PDU  Controller embeded 
//!	for 3 Panels HDTV
//!
//! @version $Revision: 1.00 $ 
//!
//! @todo
//! @bug
//******************************************************************************

//===1080P Format===default timing

// Dotclk	148.5MHz
// H total	2200
// H display	1920
// H back porch	192
// V total	1125
// V display	1080
// V back porch	36




//_____ I N C L U D E S ________________________________________________________

#include <avr/io.h>
#include <avr/eeprom.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/boot.h>

//F_CPU must be defined before this //is defined in project options
#include <util/delay.h>

#include "compiler.h"
#include "uart.c"


//______F U S E S  and L O C K B I T S__________________________________________
//
//fuses and lock bits will be readly set in elf file. see programmer for details


FUSES = {
        .low = 0xbe,
        .high = 0xd1
		};

LOCKBITS = 0xfc;



//______DEFINITIONS______________________________________________


//PORTB map

#define SCS				3		//ChipSelect 7130
//#define P_SCS			1		//ChipSelect all Panels parallel
#define R_SCS			2		//ChipSelect red Panel
#define G_SCS			1		//ChipSelect green Panel
#define B_SCS			0		//ChipSelect blue Panel

#define SCS_PORT			PORTB
//#define P_SCS_PORT			PORTB
#define R_SCS_PORT			PORTB
#define G_SCS_PORT			PORTB
#define B_SCS_PORT			PORTB



//;PORTC map
#define RESETCHIP		7		//7130 X_Reset
#define PX_RESET		6		//Panel X_Reset
#define SRCS			1		//7130 Chip Select for read
#define MISO			0		//7130 Read Data input

#define RESETCHIP_PORT	PORTC
#define PX_RESET_PORT	PORTC
#define SRCS_PORT		PORTC

#define MISO_PORT		PINC


//;PORTD map 
#define SCLK 			7		//I2C Clock
#define SDATA 			6		//I2C Data				
#define DF_SELECT 		5		//DataFlash Select
#define POWER15 		4		//15V Power on
#define VSENSE			3		//Voltage Sense input
#define SCDT 			2		//Signal OK input

#define SDATA_PORT			PORTD
#define SCLK_PORT			PORTD
#define DF_SELECT_PORT		PORTD
#define POWER15_PORT		PORTD

#define VSENSE_PORT			PIND
#define SCDT_PORT			PIND


//initial values of Ports and Data direction registers

#define	DDRA_INIT 	0x00	//;switch Porta to input (DA Converter)
#define	DDRB_INIT 	(1<<SCS | 1<<R_SCS | 1<<G_SCS | 1<<B_SCS)	//;Set direction of portb
#define	DDRC_INIT 	(1<<RESETCHIP | 1<<PX_RESET | 1<<SRCS)
#define	DDRD_INIT 	(1<<SCLK | 1<<SDATA | 1<<DF_SELECT | 1<<POWER15)

#define PORTB_INIT 		(1<<SCS | 1<<R_SCS | 1<<G_SCS | 1<<B_SCS)	//all chipselect high
#define PORTC_INIT		(1<<SRCS)
#define PORTD_INIT		(1<<SCLK | 1<<DF_SELECT)

//default value for flicker when EEPROM is erased
#define FLICKERDEFAULT	185

//LUT Base Address
#define LUTR	((U16*)0x3000)
#define LUTG	((U16*)0x3000)
#define LUTB	((U16*)0x3000)



U8 tmpport = 1;
U8 buffer[600];




//_____ D E C L A R A T I O N S ________________________________________________

/*

PROGMEM U16 LUT[] = { \
	0,400,800,1200,1400,1500,1600,1650,1700,1740,1780,1810,1840,1870,\
	1900,1920,1940,1960,1980,2000,2020,2038,2054,2068,2075,2079,2082,\
	2086,2089,2093,2096,2100,2103,2107,2110,2114,2117,2121,2124,2128,\
	2131,2135,2138,2142,2145,2149,2152,2156,2159,2163,2166,2170,2173,\
	2177,2180,2184,2187,2191,2194,2198,2201,2205,2208,2212,2215,2219,\
	2222,2226,2229,2233,2236,2240,2243,2247,2250,2254,2257,2261,2264,\
	2268,2271,2275,2278,2282,2285,2289,2292,2296,2299,2303,2306,2310,\
	2313,2317,2320,2324,2327,2331,2334,2338,2341,2345,2348,2352,2355,\
	2359,2362,2366,2369,2373,2376,2380,2383,2387,2390,2394,2397,2401,\
	2404,2408,2411,2415,2418,2422,2425,2429,2432,2436,2439,2443,2446,\
	2450,2453,2457,2460,2464,2467,2471,2474,2478,2481,2485,2488,2492,\
	2495,2499,2502,2506,2509,2513,2516,2520,2523,2527,2530,2534,2537,\
	2541,2544,2548,2551,2555,2558,2562,2565,2569,2572,2576,2579,2583,\
	2586,2590,2593,2597,2600,2604,2607,2611,2614,2618,2621,2625,2628,\
	2632,2635,2639,2642,2646,2649,2653,2656,2660,2663,2667,2670,2674,\
	2677,2681,2684,2688,2691,2695,2698,2702,2705,2709,2712,2716,2723,\
	2730,2737,2744,2751,2758,2765,2772,2779,2786,2793,2800,2807,2814,\
	2821,2828,2835,2842,2849,2860,2874,2890,2906,2922,2938,2954,2970,\
	2986,3002,3018,3034,3050,3066,3082,3098,3114,3130,3146,3162,3178,\
	3194,3210,3226,3242,3258,3274,3290,3306,3500};

*/


//7130

//timingregs 0xc00 .. 0xc3f	//basic timing and test pattern
PROGMEM U16 timingregs[] = {					\
0x53F,0x7FF,0x7FF,0x310,0x000,0x001,0x012,0x012,\
0x012,0x000,0x000,0x000,0x000,0x000,0x020,0x020,\
0x020,0x000,0x000,0x111,0x000,0x000,0x00B,0x000,\
0x01C,0x035,0x00D,0x000,0x000,0x1a4,0x000,0x002,\
0x000,0x008,0x000,0x300,0x000,0x000,0x0BC,0x780,\
0x024,0x438,0x002,0x000,0x007,0x031,0x1e0,0x59f,\
0x10e,0x329,0x00d,0x06f,0x010,0x040,0x005,0x005,\
0x300,0x300,0x0c0,0x300,0x000,0x000,0x000,0x000 \
};

//mselregs 0xd30 .. 0xd3c
//PROGMEM U16 mselregs[] = {0x010,0x044,0x075,0x0A6,0x0D7,0x108,0x139,0x16A,0x19B,0x1E6,0x024,0x02B,0x018};//alt
PROGMEM U16 mselregs[] = {0x01c,0x05c,0x08d,0x0be,0x0ef,0x120,0x151,0x182,0x1b3,0x1fc,0x015,0x02b,0x014};



//LVDS input mapping 0xd90 .. 0xdb5
//v,h,r0..11,g0..11,b0..11
//PROGMEM U16 LVDSmap[] = {2,1,0,0,0,0,0,0,0,7,6,5,4,3,0,0,0,0,0,0,0,7,6,5,4,3,0,0,0,0,0,0,0,7,6,5,4,3,0,0};
/*
PROGMEM U16 LVDSmap[] = {2,1,0x1d,0x1c,0x1b,0x1a,0x19,0x17,0x16,0x15,0x14,0x13,0x12,0x11,\
							 0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x07,0x06,0x05,0x04,0x03,\
							 0x00,0x00,0x00,0x27,0x26,0x25,0x24,0x23,0x22,0x21,0x1f,0x1e,0,0};

*/


///*
//BBS testquelle
//v,h,r0..11,g0..11,b0..11
PROGMEM U16 LVDSmap[] = {2,1,0x1d,0x1c,0x1b,0x1a,0x19,0x17,0x16,0x15,0x14,0x13,0x12,0x11,\
							 0x00,0x00,0x00,0x27,0x26,0x25,0x24,0x23,0x22,0x21,0x1f,0x1e,\
							 0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x07,0x06,0x05,0x04,0x03,0,0};
//*/




//0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x07,0x06,0x05,0x04,0x03,

//Panel registers 0xf00..0xf10 (0..16)
PROGMEM	U16 panelconfig[] = {8,0,1,0,5,0,0xec0,0x200,0x800,0x0b1,1,0,1,0,2,0x010,1};


//EEPROM dummy reg 0xc1e = 0
U8 EEMEM u8_eedata[] =	{	1, \
							0x50, 0x20, 0x00 	};



//brightness:	reg 0x502 = 0
//contrast:		reg 0x501 = 0x800


//_____ F U N C T I O N S ______________________________________________________

//------------------------------------------------------------------------------


//code to program the flash memory must be in bootloader section
BOOTLOADER_SECTION void program_flash (uint32_t page, uint8_t *buf)
{
	uint16_t i;
	uint8_t sreg;
	// Disable interrupts.

	sreg = SREG;
	cli();
	eeprom_busy_wait ();
	boot_page_erase (page);
	boot_spm_busy_wait (); // Wait until the memory is erased.
	for (i=0; i<SPM_PAGESIZE; i+=2)
	{
	// Set up little-endian word.
	uint16_t w = *buf++;
	w += (*buf++) << 8;

	boot_page_fill (page + i, w);
	}
	boot_page_write (page); // Store buffer in flash page.
	boot_spm_busy_wait(); // Wait until the memory is written.
	// Reenable RWW-section again. We need this if we want to jump back
	// to the application after bootloading.
	boot_rww_enable ();
	// Re-enable interrupts (if they were ever enabled).
	SREG = sreg;
}


/*
void Sendcontrolword(U8* p_byte)
{
	U8 bytecount, bitcount;


	Clr_bit_x(&SCS_PORT, 1<<SCS);	//SCS goes low

	for(bytecount = 0; bytecount < 3; bytecount++)
	{
		for(bitcount = 7; bitcount < 8; bitcount--)	//send MSB first
		{
			Clr_bit_x(&SCLK_PORT, 1<<SCLK);	//clock fall

			if(p_byte[bytecount] & (1<<bitcount))	//test bit to send
				Set_bit_x(&SDATA_PORT, 1<<SDATA);		//set data pin
			else
				Clr_bit_x(&SDATA_PORT, 1<<SDATA);		//or clear data pin

			Set_bit_x(&SCLK_PORT, 1<<SCLK);	//clock rise
		}
	}



	Set_bit_x(&SCS_PORT, 1<<SCS);	//SCS goes high
}


void Sendcontrolword3(U16 addr, U16 data)
{
	U8 bytes[3];

	bytes[0] = (U8)(addr>>4);
	bytes[1] = ((addr<<4)&0xf0) | ((data>>8)&0x0f);
	bytes[2] = (U8) data;
	
	Sendcontrolword(bytes);
}


void ConfigPanel2(U16 addr, U16 data)
{
	U8 bytes[3];
	U8 bytecount, bitcount;

	bytes[0] = (U8)(addr>>4);
	bytes[1] = ((addr<<4)&0xf0) | ((data>>8)&0x0f);
	bytes[2] = (U8) data;

	Clr_bit_x(&P_SCS_PORT, 1<<P_SCS);	//SCS goes low
	
	for(bytecount = 0; bytecount < 3; bytecount++)
	{
		for(bitcount = 7; bitcount < 8; bitcount--)	//send MSB first
		{
			Clr_bit_x(&SCLK_PORT, 1<<SCLK);	//clock fall

			if(bytes[bytecount] & (1<<bitcount))	//test bit to send
				Set_bit_x(&SDATA_PORT, 1<<SDATA);		//set data pin
			else
				Clr_bit_x(&SDATA_PORT, 1<<SDATA);		//or clear data pin

			
			__asm__("nop");
			Set_bit_x(&SCLK_PORT, 1<<SCLK);	//clock rise
		}
	}


	Set_bit_x(&P_SCS_PORT, 1<<P_SCS);	//SCS goes high
}
*/



void ConfigSerial(U16 addr, U16 data)
{
	U8 bytes[3];
	U8 bytecount, bitcount;
	U8 ChipSelectMask;


	//select the correct ChipSelect line
	if((addr >=0xf00) && (addr <= 0xf1f))		ChipSelectMask = (1<<R_SCS | 1<<G_SCS | 1<<B_SCS);
	else if((addr >=0xf20) && (addr <= 0xf3f))	ChipSelectMask = 1<<R_SCS;
	else if((addr >=0xf40) && (addr <= 0xf5f))	ChipSelectMask = 1<<G_SCS;
	else if((addr >=0xf60) && (addr <= 0xf7f))	ChipSelectMask = 1<<B_SCS;
	else	ChipSelectMask = 1<<SCS;

	
	if((addr >=0xf00) && (addr <= 0xf7f))	addr = (0xf00 | (addr & 0x1f));

	bytes[0] = (U8)(addr>>4);
	bytes[1] = ((addr<<4)&0xf0) | ((data>>8)&0x0f);
	bytes[2] = (U8) data;




	Clr_bit_x(&SCS_PORT, ChipSelectMask);	//SCS goes low
	
	for(bytecount = 0; bytecount < 3; bytecount++)
	{
		for(bitcount = 7; bitcount < 8; bitcount--)	//send MSB first
		{
			Clr_bit_x(&SCLK_PORT, 1<<SCLK);	//clock fall

			if(bytes[bytecount] & (1<<bitcount))	//test bit to send
				Set_bit_x(&SDATA_PORT, 1<<SDATA);		//set data pin
			else
				Clr_bit_x(&SDATA_PORT, 1<<SDATA);		//or clear data pin

			
			__asm__("nop");
			Set_bit_x(&SCLK_PORT, 1<<SCLK);	//clock rise
		}
	}

	Set_bit_x(&SCS_PORT, ChipSelectMask);	//Chip Select goes high
}



void SetLut()
{
	U16 n, data;
	U16* lutaddr;
	
	ConfigSerial(0xc24, 0x082);	//12 bit LUT //LUT disabled

	lutaddr = LUTG;
	
	for(n=0; n<257; n++)
	{
		data = pgm_read_word(lutaddr++);
		ConfigSerial(0x400 + n, data);
	}
}


void CommandWriteFlash()
{
	U16 i, address;
	address = 0;
	i = 0;

	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[i++] = USART_Receive();
		
			if(i==2)
			{
				address = buffer[0]<<8 | buffer[1];
				break;
			}
		}
	}
	
	i=0;
	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
		buffer[i++] = USART_Receive();

		if(i==128)
		{
			if(address < 0x1000) break;
			if(address >= 0x7000) break;
			program_flash(address,buffer);
			break;
		}
	}

}

void CommandWriteEEProm()
{
	U16 i, address;
	//U8 buffer[300];

	i = 0;

	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[i++] = USART_Receive();
		
			if(i==3)
			{
				address = buffer[0]<<8 | buffer[1];
				eeprom_write_byte (&u8_eedata[address], buffer[2]);
				break;
			}
		}
	}
}

void CommandReadEEProm()
{
	U16 i, address;

	i = 0;

	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[i++] = USART_Receive();
		
			if(i==2)
			{
				address = buffer[0]<<8 | buffer[1];
				USART_Transmit( eeprom_read_byte(&u8_eedata[address]) );
				break;
			}
		}
	}

}


void CommandWriteChip()
{
	U16 i, addr, data;

	i = 0;

	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[i++] = USART_Receive();

			if(i==4)
			{
				addr = ((buffer[0]<<8) | buffer[1]) &0x0fff;
				data    = ((buffer[2]<<8) | buffer[3]) &0x0fff;
				
				ConfigSerial(addr, data);

				break;
			}
		}
	}
}

void CommandChipBlock1()
{
	U16 i,k;
	//U8 buffer[300];

	i = 0;
	k=0;


	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[0] = USART_Receive();

			ConfigSerial(0xffd , buffer[0]);
			i++;
			if(i==(3*221)) break;
		}
	}

}

void CommandChipBlockInc()
{
	U16 i, addr, data, count;

	i = 0;
	count = 1;
	addr = 0; //makes the compiler happy


	while(Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
	
		if(USART_DataReceived())
		{
			buffer[i++] = USART_Receive();

			if(i==4)	//evaluate address and count
			{
				addr = ((buffer[0]<<8) | buffer[1]) &0x0fff;
				count = ((buffer[2]<<8) | buffer[3]) &0x0fff;
			}	
			if((i>5) && ((i&0x1) == 0))	//evaluate data
			{
				//addr = base + ((i-6)>>1);
				data = ((buffer[i-2]<<8) | buffer[i-1]) &0x0fff;
				
				ConfigSerial(addr, data);
				
				addr++;
			}

			if(i==4+(count<<1)) break;
		}
	}
}


void ExtendedCommand()
{
	U8 command;


	command = 0;

	while (Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//Wait for Sync Detect SCDT end
	{
		if(USART_DataReceived())
		{
			command = USART_Receive();
			switch(command)
			{
			case 1:
				CommandWriteFlash();
				break;
			case 2:
				CommandWriteChip();
				break;
			case 3:
				CommandWriteEEProm();
				break;
			case 4:
				CommandChipBlock1();
				break;
			case 5:
				CommandReadEEProm();
				break;
			case 6:
				CommandChipBlockInc();
				break;

			}
			break; //leave ExtendedCommand()
		}

	}
}

void DoEEPROM()
{
	U16  bcount, addr, data;
	U8 i, bytes[3], nwords, n, eedata;

	nwords = eeprom_read_byte(&u8_eedata[0]);

	//return if EEPROM is erased
	if(nwords == 0xff) return;

	bcount = 1;

	for(n=0; n<nwords; n++)
	{
		for(i=0; i<3; i++)
		{
			bytes[i] = eeprom_read_byte(&u8_eedata[bcount]);
			bcount++;
		}
		//Sendcontrolword(bytes);
		addr = (bytes[0]<<4) | (bytes[1]>>4);
		data = ((bytes[1]<<8) | (bytes[2]))&0x0fff;

		ConfigSerial(addr, data);

	}

	//overwrite flicker default values
	//flicker config red
	eedata = eeprom_read_byte(&u8_eedata[0x03ff]);
	if(eedata != 0xff) ConfigSerial(0xf29, eedata);
	//else ConfigSerial(0xf29, FLICKERDEFAULT);

	//flicker config green
	eedata = eeprom_read_byte(&u8_eedata[0x03fe]);
	if(eedata != 0xff) ConfigSerial(0xf49, eedata);
	//else ConfigSerial(0xf49, FLICKERDEFAULT);

	//flicker config blue
	eedata = eeprom_read_byte(&u8_eedata[0x03fd]);
	if(eedata != 0xff) ConfigSerial(0xf69, eedata);
	//else ConfigSerial(0xf69, FLICKERDEFAULT);

	//ConfigSerial(0xf09, 215);

}



void DoUniformity()
{
	U16 i;
	U8 data, *adrmin, *adrmid, *adrmax, *adrconfig;

	adrmin = (U8*)0x1400;
	adrmid = (U8*)0x1800;
	adrmax = (U8*)0x1c00;
	
	adrconfig = (U8*)0x2000;

/*
    Sendcontrolword2(0xc85, 0);		//16x12 segments

    Sendcontrolword2(0xc81, 0x104);	//startpoint x
    Sendcontrolword2(0xc82, 0x00b);	//startpoint y
    Sendcontrolword2(0xc83, 0x4c3);	//endpoint x
    Sendcontrolword2(0xc84, 0x441);	//endpoint y

    Sendcontrolword2(0xc86, 0x004);	//x coeff h
    Sendcontrolword2(0xc87, 0x044);	//x coeff l
    Sendcontrolword2(0xc88, 0x002);	//y coeff h
    Sendcontrolword2(0xc89, 0x0d8);	//y coeff l

    //temp = ((int) numericUpDown1.Value)/4;
    Sendcontrolword2(0xca0, 0);//(int) numericUpDown1.Value);	//min bright
    
    //temp = ((int) numericUpDown2.Value)/4;
    Sendcontrolword2(0xca1, 0x1ff);	//mid bright

    //temp = ((int) numericUpDown3.Value)/4;
    Sendcontrolword2(0xca2, 0x3ff);	//max bright
    //SendChipDirect(0xca3, (int) numericUpDown3.Value);	//max bright

    //temp = 0x100000 / ((int)(numericUpDown2.Value - numericUpDown1.Value));
    Sendcontrolword2(0xc90, 1);	//l1 coeff h
    Sendcontrolword2(0xc91, 0);	//l1 coeff l

    //temp = 0x100000 / ((int)(numericUpDown3.Value - numericUpDown2.Value));
    Sendcontrolword2(0xc92, 1);	//l2 coeff h
    Sendcontrolword2(0xc93, 0);	//l2 coeff l

*/

//////////////////write config from flash

	U16 n, ad16, da16, th, tl;
	n=16;

	for(i=0; i<n; i++)
	{
		th = pgm_read_byte(adrconfig++);
		tl = pgm_read_byte(adrconfig++);

		ad16 = th<<8 | tl;

		th = pgm_read_byte(adrconfig++);
		tl = pgm_read_byte(adrconfig++);

		da16 = th<<8 | tl;

		ConfigSerial(ad16, da16);
	}

    ConfigSerial(0xc80, 0x001);	//Reset address counter


	for(i=0; i<221; i++)
	{
		data = pgm_read_byte(adrmin++);
		ConfigSerial(0x4ffd, data);		//0x4ffd  ???
		data = pgm_read_byte(adrmid++);
		ConfigSerial(0x4ffd, data);
		data = pgm_read_byte(adrmax++);
		ConfigSerial(0x4ffd, data);
	}

    ConfigSerial(0xc80, 0x010);	//Switch on correction

}

void InitPanels()
{
	U16 n, data;

	//init Panel registers
	for(n = 0; n <= 0xf10-0xf00; n++)
	{
		data = pgm_read_word(&panelconfig[n]);
		ConfigSerial(n+0xf00,data);
	}
}




//______F U N C T I O N    M A I N__________________________________________

int main (void)
{

	U8 i, inbuffer;
	U16 n, bcount, data;


	while(TRUE)	// loop forever
	{


////Port init


		PORTB = PORTB_INIT; //
		PORTC = PORTC_INIT;	//
		PORTD = PORTC_INIT;	//


		DDRA = DDRA_INIT;	//;switch Porta to input //analog
		DDRB = DDRB_INIT;	//;Set direction of portb
		DDRC = DDRC_INIT; 	//;Set direction of portc
		DDRD = DDRD_INIT; 	//;Set direction of portd




////UART init
		USART_Init(25);	//9600 baud


		for(n=0;n<10000;n++)
		{
			Clr_bit_x(&RESETCHIP_PORT, 1<<RESETCHIP);	//reset 7130  //wait till 7120 stabilised
		}




		while (!Tst_bit_x(&SCDT_PORT, 1<<SCDT));	//Wait for Sync Detect SCDT 




		for(n=0;n<40000;n++)
		{
			Set_bit_x(&RESETCHIP_PORT, 1<<RESETCHIP);	//end resetting 7130  //wait till PLL locks
		}




////Send Controlwords from Flash for basic operation
		
		//timing
		for(n=0; n<=0xc3f-0xc00; n++)
		{
			data = pgm_read_word(&timingregs[n]);
			ConfigSerial(n+0xc00, data);
		}

		//SRAM D01h ... D04h

		U16 SRAM[] = {0x030,0x024,0x1e0,0x438};

		for(n=0; n<=0xd04-0xd01; n++)
		{
			//data = pgm_read_word(&sramregs[n]);
			ConfigSerial(n+0xd01, SRAM[n]);
		}

		//D0Ch
		ConfigSerial(0xd0c, 0x800); ///brightness override value out of valid range
										///therefore uniformity start and endpoints Reg 0xc81 .. 0xc84
										///must be set. If not the hole image will be overwritten
		
		//C80h .. C84h	uniformity disabe, start and endpoints (image valid range)
		U16 UnifPos[] = {0,0x030,0x024,0x20f,0x45b};

		for(n=0; n<=0xc84-0xc80; n++)
		{
			ConfigSerial(n+0xc80, UnifPos[n]);
		}
				
		//D5 pins D1Ah ... D1Fh	//needed?
		U16 D5drive[] = {0x030,0x216,0x024,0x00E,0x000,0x030};

		for(n=0; n<=0xd1f-0xd1a; n++)
		{
			//data = pgm_read_word(&sramregs[n]);
			ConfigSerial(n+0xd1a, D5drive[n]);
		}

		
		//LVDSmap 0xd90 .. 0xb7
		for(n=0; n<40; n++)
		{
			data = pgm_read_word(&LVDSmap[n]);
			ConfigSerial(n+0xd90, data);
		}
	
	
		//MSEL
		for(n=0; n<=0xd3c-0xd30; n++)
		{
			data = pgm_read_word(&mselregs[n]);
			ConfigSerial(n+0xd30, data);
		}


		

////Initialize Uniformity Correction
		//DoUniformity();


////Initialize LUT
		//SetLut();


////init LCD 
	//output black 
	//P_XRESET goes high
	Set_bit_x(&PX_RESET_PORT, 1<<PX_RESET);

//delay

	InitPanels();


////delay

////Send Controlwords from EEPROM
		DoEEPROM();

		//switch on 15V
		Set_bit_x(&POWER15_PORT, 1<<POWER15);
		//wait 5 frames 
		//output normal image.


		U16 nwords, writecount, wordstowrite;

		writecount = 0;
		wordstowrite = 0;	//dummy to make the compiler happy


////////while(TRUE);//stop here////////////////////////////////////////////////////////

		//clear USART input buffer in case it isnt empty
		USART_Flush();

		while (Tst_bit_x(&SCDT_PORT, 1<<SCDT))	//loop till Sync Detect SCDT end
		{
			//poll UART
			if(USART_DataReceived())
			{
				inbuffer = USART_Receive();
				if (writecount == 0) wordstowrite = inbuffer;//first byte is number of controlwords

				if(wordstowrite == 255)	//new commands
				{
					ExtendedCommand();
				}
				
				
				
				else if(wordstowrite == 0)	//transmit stored data
				{
					nwords = eeprom_read_byte(&u8_eedata[0]);

					USART_Transmit( eeprom_read_byte(&u8_eedata[0]) );

					bcount = 1;

					for(n=0; n<nwords; n++)
					{
						for(i=0; i<3; i++)
						{
							USART_Transmit( eeprom_read_byte(&u8_eedata[bcount]) );
							bcount++;
						}
					}
				}
				else
				{
					 //write eeprom //write byte only if it is modified
     				if( inbuffer != eeprom_read_byte(&u8_eedata[writecount]) ) eeprom_write_byte(&u8_eedata[writecount], inbuffer);

					writecount++;
					//restart if all controlwords are received
					if(writecount == (3*wordstowrite+1)) 
					{
						DoEEPROM();
						
						writecount = 0;
						wordstowrite = 0;
					}
				}

			}

		}
////SCDT has gone low
////switch off LCD and driver


		//Panel off sequence

		//output black
		ConfigSerial(0x501, 0);
		ConfigSerial(0x502, 0);
		
		//switch off panels
		ConfigSerial(0xf0c,1);
		ConfigSerial(0xf11,3);
		//wait 2 frames
			
		for(n=0;n<30000;n++)
		{
			i++;
		}
		//power off LCD
		Clr_bit_x(&POWER15_PORT, 1<<POWER15);


		//reset Chips and panel
		Clr_bit_x(&RESETCHIP_PORT, 1<<RESETCHIP);	
		Clr_bit_x(&PX_RESET_PORT, 1<<PX_RESET);

		
		//wait till restart again
		for(n=0;n<30000;n++)
		{
			i++;
		}


	}
} 
