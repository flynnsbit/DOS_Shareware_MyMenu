/***********************************************/
/* Omega AWE32 module player v0.6              */
/* This file is written by Cygnus X-1          */
/*                                             */
/* You can use this file in any way you want!! */
/***********************************************/
/***********************************************/
/* modified by Markus Hein                     */
/* (heinm@cs.tu-berlin.de)                     */
/* for use with Borland C++                    */
/* and optional sample interpolating           */
/* (experimental !)                            */
/***********************************************/

/************/
/* Includes */
/************/
#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <string.h>
#include <time.h>

/*************************/
/* Compiler Dependencies */
/*************************/
#ifdef __BCPLUSPLUS__                           // Borland C++

#include <graphics.h>
#define _CPPARGS        ...
#define WHITE           15
#define BLACK           0
#define GREY            7
#define DKGREY          8
#define _DEFAULTMODE    0
#define _VRES16COLOR    1
#define FONT_WIDTH      7.8
#define FONT_HEIGHT     15
#define _outpw(adress,value)    BC_outpw(adress,value)
#define _inpw(adress)           BC_inpw(adress)
#define _outp(adress,value)     BC_outp(adress,value)
#define _inp(adress)            BC_inp(adress)
#define _settextposition(x,y)   BC_settextposition(x,y)
#define _outtext(string)        BC_outtext(string)
#define _setcolor(color)        BC_setcolor(color)
#define _rectangle_w(attribut,x1,y1,x2,y2)      \
				BC_rectangle_w(x1,y1,x2,y2)
#define _initgraphics()         BC_initgraphics()
#define _clearscreen(attribut)  BC_clearscreen()
#define _setvideomode(mode)     BC_setvideomode(mode)
#define _kbhit()                BC_kbhit()
#define _getch()                BC_getch()

void BC_outpw(unsigned adress, unsigned value)
	{
	outpw(adress,value);
	}

unsigned BC_inpw(unsigned adress)
	{
	return(inpw(adress));
	}

void BC_outp(unsigned adress, unsigned value)
	{
	outp(adress,value);
	}

int BC_inp(unsigned adress)
	{
	return(inp(adress));
	}

void BC_settextposition(int x, int y)
	{
	moveto(y*FONT_WIDTH,x*FONT_HEIGHT);
	}

void BC_outtext(char *string)
	{
	int color=getcolor();
	int x=getx(), y=gety();

	setfillstyle(SOLID_FILL,BLACK);
	bar(x,y,x+strlen(string)*FONT_WIDTH,y+FONT_HEIGHT);
	setcolor(WHITE);
	outtext(string);
	setcolor(color);
	}

void BC_setcolor(int color)
	{
	setcolor(color);
	}

void BC_rectangle_w(int x1, int y1, int x2, int y2)
	{
	setfillstyle(SOLID_FILL,getcolor());
	bar(x1,y1,x2,y2);
	}

void BC_initgraphics(void)
	{
	int gdriver=VGA, gmode=VGAHI;
	registerbgidriver(EGAVGA_driver);
	initgraph(&gdriver,&gmode,"");
	if (graphresult() != 0)
		{
		cout << "Cannot initialize graphic mode !";
		exit(1);
		}
	restorecrtmode();
	}

void BC_clearscreen(void)
	{
	cleardevice();
	}

void BC_setvideomode(int mode)
	{
	if (mode == _VRES16COLOR)
		setgraphmode(VGAHI);
	if (mode == _DEFAULTMODE)
		restorecrtmode();
	}

int BC_kbhit(void)
	{
	return(kbhit());
	}

int BC_getch(void)
	{
	return(getch());
	}

#else                                           // MS C++

#include <graph.h>
#define _CPPARGS
#define _initgraphics()
#define WHITE   15
#define BLACK   0
#define GREY    7
#define DKGREY  10
#endif

/**************/
/* Structures */
/**************/
struct ChannelInfo
	{
	unsigned long StartAddr;
	unsigned long LoopStart;
	unsigned long LoopEnd;
	unsigned long Offset;
	int Pitch;
	int Period;
	char Finetune;
	char Volume;
	char VolumeSlide;
	int PitchSlide;
	int PortamentoSpeed;
	unsigned char Reverb;
	unsigned char Chorus;
	unsigned char Pan;
	char AWE32Chan;
	char Status;
	char FirstNote;
	unsigned char Env2Decay;
	unsigned char Env2Sustain;
	int MaxSlide;
	int MinSlide;
	unsigned char VibSpeed;                                                                 // Vibrato speed
	unsigned char VibDepth;                                 // Vibrato depth
	unsigned char TremSpeed;                                // Tremolo speed
	unsigned char TremDepth;                                // Tremolo depth
	unsigned int ArpeggioD[3];
	unsigned int ArpeggioP;
	};
struct SampleInfo
	{
	char SampleName[22];                                    // padded with null bytes
	unsigned int SampleLen;                                         // sample length in words
	char Finetune;
	char Volume;                                            // 0-64
	unsigned int LoopStart;                                 // loop start point in words
	unsigned int LoopLen;                                   // loop length in words
	};
struct SampleInfoE
	{
	unsigned long StartAddr;
	unsigned long LoopStart;
	unsigned long LoopEnd;
	};
struct SongInfo
	{
	char SongName[20];                                      // song name
	SampleInfo SampleA[31];                                         // 31 sample attributes
	unsigned char SongLength;                               // length of song
	char Unused;
	unsigned char PattSeq[128];                                     // points to pattern sequence
	char FileID[4];                                                 // "M.K." for 31 sample modfiles
	};
struct ChanI
	{
	char Sample;
	unsigned int Period;
	char Effect;
	};
struct RowI
	{
	ChanI Chan[4];
	};
struct Pattern
	{
	RowI Row[64];
	};

/********************/
/* Global song data */
/********************/
unsigned int AWE32Base = 0x620;
ChannelInfo* Channel = new ChannelInfo[4];
char CR = 0;                                                // Current row
int DRAMSize;
unsigned char* EnvTimeTable = new unsigned char[32];
SongInfo* Header = new SongInfo;
unsigned int* LogTable = new unsigned int[2000];            // AWE32 log rate table
unsigned char NumberOfPatterns = 0;
void _interrupt _far (*OldIRQ0)(_CPPARGS);
Pattern* Patt[128];                                                                                     // 128 pointers to patterns
SampleInfoE* SampleAE = new SampleInfoE[31];                            // Extended sample attributes
unsigned char SongPos = 0;                                  // Sequnce pattern position
char SongSpeed = 6;                                         // Song speed(6 default)
FILE *Soundfile;
char TrackTick = SongSpeed;                                                                     // Counter for Beat interrupt handler
unsigned char* VolTable = new unsigned char[65];
unsigned char Reverb = 64;                                  // Reverb effect, 0-255
unsigned char Chorus = 64;                                  // Chorus effect, 0-255

unsigned char MainVolumeL,MainVolumeR;
unsigned char SynthVolumeL,SynthVolumeR;
unsigned char BassL,BassR;
unsigned char TrebleL,TrebleR;

/****************************/
/* Various constant defines */
/****************************/
#define         IRQ0                    8
#define         Left            255
#define         Center          127
#define         Right                   0

#define         Room1                   0
#define         Room2                   1
#define         Room3                   2
#define         Hall1                   3
#define         Hall2                   4
#define         Plate                   5
#define         Delay                   6
#define         PanningDelay    7

#define         Chorus1                 0
#define         Chorus2                 1
#define         Chorus3                 2
#define         Chorus4                 3
#define         FeedbackChorus  4
#define         Flanger                 5
#define         ShortDelay              6
#define         Shortdelay              7

/****************/
/* Effect list  */
/****************/  
#define         Arpeggio                0x0
#define         SlideUp                 0x1
#define         SlideDown               0x2
#define         SlideToNote             0x3
#define         Vibrato                 0x4
#define         Tremolo                 0x7
#define         SampleOffset    0x9
#define         VolumeSlideUD   0xA
#define         PositionJump    0xB
#define         SetVolume               0xC
#define         PatternBreak    0xD
#define         SetSpeed                0xF
		     
unsigned int EffectData[] = { 0x3FF,0x30,0x7FF,0x130,0xBFF,0x230,0xFFF,0x330,
							0x13FF,0x430,0x17FF,0x530,0x1BFF,0x630,0x1FFF,0x730,
							0x23FF,0x830,0x27FF,0x930,0x2BFF,0xA30,0x2FFF,0xB30,
							0x33FF,0xC30,0x37FF,0xD30,0x3BFF,0xE30,0x3FFF,0xF30,
							0x43FF,0x030,0x47FF,0x130,0x4BFF,0x230,0x4FFF,0x330,
							0x53FF,0x430,0x57FF,0x530,0x5BFF,0x630,0x5FFF,0x730,
							0x63FF,0x830,0x67FF,0x930,0x6BFF,0xA30,0x6FFF,0xB30,
							0x73FF,0xC30,0x77FF,0xD30,0x7BFF,0xE30,0x7FFF,0xF30,

							0x83FF,0x030,0x87FF,0x130,0x8BFF,0x230,0x8FFF,0x330,
							0x93FF,0x430,0x97FF,0x530,0x9BFF,0x630,0x9FFF,0x730,
							0xA3FF,0x830,0xA7FF,0x930,0xABFF,0xA30,0xAFFF,0xB30,
							0xB3FF,0xC30,0xB7FF,0xD30,0xBBFF,0xE30,0xBFFF,0xF30,
							0xC3FF,0x030,0xC7FF,0x130,0xCBFF,0x230,0xCFFF,0x330,
							0xD3FF,0x430,0xD7FF,0x530,0xDBFF,0x630,0xDFFF,0x730,
							0xE3FF,0x830,0xE7FF,0x930,0xEBFF,0xA30,0xEFFF,0xB30,
							0xF3FF,0xC30,0xF7FF,0xD30,0xFBFF,0xE30,0xFFFF,0xF30 };

unsigned int EffectData2[] = { 0xC10,0x8470,0x14FE,0xB488,0x167F,0xA470,0x18E7,0x84B5,
							0x1B6E,0x842A,0x1F1D,0x852A,0xDA3,0xF7C,0x167E,0x7254,
							0x0000,0x842A,1,0x852A,0x18E6,0xBAA,0x1B6D,0x7234,
							0x229F,0x8429,0x2746,0x8529,0x1F1C,0x6E7,0x229E,0x7224,
							0xDA4,0x8429,0x2C29,0x8529,0x2745,0x7F6,0x2C28,0x7254,
							0x383B,0x8428,0x320F,0x8528,0x320E,0xF02,0x1341,0x7264,
							0x3EB6,0x8428,0x3EB9,0x8528,0x383A,0xFA9,0x3EB5,0x7294,
							0x3EB7,0x8474,0x3EBA,0x8575,0x3EB8,0x44C3,0x3EBB,0x45C3,

							0x0000,0xA404,1,0xA504,0x141F,0x671,0x14FD,0x287,
							0x3EBC,0xE610,0x3EC8,0xC7B,0x31A,0x7E6,0x3EC8,0x86F7,
							0x3EC0,0x821E,0x3EBE,0xD280,0x3EBD,0x21F,0x3ECA,0x386,
							0x3EC1,0xC03,0x3EC9,0x31E,0x3ECA,0x8C4C,0x3EBF,0xC55,
							0x3EC9,0xC280,0x3EC4,0xBC84,0x3EC8,0xEAD,0x3EC8,0xD380,
							0x3EC2,0x8F7E,0x3ECB,0x219,0x3ECB,0xD2E6,0x3EC5,0x31F,
							0x3EC6,0xC380,0x3EC3,0x327F,0x3EC9,0x265,0x3EC9,0x8319,
							0x1342,0xD3E6,0x3EC7,0x337F,0x0000,0x8365,0x1420,0x9570 };
							
unsigned int EffectCommand[] = { 0x40,0xA20,0x40,0xA22,0x60,0xA20,0x60,0xA22 };  

unsigned int ChorusEffects[] = {0xE600,0x3F6,0xBC2C,0xE608,0x31A,0xBC6E,0xE610,0x31A,0xBC84,
								0xE620,0x269,0xBC6E,0xE680,0x4D3,0xBCA6,0xE6E0,0x44E,0xBC37,
								0xE600,0xB06,0xBC00,0xE6C0,0xB06,0xBC00 };

unsigned long ChorusEffects2[] = {  0,0x6D,0x8000,0,0,0x17C,0x8000,0,0,0x83,0x8000,0,
									0,0x17C,0x8000,0,0,0x5B,0x8000,0,0,0x26,0x8000,0,
									0x6E000,0x83,0x8000,0,0x6E000,0x83,0x8000,0 };

unsigned int ChorusCommand[] = {0x69,0xA20,0x6C,0xA20,0x63,0xA22,0x29,0xA20,0x2A,0xA20,0x2D,0xA20,0x2E,0xA20 };

unsigned int ReverbEffects[] = {0xB488,0xA450,0x9550,0x84B5,0x383A,0x3EB5,0x72F4,0x72A4,
								0x7254,0x7204,0x7204,0x7204,0x4416,0x4516,0xA490,0xA590,
								0x842A,0x852A,0x842A,0x852A,0x8429,0x8529,0x8429,0x8529,
								0x8428,0x8528,0x8428,0x8528,
				0xB488,0xA458,0x9558,0x84B5,0x383A,0x3EB5,0x7284,0x7254,
								0x7224,0x7224,0x7254,0x7284,0x4448,0x4548,0xA440,0xA540,
								0x842A,0x852A,0x842A,0x852A,0x8429,0x8529,0x8429,0x8529,
								0x8428,0x8528,0x8428,0x8528,
				0xB488,0xA460,0x9560,0x84B5,0x383A,0x3EB5,0x7284,0x7254,
								0x7224,0x7224,0x7254,0x7284,0x4416,0x4516,0xA490,0xA590,
								0x842C,0x852C,0x842C,0x852C,0x842B,0x852B,0x842B,0x852B,
								0x842A,0x852A,0x842A,0x852A,
				0xB488,0xA470,0x9570,0x84B5,0x383A,0x3EB5,0x7284,0x7254,
								0x7224,0x7224,0x7254,0x7284,0x4448,0x4548,0xA440,0xA540,
								0x842B,0x852B,0x842B,0x852B,0x842A,0x852A,0x842A,0x852A,
								0x8429,0x8529,0x8429,0x8529,
								0xB488,0xA470,0x9570,0x84B5,0x383A,0x3EB5,0x7254,0x7234,
								0x7224,0x7254,0x7264,0x7294,0x44C3,0x45C3,0xA404,0xA504,
								0x842A,0x852A,0x842A,0x852A,0x8429,0x8529,0x8429,0x8529,
								0x8428,0x8528,0x8428,0x8528, 
				0xB4FF,0xA470,0x9570,0x84B5,0x383A,0x3EB5,0x7234,0x7234,
								0x7234,0x7234,0x7234,0x7234,0x4448,0x4548,0xA440,0xA540,
								0x842A,0x852A,0x842A,0x852A,0x8429,0x8529,0x8429,0x8529,
								0x8428,0x8528,0x8428,0x8528,
				0xB4FF,0xA470,0x9500,0x84B5,0x333A,0x39B5,0x7204,0x7204,
								0x7204,0x7204,0x7204,0x72F4,0x4400,0x4500,0xA4FF,0xA5FF,
								0x8420,0x8520,0x8420,0x8520,0x8420,0x8520,0x8420,0x8520,
								0x8420,0x8520,0x8420,0x8520,
				0xB4FF,0xA490,0x9590,0x8474,0x333A,0x39B5,0x7204,0x7204,
								0x7204,0x7204,0x7204,0x72F4,0x4400,0x4500,0xA4FF,0xA5FF,
								0x8420,0x8520,0x8420,0x8520,0x8420,0x8520,0x8420,0x8520,
								0x8420,0x8520,0x8420,0x8520 };
								
unsigned int ReverbCommand[] = {0x43,0xA20,0x45,0xA20,0x7F,0xA22,0x47,0xA20,
								0x54,0xA22,0x56,0xA22,0x4F,0xA20,0x57,0xA20,
								0x5F,0xA20,0x47,0xA22,0x4F,0xA22,0x57,0xA22,
								0x5D,0xA22,0x5F,0xA22,0x61,0xA20,0x63,0xA20,
								0x49,0xA20,0x4B,0xA20,0x51,0xA20,0x53,0xA20,
								0x59,0xA20,0x5B,0xA20,0x41,0xA22,0x43,0xA22,
								0x49,0xA22,0x4B,0xA22,0x51,0xA22,0x53,0xA22 };

void ExitWithError(char* ErrorMessage)
	{
	cout << ErrorMessage << "\n";
	exit(1);
	}           
	
void AWE32RegW(int Command,int DataPort,unsigned int Data)
	{
	_disable();
	_outpw((AWE32Base+0x802),Command);
	_outpw((AWE32Base-0x620+DataPort),Data);
	_enable();        
	}
	
void AWE32RegDW(int Command,int DataPort,unsigned long Data)
	{
	_disable();
	_outpw((AWE32Base+0x802),Command);
	_outpw((AWE32Base-0x620+DataPort),Data);
	_outpw((AWE32Base-0x620+DataPort+2),Data>>16);
	_enable();
	}

unsigned int AWE32RegR(int Command,int DataPort)
	{
	_disable();
	_outpw((AWE32Base+0x802),Command);
	unsigned int k = _inpw(AWE32Base-0x620+DataPort);
	_enable();
	return k;
	}

unsigned long AWE32RegDR(int Command,int DataPort)
	{
	_disable();
	_outpw((AWE32Base+0x802),Command);
	unsigned long k = _inpw(AWE32Base-0x620+DataPort);
	unsigned long Temp = _inpw(AWE32Base-0x620+DataPort+2);
	k |= Temp << 16;
	_enable();
	return k;
	}

int AWE32Detect()                                       // autodetect AWE32 at 620h,640h,660h or 680h
	{
	for(int AWE32Base=0x620;AWE32Base<=0x680;AWE32Base +=0x20)
		{
		if(AWE32RegR(0xE0,0xE20)&0xC != 0xC)
			continue;
		if(AWE32RegR(0x3D,0xA20)&0x58 != 0x58)
			continue;
		if(AWE32RegR(0x3E,0xA20)&3 != 3)
			continue;
		return 0;
		}
	return 1;
	}        

void InitEffect(unsigned int* Data)
	{ 
	for(int k=0;k<4;++k)
		for(int i=0;i<32;++i)
			AWE32RegW(EffectCommand[k*2]+i,EffectCommand[k*2+1],Data[k*32+i]);
	}
void InitEffect2(unsigned int* Data)
	{
	for(int k=0;k<4;++k)
		for(int i=0;i<32;++i)       
			{
			unsigned int TempData = Data[k*32+i];
			AWE32RegW(EffectCommand[k*2]+i,EffectCommand[k*2+1],TempData | (i&1)<<15);
			}
	}                         
	
/*********************************************/
/* Wait Delay number of AWE32 44100Hz clocks */
/*********************************************/
void AWE32Wait(unsigned int Clocks)
	{
	unsigned int k = AWE32RegR(0x3B,0xA22);                                 // 44100Hz clock
	unsigned Time = k;
	while(Clocks > (Time-k))
		Time = AWE32RegR(0x3B,0xA22);
	}

/****************************************/
/* Initialization of the AWE32 hardware */
/****************************************/
void AWE32Init()
	{
	for(int k=0;k<32;++k)                                                                   // init envelope engine 
		{  
		AWE32RegW(0xA0+k,0xA20,0x80);                                           // envelope 2 sustain & decay
		AWE32RegW(0xC0+k,0xA22,0);                                                      // envelope 1 hold & attack
		AWE32RegW(0xE0+k,0xA20,0);                                                      // envelope 1 sustain & decay
		AWE32RegW(0x00+k,0xE20,0xE000);                                         // pitch
		AWE32RegW(0x20+k,0xE20,0xFF00);                                         // filter cutoff & volume
		AWE32RegW(0x40+k,0xE20,0);                                                      // envelope 1 to pitch & filter
		AWE32RegW(0x60+k,0xE20,0);                                                      // LFO1 to pitch & filter
		AWE32RegW(0x80+k,0xE20,0x18);                                           // LFO1 frequnecy & LFO1 to volume
		AWE32RegW(0xA0+k,0xE20,0x18);                                           // LFO2 frequency & LFO2 to pitch
		AWE32RegW(0xC0+k,0xE20,0);                                                      // ???
		AWE32RegW(0xE0+k,0xA22,0);                                                      // LFO2 delay
		AWE32RegW(0xA0+k,0xA22,0);                                                      // LFO1 delay
		AWE32RegW(0x80+k,0xA22,0);                                                      // envelope 2 hold & attack
		AWE32RegW(0x80+k,0xA20,0);                                                      // envelope 2 delay
		AWE32RegW(0xC0+k,0xA20,0);                                                      // envelope 1 delay
		}
		
	AWE32Wait(2);    
		 
	for(k=0;k<32;++k)                                                                               // init sound engine
		{
		AWE32RegDW(0x20+k,0x620,0);
		AWE32RegDW(0x60+k,0x620,0xFFFF);
		AWE32RegDW(0xC0+k,0x620,0);                                                     // pan & loop start
		AWE32RegDW(0xE0+k,0x620,0);                                                     // chorus & loop end
		AWE32RegDW(0x00+k,0x620,0);
		AWE32RegDW(0x40+k,0x620,0xFFFF);
		AWE32RegDW(0x00+k,0xA20,0);                                                     // filter coeff. & start address
		AWE32RegDW(0xA0+k,0x620,0);
		AWE32RegDW(0x80+k,0x620,0);
		AWE32RegW(0xA0+k,0xA20,0x807F);
		}  

	AWE32RegW(0x34,0xA20,0);                                                                // init effects engine
	AWE32RegW(0x35,0xA20,0);
	AWE32RegW(0x36,0xA20,0);
	AWE32RegW(0x35,0xA20,0);
	
	InitEffect(EffectData);
	AWE32Wait(0x400);
	InitEffect2(EffectData);
	for(k=0;k<0x14;++k)
		AWE32RegDW(0x20+k,0xA20,0);
	InitEffect2(EffectData2);
	
	AWE32RegDW(0x29,0xA20,0);
	AWE32RegDW(0x2A,0xA20,0x83);
	AWE32RegDW(0x2D,0xA20,0x8000);
	AWE32RegDW(0x2E,0xA20,0);

	InitEffect(EffectData2);     

	AWE32RegW(0xBE,0xA20,0x80);                                                             // init DRAM refresh
	AWE32RegDW(0xDE,0x620,0xFFFFFFE0);
	AWE32RegDW(0xFE,0x620,0xFFFFE8);
	AWE32RegDW(0x3E,0x620,0);
	AWE32RegDW(0x1E,0x620,0);
	AWE32RegDW(0x1E,0xA20,0xFFFFE3);

	AWE32RegW(0xBF,0xA20,0x80);
	AWE32RegDW(0xDF,0x620,0xFFFFF0);
	AWE32RegDW(0xFF,0x620,0xFFFFF8);
	AWE32RegDW(0x3F,0x620,0xFF);
	AWE32RegDW(0x1F,0x620,0x8000);
	AWE32RegDW(0x1F,0xA20,0xFFFFF3);
     
    _disable();
    _outpw(AWE32Base+0x802,0x3E);
	 _outpw(AWE32Base,0);
    while(k==0)
	k = _inpw(AWE32Base+0x802) & 0x10;
    while(k==0x10)
	k = _inpw(AWE32Base+0x802) & 0x10;
    _enable();
    _outpw(AWE32Base+2,0x4828);
    _outpw(AWE32Base+0x802,0x3C);
    _outpw(AWE32Base+0x400,0);
	 _enable();

	 AWE32RegDW(0x7E,0x620,0xFFFFFFFF);
	 AWE32RegDW(0x7F,0x620,0xFFFFFFFF);
	}
   
void SetReverbEffect(char Effect)
	{
	for(int k=0; k<28; k++)
		AWE32RegW(ReverbCommand[k*2],ReverbCommand[k*2+1],ReverbEffects[k+Effect*28]);
	}
void SetChorusEffect(char Effect)
	{              
	for(int k=0; k<3; k++)
		AWE32RegW(ChorusCommand[k*2],ChorusCommand[k*2+1],ChorusEffects[k+Effect*3]);
	for(k=0; k<4; k++)
		AWE32RegDW(ChorusCommand[6+k*2],ChorusCommand[6+k*2+1],ChorusEffects2[k+Effect*4]);
	}
/*********************************************/
/* Convert an Motorola word to an Intel word */
/*********************************************/                                           
unsigned int cword(unsigned int BigEndian)
	{
	return ((BigEndian&0xFF)<<8) | ((BigEndian&0xFF00)>>8);
	}
    
/****************************/
/* Enable AWE32 DRAM access */
/****************************/
void EnableDRAM()
	{
	unsigned long Scratch;

	AWE32RegW(0x3E,0xA20,0x20);                             // enable DRAM access
	for(int k=0;k<30;k++)
		{
		AWE32RegW(0xA0+k,0xA20,0x80);
		AWE32RegDW(0x60+k,0x620,0);
		AWE32RegDW(0x40+k,0x620,0);
		AWE32RegDW(0xC0+k,0x620,0);
		AWE32RegDW(0xE0+k,0x620,0);
		AWE32RegDW(0x20+k,0x620,0x40000000);
		AWE32RegDW(0+k,0x620,0x40000000);
		Scratch = (((k&1)<<9)+0x400);
		Scratch = Scratch <<16;
		AWE32RegDW(0+k,0xA20,Scratch);
		}
	}

/*****************************/
/* Disable AWE32 DRAM access */
/*****************************/
void DisableDRAM()
	{
	for(int k=0;k<30;k++)                                                                           // disable DRAM access
		{
		AWE32RegDW(k,0xA20,0);
		AWE32RegW(0xA0+k,0xA20,0x807F);
		}
	}

/**************/
/* Check DRAM */
/**************/
void CheckDRAM()
	{
	EnableDRAM();

	 AWE32RegDW(0x36,0xA20,0x200000);                                            // Address for writing
	 AWE32RegW(0x3A,0xA20,0x1234);
	 AWE32RegW(0x3A,0xA20,0x7777);

	 while(DRAMSize < 28*1024)                                                           // 28 MB is max onboard memory
	{
	AWE32Wait(2);
	AWE32RegDW(0x34,0xA20,0x200000);                                        // Address for reading
	AWE32RegR(0x3A,0xA20);                                                          // Skip first word
	if(AWE32RegR(0x3A,0xA20) != 0x1234)
		break;
	if(AWE32RegR(0x3A,0xA20) != 0x7777)
		break;
	DRAMSize += 32;
		AWE32RegDW(0x36,0xA20,0x200000+DRAMSize*512L);          // Address for writing
	AWE32RegW(0x3A,0xA20,0xFFFF);
	}

	DisableDRAM();
	}

/*********************************/
/* Sample interpolating routines */
/*********************************/
int MAXOVERSAMPLES=0;
unsigned OverSamples=0;                                     // number of lineary interpolated samples
																				// to be inserted between regular samples
void CalcOverSamples(void)
	{
	int Instr;
	long SampleLen;
	long AWE32FreeMem = DRAMSize*1024L, ModMem=0;

	if (MAXOVERSAMPLES > 0)
		{
		for (Instr=0;Instr<31;Instr++)
			{
			SampleLen = cword(Header->SampleA[Instr].SampleLen);
			if (SampleLen > 0)
				ModMem += 2*SampleLen+8;
			}

		if (ModMem < AWE32FreeMem)
			OverSamples = min(MAXOVERSAMPLES,(int)(AWE32FreeMem/ModMem)-1);      //max. (MAXOVERSAMPLES+1)*8363 Hz
		}
	}

void SendOverSamples(long Sample1, long Sample2)
	{
	int i;
        float Sample = Sample1;
        float delta = ((float)Sample2-(float)Sample1)/(float)(OverSamples+1);

	if (OverSamples > 0)
		for (i=0; i<OverSamples; i++)
			{
			Sample += delta;
                        AWE32RegW(0x3A,0xA20,(unsigned int)(Sample+0.5));
			}
	}

/******************************************/
/* Load & upload instruments to the AWE32 */
/******************************************/
void LoadInstruments()
	{
	long AWE32FreeMem = DRAMSize * 1024L;
	long BufferSize = 32768;
	long SampleLen,LoopStart,LoopLen,LoopEnd;
	long CurrentAddr = 0x200000;
	long Samples;
	long CurrentSample;
	long LastSample;
	char* SampleBuffer = new char[BufferSize];
	char LoopSample1,LoopSample2;

	CalcOverSamples();

	cout << "Uploading instruments to AWE32 DRAM:" << endl;
	EnableDRAM();
	AWE32RegDW(0x36,0xA20,CurrentAddr);                                                     // write start address

	for(int Instr=0; Instr<31; Instr++)                                                     // Load 31 samples
		{
		SampleLen = cword(Header->SampleA[Instr].SampleLen)*2L;
		SampleAE[Instr].StartAddr = 0;                                                  // Start address 0 will not play sample
		if(SampleLen == 0)                                      // Is this a sample?
			continue;
		
		for(int m=0; m<22; m++)
			{
			if(Header->SampleA[Instr].SampleName[m] < 32)
				{
				Header->SampleA[Instr].SampleName[m] = 0;
				break;
				}
			if(m == 21)
				Header->SampleA[Instr].SampleName[m] = 0;
			}

		cout << Header->SampleA[Instr].SampleName;
		for(int k=0; k<(25-strlen(Header->SampleA[Instr].SampleName)); k++)
			cout << " ";

		if(AWE32FreeMem < (SampleLen+8))
			{
			fseek(Soundfile,SampleLen,SEEK_CUR);
			cout << "ERROR: Not enough AWE32 memory!" << endl;
			continue;
			}

		LoopStart = cword(Header->SampleA[Instr].LoopStart)*2L;
		LoopLen = cword(Header->SampleA[Instr].LoopLen)*2L;
		LoopEnd = LoopStart+LoopLen;
		if((Header->SampleA[Instr].Finetune &8) != 0)           // Expand finetune signed nibble to signed char
			Header->SampleA[Instr].Finetune |= 0xF0;

		CurrentSample = 0;

		if(LoopLen < 4)
			{
			LoopStart = SampleLen+1;                                                        // Never find loopstart
			LoopSample1 = 0;                                    // Smooth end to 0
			LoopEnd = SampleLen;
			}

		do
			{
			if((CurrentSample+BufferSize) >= SampleLen)
				Samples = SampleLen-CurrentSample;
			else
				Samples = BufferSize;

			fread(SampleBuffer,1,Samples,Soundfile);                        // read sample data from file

			if(LoopStart < (CurrentSample + Samples))                       // Find first sample in loop
				{
				if(LoopStart > CurrentSample)
					LoopSample1 = SampleBuffer[LoopStart-CurrentSample];
				}

			if(LoopEnd <= (CurrentSample + Samples))             // Find last sample in loop
				{
				if(LoopEnd >= CurrentSample)
					{
					LoopSample2 = SampleBuffer[LoopEnd-CurrentSample-9];
					for(int i=0; i<8; i++)
						SampleBuffer[LoopEnd-CurrentSample-8+i] = LoopSample2+(i+1)*(LoopSample1-LoopSample2)/8;
					}
				}

			if (CurrentSample > 0)                                          // send oversamples between last sample of
				SendOverSamples(LastSample<<8,SampleBuffer[0]<<8);      // previous buffer and first sample of current buffer

			for(long i=0; i<Samples; i++)
				{
				AWE32RegW(0x3A,0xA20,SampleBuffer[i]<<8);                               // upload data to AWE32 DRAM
				if (i != Samples-1)                                                     // last sample in buffer ?
					SendOverSamples(SampleBuffer[i]<<8,SampleBuffer[i+1]<<8);       // send oversamples between Buffer[i] and Buffer[i+1]
				if((CurrentSample + i) == LoopStart)
					LoopSample1 = SampleBuffer[i];
				}

			CurrentSample += Samples;
			LastSample = SampleBuffer[Samples-1];
			}
		while(CurrentSample != SampleLen);

		SampleAE[Instr].StartAddr = CurrentAddr;
		if(LoopLen < 4)
			{
			for(int i=0; i<8; i++)                                                          // Anticlick samples
				AWE32RegW(0x3A,0xA20,0);
			SampleAE[Instr].LoopStart = SampleLen*(OverSamples+1)-OverSamples+CurrentAddr;
			SampleAE[Instr].LoopEnd = SampleLen*(OverSamples+1)-OverSamples+5+CurrentAddr;
			CurrentAddr += SampleLen*(OverSamples+1)-OverSamples + 8;
			AWE32FreeMem -= SampleLen*(OverSamples+1)-OverSamples + 8;
			}
		else
			{
			SampleAE[Instr].LoopStart = LoopStart*(OverSamples+1)+CurrentAddr;
			SampleAE[Instr].LoopEnd = (LoopStart+LoopLen)*(OverSamples+1)+CurrentAddr-3;
			CurrentAddr += SampleLen*(OverSamples+1);
			AWE32FreeMem -= SampleLen*(OverSamples+1);
			}
		cout << "OK!" << endl;
		}

	delete SampleBuffer;
	DisableDRAM();
	}

/******************************************/
/* Play a note with settings from Chan[i] */
/******************************************/
void PlayNote(ChannelInfo* Chan, int i)
	{
	char GChan = Chan[i].AWE32Chan;
	AWE32RegW(0xA0+GChan,0xA20,0x807F);                                             // envelope 2 sustain & decay
	AWE32RegW(0x00+GChan,0xE20,0xE000);                             // pitch

	AWE32RegW(0xA0+GChan,0xA20,0x80);                               // envelope 2 sustain & decay
	AWE32RegDW(0x60+GChan,0x620,0xFFFF);

	 AWE32RegW(0x80+GChan,0xA20,0x8000);                                         // envelope 2 delay
	AWE32RegW(0x80+GChan,0xA22,0x7F7F);                                             // envelope 2 hold & attack
	AWE32RegW(0xC0+GChan,0xA20,0x8000);                     // envelope 1 delay
	AWE32RegW(0xC0+GChan,0xA22,0x7F7F);                     // envelope 1 hold & attack
	 AWE32RegW(0xE0+GChan,0xA20,0x7F);                           // envelope 2 sustain & decay

	AWE32RegW(0x00+GChan,0xE20,Chan[i].Pitch);                              // pitch
	unsigned char AWE32Vol = VolTable[Chan[i].Volume];
	AWE32RegW(0x20+GChan,0xE20,0xFF00 | AWE32Vol);                  // filter cutoff & volume
	AWE32RegW(0xA0+GChan,0xA22,0x8000);                     // LFO1 delay
	AWE32RegW(0xE0+GChan,0xA22,0x8000);                     // LFO2 delay
	AWE32RegW(0x40+GChan,0xE20,0);                          // envelope 2 to pitch & filter
	AWE32RegW(0x60+GChan,0xE20,0);                          // LFO1 to pitch & filter
//      AWE32RegW(0x80+GChan,0xE20,0x7F);                       // LFO1 frequency & to volume
	AWE32RegW(0x80+GChan,0xE20,(Chan[i].TremDepth << 8) | Chan[i].TremSpeed);
	AWE32RegW(0xA0+GChan,0xE20,(Chan[i].VibDepth << 8) | Chan[i].VibSpeed);
	AWE32RegDW(0x20+GChan,0x620,(Chan[i].Reverb<<8) | (AWE32RegDR(0x20+GChan,0x620)&0xFFFF0000));
	long TempPan = Chan[i].Pan;
	TempPan <<= 24L;
	AWE32RegDW(0xC0+GChan,0x620,TempPan | Chan[i].LoopStart);
	TempPan = Chan[i].Chorus;
	TempPan <<= 24L;
	AWE32RegDW(0xE0+GChan,0x620,TempPan | Chan[i].LoopEnd);
	AWE32RegDW(0x00+GChan,0xA20,Chan[i].StartAddr+Chan[i].Offset);
	AWE32RegW(0xA0+GChan,0xA20,Chan[i].Env2Sustain<<8 | Chan[i].Env2Decay);
	}

void NoteOff(char Channel)
	{
	AWE32RegW(0xA0+Channel,0xA20,0x807F);
	AWE32RegW(0xE0+Channel,0xA20,0x807F);
	}

/**********************************************/
/* Calculate the AWE32 logarithmic rate table */
/**********************************************/
void CalcLogTable()
	{
	long Frequency;
	for(int k=75;k<2000;k++)
		{
		Frequency = (OverSamples+1)*8363L*428L/k;
		LogTable[k] = int(log(Frequency)*5909.27-5850.98);
		}

	VolTable[0] = 127;
	for(k=1; k<65; k++)
		VolTable[k] = char(127 - log(k)*26.6899);

	}

/**********************************************/
/* DecodePatterns functions flips a couple of */
/* bytes in the pattern so that it would be   */
/* easier to use the data when playing            */
/**********************************************/
void DecodePatterns()
	{
	char b;
	int w;

	for(int k=0; k<NumberOfPatterns; k++)
		for(int n=0; n<64; n++)
			for(int i=0; i<4; i++)
				{
				b = Patt[k]->Row[n].Chan[i].Period >> 12;
				b &= 0xF;
				b |= Patt[k]->Row[n].Chan[i].Sample & 0xF0;
				w = Patt[k]->Row[n].Chan[i].Period << 4;
				w &= 0xF000;
				w |= (Patt[k]->Row[n].Chan[i].Sample << 8L)&0xFFF;
				w |= Patt[k]->Row[n].Chan[i].Period & 0xFF;

				Patt[k]->Row[n].Chan[i].Sample = b;
				Patt[k]->Row[n].Chan[i].Period = w;
				}
	}
/**********************/
/* Beat function data */
/**********************/
	char CP;                                                                                                // Current pattern
	char Effect;                                            // Effect type
	unsigned char EffectD;                                                                  // Effect data
	int Finetune;
	char i;                                                                                                 // Channel number in loop
	char l;
	char s;                                                                                                 // Sample to play
	int Period;                                             // Note to play
	int     StackSeg;
	int     StackPtr;
	int     StackData[1024];
	unsigned char NewSongPos = 255;
	char NewCR = 0;
	char TempSTR[8];
	unsigned int TempTimer;

/******************************************************/
/* IRQ0 Timer interrupt handler                       */
/* This function is called 50 times a second(125 BPM) */
/*                                                                                                        */
/* Counts TrackTick down to 0 and then plays a row    */
/******************************************************/
void interrupt Beat(_CPPARGS)
	{
	_asm
		{
		mov     ax,ss                                                                                   // Switch to our stack
		mov     StackSeg,ax
		mov     StackPtr,sp
		mov     ax,ds
		mov     ss,ax
		mov     sp,StackData+1024
		}

	if( SongPos == 255)
		goto EXIT_INT;                                                                          // The song has finished

	TrackTick -= 1;                                                                                 // TrackTick is a counter based on the song speed
	if(TrackTick != 0)
		{
		for(i=0; i<4; i++)
			{
			if(Channel[i].VolumeSlide != 0)
				{
				Channel[i].Volume += Channel[i].VolumeSlide;
				if(Channel[i].Volume > 64)
					Channel[i].Volume = 64;                                 // Don't slide higher than 64
				if(Channel[i].Volume < 0)                   // Don't slide less than 0
					Channel[i].Volume = 0;
				AWE32RegW(0x20+Channel[i].AWE32Chan,0xE20,0xFF00 | VolTable[Channel[i].Volume]);
				}
			if(Channel[i].PitchSlide != 0)
				{
				Channel[i].Period += Channel[i].PitchSlide;
				if(Channel[i].Period > Channel[i].MinSlide)
					Channel[i].Period = Channel[i].MinSlide;
				if(Channel[i].Period < Channel[i].MaxSlide)
					Channel[i].Period = Channel[i].MaxSlide;
				AWE32RegW(Channel[i].AWE32Chan,0xE20,LogTable[Channel[i].Period + Channel[i].Finetune]);
				}
			if(Channel[i].ArpeggioD[0] != 0)
				{
				AWE32RegW(Channel[i].AWE32Chan,0xE20,LogTable[Channel[i].ArpeggioD[Channel[i].ArpeggioP] + Channel[i].Finetune]);
				if(Channel[i].ArpeggioP == 2)
					Channel[i].ArpeggioP = 0;
				else
					Channel[i].ArpeggioP++;
				}
			}
		goto EXIT_INT;                                      // Don't play new row yet
		}

	CP = Header->PattSeq[SongPos];                                                  // Fetch current pattern from pattern sequence
	for(i=0; i<4; i++)
		{
		if(Channel[i].VibSpeed != 0)
			AWE32RegW(0xA0+Channel[i].AWE32Chan,0xE20,0);   // stop vibrating
		if(Channel[i].TremSpeed != 0)
			AWE32RegW(0x80+Channel[i].AWE32Chan,0xE20,0);   // stop tremolo
		if(Channel[i].ArpeggioD[0] != 0)
			AWE32RegW(Channel[i].AWE32Chan,0xE20,LogTable[Channel[i].Period + Channel[i].Finetune]);
		Channel[i].ArpeggioD[0] = 0;

		s = Patt[CP]->Row[CR].Chan[i].Sample;
		Period = Patt[CP]->Row[CR].Chan[i].Period;
		Effect = (Period >> 12) & 0xF;                      // Effect type is the top 4 bits of Period
		EffectD = Patt[CP]->Row[CR].Chan[i].Effect;                 // Fetch effect data
		Period &= 0xFFF;                                                                        // Throw away the effect type

		if(Period == 0)
			s = 0;

		if(s != 0)
			{
			Channel[i].Status = 1;
			s -= 1;
			Channel[i].Volume = Header->SampleA[s].Volume;
			Channel[i].StartAddr = SampleAE[s].StartAddr;
			Channel[i].LoopStart = SampleAE[s].LoopStart;
			Channel[i].LoopEnd = SampleAE[s].LoopEnd;
			Channel[i].Env2Decay = 0x7F;                                    // Decay time set to zero
			Channel[i].Env2Sustain = 0x7F;                  // Max sustain
			Finetune = Header->SampleA[s].Finetune;
			Channel[i].Pitch = LogTable[Period+Finetune];           // AWE32 logarithmic rate
			Channel[i].Period = Period;
			Channel[i].Finetune = Finetune;
			Channel[i].VibSpeed = 0;
			Channel[i].TremSpeed = 0;
			Channel[i].Offset = 0;
			}

		if(Period == 0)
			Channel[i].Status = 0;

		if(Finetune && 8)                                                                       // Finetune is a 4-bit signed value
			Finetune |= 0xFFF0;                             // Expand sign to 16-bit

		Channel[i].Reverb = Reverb;
		Channel[i].Chorus = Chorus;
		Channel[i].VolumeSlide = 0;
		Channel[i].PitchSlide = 0;

		switch(Effect)                                                                  // Find out which effect we have
			{
			case Arpeggio:
				if(EffectD != 0)
					{
					Channel[i].ArpeggioP = 1;
					Channel[i].ArpeggioD[0] = Channel[i].Period;
					Channel[i].ArpeggioD[1] = Channel[i].Period;
					Channel[i].ArpeggioD[2] = Channel[i].Period;
					for(l=0; l<((EffectD>>4)&0xF); l++)
						Channel[i].ArpeggioD[1] -= Channel[i].ArpeggioD[1]>>4;
					for(l=0; l<(EffectD&0xF); l++)
						Channel[i].ArpeggioD[2] -= Channel[i].ArpeggioD[2]>>4;
					}
				break;
			case SlideUp:
				Channel[i].PitchSlide = - EffectD;
				Channel[i].MaxSlide = 113;
				Channel[i].MinSlide = 856;
				break;
			case SlideDown:
				Channel[i].PitchSlide = EffectD;
				Channel[i].MaxSlide = 113;
				Channel[i].MinSlide = 856;
				break;
			case SlideToNote:
				if(EffectD == 0)
					{
					Channel[i].PitchSlide = Channel[i].PortamentoSpeed;
					break;
					}
				if(Period != 0)
					{
					if(Channel[i].Period > Period)
						{
						if(Period != 0)
							Channel[i].MaxSlide = Period;
						Channel[i].PitchSlide = - EffectD;
						}
					else
						{
						if(Period != 0)
							Channel[i].MinSlide = Period;
						Channel[i].PitchSlide = EffectD;
						}
					}
				else
					{
					if(Channel[i].PortamentoSpeed > 0)
						Channel[i].PitchSlide = EffectD;
					else
						Channel[i].PitchSlide = - EffectD;
					}
				Channel[i].PortamentoSpeed = Channel[i].PitchSlide;
				break;
			case Vibrato:
				if(EffectD & 0xF != 0)
					Channel[i].VibSpeed = (EffectD >> 4)*16+7;
				if(EffectD & 0xF0 != 0)
					Channel[i].VibDepth = EffectD & 0xF;
				if(Channel[i].Status == 0)
					AWE32RegW(0xA0+Channel[i].AWE32Chan,0xE20,(Channel[i].VibDepth << 8) | Channel[i].VibSpeed);
				break;
			case Tremolo:
				if(EffectD & 0xF != 0)
					Channel[i].TremSpeed = (EffectD >> 4)*16+7;
				if(EffectD & 0xF0 != 0)
					Channel[i].TremDepth = EffectD & 0xF;
				if(Channel[i].Status == 0)
					AWE32RegW(0x80+Channel[i].AWE32Chan,0xE20,(Channel[i].TremDepth << 8) | Channel[i].TremSpeed);
				break;
			case SampleOffset:
				Channel[i].Offset = (EffectD << 8L)*(OverSamples+1);
				break;
			case VolumeSlideUD:
				if((EffectD & 0xF0) == 0)
					Channel[i].VolumeSlide = - EffectD;
				if((EffectD & 0xF) == 0)
					Channel[i].VolumeSlide = EffectD>>4;
				break;
			case PositionJump:
				NewSongPos = EffectD;
				break;
			case SetVolume:
				Channel[i].Volume = EffectD;
				if(Channel[i].Status == 0)
					AWE32RegW(0x20+Channel[i].AWE32Chan,0xE20,0xFF00 | VolTable[EffectD]);
				break;
			case PatternBreak:
				NewCR = EffectD;
				NewSongPos = SongPos + 1;
				break;
			case SetSpeed:
				if(EffectD < 32)
					SongSpeed = EffectD;
				else
					{
					TempTimer = 1193181L/((EffectD*50L)/125);
					_outp(0x40,TempTimer&0xFF);
					_outp(0x40,(TempTimer>>8)&0xFF);
					}
		break;
		}
	}

	l = 0;
	for(i=0; i<4; i++)
		{
		while( l != 30 )
			{
			if((AWE32RegR(0xA0+l,0xA20) >> 15) == 1)
				if((AWE32RegDR(0x60+l,0x620) >> 16) == 0)
					break;
			l++;
			}
		if(l == 30)
			break;
		if(Channel[i].Status == 1)
			{
			if(Channel[i].FirstNote != 1)
				NoteOff(Channel[i].AWE32Chan);
			else
				Channel[i].FirstNote = 0;

			Channel[i].AWE32Chan = l;
			if(Channel[i].StartAddr != 0)
		PlayNote(Channel, i);
		 Channel[i].Status = 0;
		 l++;
		 }
		}

	TempSTR[0] = SongPos/10+48;
	TempSTR[1] = (SongPos - (SongPos/10)*10)+48;
	TempSTR[2] = 0;
	_settextposition(4,44);
	_outtext(TempSTR);

	TempSTR[0] = CR/10+48;
	TempSTR[1] = (CR - (CR/10)*10)+48;
	TempSTR[2] = 0;
	_settextposition(4,60);
	_outtext(TempSTR);

	CR++;                                                                                                   // Increase current row
		if(CR == 64)                                                                                    // If end of pattern, reset
			{                                                   // current row & increase song pos
			CR = 0;
			SongPos++;
			Header->SongLength -= 1;
			if(Header->SongLength == 0)
				SongPos = 255;
			}
	if(NewSongPos != 255)
		{
		Header->SongLength += SongPos - NewSongPos;
		SongPos = NewSongPos;
		CR = NewCR;
		NewSongPos = 255;
		NewCR = 0;
		}

	TrackTick = SongSpeed;
	EXIT_INT:;
	_disable();
	_outp(0x20,0x20);                                                                               // send end of interrupt to int controller
	_asm
		{
		mov     ss,StackSeg                                                                             // Restore stack
		mov     sp,StackPtr
		}
	}

/*******************/
/* Mouse functions */
/*******************/
union REGS regs;

void ShowMouseCursor()
	{
	regs.x.ax = 1;
	int86(0x33,&regs,&regs);
	}

void HideMouseCursor()
	{
	regs.x.ax = 2;
	int86(0x33,&regs,&regs);
	}

void InitMouse()
	{
	regs.x.ax = 0;
	int86(0x33,&regs,&regs);
	}

int GetMousePos(unsigned int* MouseX,unsigned int* MouseY)
	{
	regs.x.ax = 3;
	int86(0x33,&regs,&regs);
	*MouseX = regs.x.cx;
	*MouseY = regs.x.dx;
	return regs.x.bx;
	}  
      
int GetMouseButtonStat()
	{
	regs.x.ax = 5;
	regs.x.bx = 0;
	int86(0x33,&regs,&regs);
	return regs.x.ax;
	}                
	
int MouseMov(unsigned int* MouseX,unsigned int* MouseY)
	{
	regs.x.ax = 3;
	int86(0x33,&regs,&regs);
	if(*MouseX != regs.x.cx || *MouseY != regs.x.dx)
		{
		*MouseX = regs.x.cx;
		*MouseY = regs.x.dx;
		return 1;
		}
	return 0;
	}
	
void SetMousePos(int MouseX,int MouseY)
	{
	regs.x.ax = 4;
	regs.x.cx = MouseX;
	regs.x.dx = MouseY;
	int86(0x33,&regs,&regs);
	}

void SetMouseYLimits(int yMin,int yMax)
	{                                  
	regs.x.ax = 8;
	regs.x.cx = yMin;
	regs.x.dx = yMax;
	int86(0x33,&regs,&regs);
	} 

void SetMouseXLimits(int xMin,int xMax)
	{
	regs.x.ax = 7;
	regs.x.cx = xMin;
	regs.x.dx = xMax;
	int86(0x33,&regs,&regs);
	} 
	
void WaitRetrace()
	{
	_asm
		{
		mov     dx,0x3DA
		WR1:
		in      al,dx
		test al,8
		jz      WR1  
		WR2:
		in      al,dx
		test al,8
		jnz WR2
		}
	}
	
/***********************************/
/* Objects and classes for buttons */
/***********************************/
class Base
	{
	public:
		virtual void ButtonFunction(int Data) = 0;
	};

class Chan0Pan : public Base
	{ 
	public:
		void ButtonFunction(int Data)   
			{
			Channel[0].Pan = 255-Data;
			long TempPan = Channel[0].Pan;
			TempPan <<= 24L;
			if(Channel[0].FirstNote == 0)
				AWE32RegDW(0xC0+Channel[0].AWE32Chan,0x620,TempPan | Channel[0].LoopStart);
			}
	};                         
class Chan1Pan : public Base
	{ 
	public:
		void ButtonFunction(int Data)   
			{
			Channel[1].Pan = 255-Data;
			long TempPan = Channel[1].Pan;
			TempPan <<= 24L;
			if(Channel[1].FirstNote == 0)
				AWE32RegDW(0xC0+Channel[1].AWE32Chan,0x620,TempPan | Channel[1].LoopStart);
			}
	};                         
class Chan2Pan : public Base
	{
	public:
		void ButtonFunction(int Data)   
			{
			Channel[2].Pan = 255-Data;
			long TempPan = Channel[2].Pan;
			TempPan <<= 24L;
			if(Channel[2].FirstNote == 0)
				AWE32RegDW(0xC0+Channel[2].AWE32Chan,0x620,TempPan | Channel[2].LoopStart);
			}
	};                         
class Chan3Pan : public Base
	{ 
	public:
		void ButtonFunction(int Data)   
			{
			Channel[3].Pan = 255-Data;
			long TempPan = Channel[3].Pan;
			TempPan <<= 24L;
			if(Channel[3].FirstNote == 0)
				AWE32RegDW(0xC0+Channel[3].AWE32Chan,0x620,TempPan | Channel[3].LoopStart);
			}
	};      
class AWE32MVolume : public Base
	{
	public:
		void ButtonFunction(int Data)
			{                            
			int Volume = (Data/2)*8;
			_outp(AWE32Base-0x400+4,0x30);
			_outp(AWE32Base-0x400+5,Volume);
			_outp(AWE32Base-0x400+4,0x31);
			_outp(AWE32Base-0x400+5,Volume);
			}
	};
class AWE32Volume : public Base
	{
	public:
		void ButtonFunction(int Data)
			{                            
			int Volume = (Data/2)*8;
			_outp(AWE32Base-0x400+4,0x34);
			_outp(AWE32Base-0x400+5,Volume);
			_outp(AWE32Base-0x400+4,0x35);
			_outp(AWE32Base-0x400+5,Volume);
			}
	};
class AWE32Bass : public Base
	{
	public:
		void ButtonFunction(int Data)
			{                            
			int Volume = (Data/2)*8;
			_outp(AWE32Base-0x400+4,0x46);
			_outp(AWE32Base-0x400+5,Volume);
			_outp(AWE32Base-0x400+4,0x47);
			_outp(AWE32Base-0x400+5,Volume);
			}
	};
class AWE32Treble : public Base
	{
	public:
		void ButtonFunction(int Data)
			{                            
			int Volume = (Data/2)*8;
			_outp(AWE32Base-0x400+4,0x44);
			_outp(AWE32Base-0x400+5,Volume);
			_outp(AWE32Base-0x400+4,0x45);
			_outp(AWE32Base-0x400+5,Volume);
			}
	};
class AWE32Reverb : public Base
	{
	public:
		void ButtonFunction(int Data)
			{
			Reverb = Data*4;
			}
	};
class AWE32Chorus : public Base
	{
	public:
		void ButtonFunction(int Data)
			{                            
			Chorus = Data*4;
			}
	};
	
class Button
	{
	public:
		Base* FunctionPTR;
		virtual void ButtonDown(int MouseX,int MouseY) = 0;
		virtual void ButtonUp() = 0;
		virtual void ButtonMov(int MouseX,int MouseY) = 0;
		virtual int CheckButton(int MouseX,int MouseY) = 0;
		virtual void DrawButton(int Status) = 0;
	};

class BigButton : public Button
	{
	private:
		int xLoc,yLoc;
		int SlideLen;
		int Height,Width;
		int SlidePos;
		int xDown,yDown;
    public:  
	BigButton(int x,int y,int l)
		{
			xLoc = x;
			yLoc = y;
			SlideLen = l;
			Height = 19;
			Width = SlideLen + 12;
		}
	void ButtonDown(int MouseX,int MouseY)
		{
		SetMouseXLimits(MouseX,MouseX);
		SetMouseYLimits(MouseY,MouseY);
		}
	void ButtonUp()
		{
			SetMouseYLimits(0,479);
			SetMouseXLimits(0,639);
		}
	int CheckButton(int MouseX,int MouseY)
	    {
	    if(MouseX > (xLoc*8))
		if(MouseX < (xLoc*8+128))
			if(MouseY > (yLoc*16))
				if(MouseY < (yLoc*16+128))
					return 1;
		 return 0;
		 }
	void DrawButton(int Status)
		{
		
		}
	};
	
class VSlideButton : public Button
	{
	private:
		int xLoc,yLoc;
		int SlideLen;
		int Height,Width;
		int SlidePos;
		int xDown,yDown;
	public:
		VSlideButton(int x,int y,int l)                                                                 // Constructor
			{               
			xLoc = x;
			yLoc = y;
			SlideLen = l;
			Height = 19;
			Width = SlideLen + 12;
			}       
		void ButtonDown(int MouseX,int MouseY)
			{
			xDown = MouseX;
			yDown = MouseY;
			HideMouseCursor();
			SetMouseYLimits(MouseY-SlideLen+SlidePos,MouseY+SlidePos);
			SetMouseXLimits(MouseX,MouseX);
			}       
		void ButtonUp()
			{
			ShowMouseCursor();
			SetMouseYLimits(0,479);
			SetMouseXLimits(0,639);
			}
		void ButtonMov(int MouseX,int MouseY)
			{
			int Status = SlideLen-SlidePos;
			WaitRetrace();
			
			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+Status+1,xLoc+7,yLoc+Status+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+12,yLoc+Status+1,xLoc+17,yLoc+Status+10);
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+9,yLoc+Status+1,xLoc+10,yLoc+Status+10);
			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+11,yLoc+Status+1,xLoc+11,yLoc+Status+10);
			if(Status == SlideLen)
				_rectangle_w(_GFILLINTERIOR,xLoc+8,yLoc+Status+10,xLoc+10,yLoc+Status+10);
			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+8,yLoc+Status+1,xLoc+8,yLoc+Status+10);
			if(Status == 0)
				_rectangle_w(_GFILLINTERIOR,xLoc+9,yLoc+1,xLoc+11,yLoc+1);      

			SlidePos += yDown - MouseY;
			Status = SlideLen-SlidePos;
			
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+1+Status,xLoc+2,yLoc+Status+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+1+Status,xLoc+17,yLoc+Status+1);
			_rectangle_w(_GFILLINTERIOR,xLoc+17,yLoc+1+Status,xLoc+17,yLoc+Status+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+Status+10,xLoc+17,yLoc+Status+10);

			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+4,xLoc+14,yLoc+Status+7);

			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+3,yLoc+Status+2,xLoc+4,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+2,xLoc+16,yLoc+Status+3);

			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+16,yLoc+Status+2,xLoc+16,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+15,yLoc+Status+3,xLoc+15,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+8,xLoc+14,yLoc+Status+8);
			_rectangle_w(_GFILLINTERIOR,xLoc+4,yLoc+Status+9,xLoc+14,yLoc+Status+9);

			yDown = MouseY;

			FunctionPTR->ButtonFunction(SlidePos);
			}

		int CheckButton(int MouseX,int MouseY)
			{
			if(MouseX >= (xLoc+2))
				if(MouseX <= (xLoc+17))
					if(MouseY >= (yLoc+1+SlideLen-SlidePos))
						if(MouseY <= (yLoc+10+SlideLen-SlidePos))
							{
							xDown = MouseX;
							yDown = MouseY;
							return 1;
							}
			return 0;
			}
		void DrawButton(int Status)
			{
			SlidePos = Status;
			Status = SlideLen-Status;
			_setcolor(WHITE);                                          // White
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc,xLoc,yLoc+SlideLen+10);
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc,xLoc+18,yLoc);
			_rectangle_w(_GFILLINTERIOR,xLoc+11,yLoc+2,xLoc+11,yLoc+SlideLen+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+8,yLoc+SlideLen+11,xLoc+10,yLoc+SlideLen+10);
			_setcolor(GREY);                                           // Grey
			_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+1,xLoc+7,yLoc+SlideLen+10);                                     
			_rectangle_w(_GFILLINTERIOR,xLoc+12,yLoc+1,xLoc+19,yLoc+SlideLen+10);
	
			_setcolor(DKGREY);                                          // Dark grey
			_rectangle_w(_GFILLINTERIOR,xLoc+19,yLoc,xLoc+19,yLoc+SlideLen+11);
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc+SlideLen+11,xLoc+19,yLoc+SlideLen+11);
			_rectangle_w(_GFILLINTERIOR,xLoc+8,yLoc+1,xLoc+8,yLoc+SlideLen+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+9,yLoc+1,xLoc+11,yLoc+1);
				
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+1+Status,xLoc+2,yLoc+Status+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+1+Status,xLoc+17,yLoc+Status+1);
			_rectangle_w(_GFILLINTERIOR,xLoc+17,yLoc+1+Status,xLoc+17,yLoc+Status+10);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+Status+10,xLoc+17,yLoc+Status+10);
				
			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+4,xLoc+14,yLoc+Status+7);
				
			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+3,yLoc+Status+2,xLoc+4,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+2,xLoc+16,yLoc+Status+3);

			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+16,yLoc+Status+2,xLoc+16,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+15,yLoc+Status+3,xLoc+15,yLoc+Status+9);
			_rectangle_w(_GFILLINTERIOR,xLoc+5,yLoc+Status+8,xLoc+14,yLoc+Status+8);
			_rectangle_w(_GFILLINTERIOR,xLoc+4,yLoc+Status+9,xLoc+14,yLoc+Status+9);
			}
	};
	
class HSlideButton : public Button
	{
	private:
		int xLoc,yLoc;
		int SlideLen;
		int Height,Width;
		int SlidePos;
		int xDown,yDown;
	public:
		HSlideButton(int x,int y,int l)                                                                 // Constructor
			{               
			xLoc = x;
			yLoc = y;
			SlideLen = l;
			Height = 19;
			Width = SlideLen + 12;
			}       
		void ButtonDown(int MouseX,int MouseY)
			{
			xDown = MouseX;
			yDown = MouseY;
			HideMouseCursor();
			SetMouseYLimits(MouseY,MouseY);
			SetMouseXLimits(MouseX-SlidePos,SlideLen-SlidePos+MouseX);
			}       
		void ButtonUp()
			{
			ShowMouseCursor();
			SetMouseYLimits(0,479);
			SetMouseXLimits(0,639);
			}
		void ButtonMov(int MouseX,int MouseY)
			{
			WaitRetrace();
			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+1,yLoc+2,xLoc+SlidePos+10,yLoc+7);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+1,yLoc+12,xLoc+SlidePos+10,yLoc+17);
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+1,yLoc+9,xLoc+SlidePos+10,yLoc+10);
			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+1,yLoc+11,xLoc+SlidePos+10,yLoc+11);
			if(SlidePos == SlideLen)
				_rectangle_w(_GFILLINTERIOR,xLoc+SlideLen+10,yLoc+8,xLoc+SlideLen+10,yLoc+10);
			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+1,yLoc+8,xLoc+SlidePos+10,yLoc+8);
			if(SlidePos == 0)
				_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+9,xLoc+1,yLoc+11);      
			
			SlidePos += MouseX - xDown;
			
			WaitRetrace();
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+SlidePos,yLoc+2,xLoc+10+SlidePos,yLoc+2);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+SlidePos,yLoc+2,xLoc+1+SlidePos,yLoc+17);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+SlidePos,yLoc+17,xLoc+10+SlidePos,yLoc+17);
			_rectangle_w(_GFILLINTERIOR,xLoc+10+SlidePos,yLoc+2,xLoc+10+SlidePos,yLoc+17);
			
			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+4,yLoc+5,xLoc+SlidePos+7,yLoc+14);
					
			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+2,yLoc+3,xLoc+SlidePos+9,yLoc+4);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+2,yLoc+5,xLoc+SlidePos+3,yLoc+16);
					
			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+2,yLoc+16,xLoc+SlidePos+9,yLoc+16);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+3,yLoc+15,xLoc+SlidePos+9,yLoc+15);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+8,yLoc+5,xLoc+SlidePos+8,yLoc+14);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlidePos+9,yLoc+4,xLoc+SlidePos+9,yLoc+14);
			
			xDown = MouseX;

			FunctionPTR->ButtonFunction(SlidePos);
			}
			
		int CheckButton(int MouseX,int MouseY)
			{
			if(MouseX >= (xLoc+1+SlidePos))
				if(MouseX <= (xLoc+10+SlidePos))
					if(MouseY >= (yLoc+2))
						if(MouseY <= (yLoc+17))
							{
							xDown = MouseX;
							yDown = MouseY;
							return 1;
							}
			return 0;
			}
		void DrawButton(int Status)
			{
			SlidePos = Status;
			_setcolor(WHITE);                                          // White
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc,xLoc+SlideLen+10,yLoc);                                   
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc,xLoc,yLoc+18);
			_rectangle_w(_GFILLINTERIOR,xLoc+2,yLoc+11,xLoc+SlideLen+10,yLoc+11);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlideLen+11,yLoc+8,xLoc+SlideLen+10,yLoc+10);
			_setcolor(GREY);                                           // Grey
			_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+1,xLoc+SlideLen+10,yLoc+7);                                     
			_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+12,xLoc+SlideLen+10,yLoc+19);
	
			_setcolor(DKGREY);                                                                                  // Dark grey
			_rectangle_w(_GFILLINTERIOR,xLoc,yLoc+19,xLoc+SlideLen+11,yLoc+19);
			_rectangle_w(_GFILLINTERIOR,xLoc+SlideLen+11,yLoc,xLoc+SlideLen+11,yLoc+19);
			_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+8,xLoc+SlideLen+9,yLoc+8);
			_rectangle_w(_GFILLINTERIOR,xLoc+1,yLoc+9,xLoc+1,yLoc+11);
				
			_setcolor(BLACK);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+Status,yLoc+2,xLoc+10+Status,yLoc+2);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+Status,yLoc+2,xLoc+1+Status,yLoc+17);
			_rectangle_w(_GFILLINTERIOR,xLoc+1+Status,yLoc+17,xLoc+10+Status,yLoc+17);
			_rectangle_w(_GFILLINTERIOR,xLoc+10+Status,yLoc+2,xLoc+10+Status,yLoc+17);
				
			_setcolor(GREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+4,yLoc+5,xLoc+Status+7,yLoc+14);

			_setcolor(WHITE);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+2,yLoc+3,xLoc+Status+9,yLoc+4);
				_rectangle_w(_GFILLINTERIOR,xLoc+Status+2,yLoc+5,xLoc+Status+3,yLoc+16);
				
			_setcolor(DKGREY);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+2,yLoc+16,xLoc+Status+9,yLoc+16);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+3,yLoc+15,xLoc+Status+9,yLoc+15);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+8,yLoc+5,xLoc+Status+8,yLoc+14);
			_rectangle_w(_GFILLINTERIOR,xLoc+Status+9,yLoc+4,xLoc+Status+9,yLoc+14);
			}
	};

char Palette [] = { 0x00,0x00,0x00, 0x00,0x00,0x2A, 0x00,0x2A,0x00, 0x00,0x2A,0x2A, 
					0x2A,0x00,0x00, 0x2A,0x00,0x2A, 0x2A,0x2A,0x00, 0x2A,0x2A,0x2A,
					0x00,0x00,0x15, 0x00,0x00,0x3F, 0x18,0x18,0x18, 0x00,0x2A,0x3F,
					0x2A,0x00,0x15, 0x2A,0x00,0x3F, 0x2A,0x2A,0x3F, 0x3F,0x3F,0x3F };
char TempPalette[48];
 
void FadeIn()
	{
	for (int i=0; i<48; i++)
		TempPalette[i] = 0;
	
	for(int k=0; k<64; k++)
		{       
		for(int i=0; i<48; i++)
			{
			if(Palette[i] != TempPalette[i])
				TempPalette[i]++;
			}
		_outp(0x3C8,0);
		for(i=0; i<16; i++)
			{
			_outp(0x3C9,TempPalette[i*3]);
			_outp(0x3C9,TempPalette[i*3+1]);
			_outp(0x3C9,TempPalette[i*3+2]);
			}
		WaitRetrace();
		}
	}

void PlayScreen()
	{
	unsigned int MouseX,MouseY;

	_setcolor(WHITE);
	_settextposition(1,28);
	_outtext("Omega ModPlayer for AWE32");
	_settextposition(2,28);
	_outtext("-------------------------");

	_settextposition(4,5);
	_outtext("Playing: ");
	_outtext(Header->SongName);
	_settextposition(4,35);
	_outtext("Pattern: ");
	_settextposition(4,46);
	_outtext("/");
	TempSTR[0] = (Header->SongLength-1)/10+48;
	TempSTR[1] = ((Header->SongLength-1) - ((Header->SongLength-1)/10)*10)+48;
	TempSTR[2] = 0;
	_outtext(TempSTR);

	_settextposition(4,55);
	_outtext("Row: ");

	_settextposition(9,4);
	_outtext("Channel 1");
	_settextposition(11,4);
	_outtext("Channel 2");
	_settextposition(13,4);
	_outtext("Channel 3");
	_settextposition(15,4);
	_outtext("Channel 4");

	_settextposition(7,30);
	_outtext("Pan");

	Button* Buttons[10];
	Buttons[0] = new HSlideButton(125,128,255);
	Buttons[1] = new HSlideButton(125,160,255);
	Buttons[2] = new HSlideButton(125,192,255);
	Buttons[3] = new HSlideButton(125,224,255);
	Buttons[4] = new VSlideButton(45,280,63);
	Buttons[5] = new VSlideButton(170,280,63);
	Buttons[6] = new VSlideButton(270,280,63);
	Buttons[7] = new VSlideButton(320,280,63);
	Buttons[8] = new VSlideButton(390,280,63);
	Buttons[9] = new VSlideButton(440,280,63);
	Buttons[0]->FunctionPTR = new Chan0Pan;
	Buttons[1]->FunctionPTR = new Chan1Pan;
	Buttons[2]->FunctionPTR = new Chan2Pan;
	Buttons[3]->FunctionPTR = new Chan3Pan;
	Buttons[4]->FunctionPTR = new AWE32MVolume;
	Buttons[5]->FunctionPTR = new AWE32Volume;
	Buttons[6]->FunctionPTR = new AWE32Bass;
	Buttons[7]->FunctionPTR = new AWE32Treble;
	Buttons[8]->FunctionPTR = new AWE32Reverb;
	Buttons[9]->FunctionPTR = new AWE32Chorus;

	Buttons[0]->DrawButton(0);
	Buttons[1]->DrawButton(255);
	Buttons[2]->DrawButton(255);
	Buttons[3]->DrawButton(0);

	Buttons[4]->DrawButton((MainVolumeL+7)/4-1);
	Buttons[5]->DrawButton((SynthVolumeL+7)/4-1);
	Buttons[6]->DrawButton(BassL*4L/15-1);
	Buttons[7]->DrawButton(TrebleL*4L/15-1);
	Buttons[8]->DrawButton(Reverb/4);
	Buttons[9]->DrawButton(Chorus/4);

		_settextposition(24,2);
	_outtext("Main Volume");
		_settextposition(24,18);
	_outtext("Synth Volume");

		_settextposition(24,34);
	_outtext("Bass");
		_settextposition(24,40);
	_outtext("Treble");
		_settextposition(24,48);
	_outtext("Reverb");
		_settextposition(24,56);
	_outtext("Chorus");


	InitMouse();
	ShowMouseCursor();

	FadeIn();

	OldIRQ0 = _dos_getvect(IRQ0);
	_disable();
	_outp(0x40,0x38);                                                                               // Set up timer to interrupt 50 times/sec
	_outp(0x40,0x5D);
	_outp(0x43,0);
	_dos_setvect(IRQ0,Beat);
	_enable();

	int key;
	while( key != 27)
		{
		if(_kbhit() != 0)
			key = _getch();

		if((GetMousePos(&MouseX,&MouseY)&1))                                            // Is left mouse button pressed?
			for(int i=0; i<10; i++)
				if(Buttons[i]->CheckButton(MouseX,MouseY))          // Check all buttons
					{
					Buttons[i]->ButtonDown(MouseX,MouseY);

					while(GetMouseButtonStat()&1)
						if(MouseMov(&MouseX,&MouseY) == 1)
							Buttons[i]->ButtonMov(MouseX,MouseY);

					Buttons[i]->ButtonUp();
					break;
					}
		 }
	}


void Sleep(clock_t wait)
	{
	clock_t goal;

	goal = wait+clock();
	while(goal > clock());
	}

void SaveMixer()
	{
	_outp(AWE32Base-0x400+4,0x30);                                                  // Save main volume
	MainVolumeL = _inp(AWE32Base-0x400+5);
	_outp(AWE32Base-0x400+4,0x31);
	MainVolumeR = _inp(AWE32Base-0x400+5);

	_outp(AWE32Base-0x400+4,0x34);                          // Save synth volume
	SynthVolumeL = _inp(AWE32Base-0x400+5);
	_outp(AWE32Base-0x400+4,0x35);
	SynthVolumeR = _inp(AWE32Base-0x400+5);
	
	_outp(AWE32Base-0x400+4,0x44);                          // Save treble setting
	TrebleL = _inp(AWE32Base-0x400+5);
	_outp(AWE32Base-0x400+4,0x45);
	TrebleR = _inp(AWE32Base-0x400+5);
	
	_outp(AWE32Base-0x400+4,0x46);                          // Save bass setting
	BassL = _inp(AWE32Base-0x400+5);
	_outp(AWE32Base-0x400+4,0x47);
	BassR = _inp(AWE32Base-0x400+5);
	}
void RestoreMixer()
	{
	_outp(AWE32Base-0x400+4,0x30);                                                  // Restore main volume
	_outp(AWE32Base-0x400+5,MainVolumeL);
	_outp(AWE32Base-0x400+4,0x31);
	_outp(AWE32Base-0x400+5,MainVolumeR);
	
	_outp(AWE32Base-0x400+4,0x34);                          // Restore synth volume
	_outp(AWE32Base-0x400+5,SynthVolumeL);
	_outp(AWE32Base-0x400+4,0x35);
	_outp(AWE32Base-0x400+5,SynthVolumeR);

	_outp(AWE32Base-0x400+4,0x44);                          // Restore treble setting
	_outp(AWE32Base-0x400+5,TrebleL);
	_outp(AWE32Base-0x400+4,0x45);
	_outp(AWE32Base-0x400+5,TrebleR);

	_outp(AWE32Base-0x400+4,0x46);                          // Restore bass setting
	_outp(AWE32Base-0x400+5,BassL);
	_outp(AWE32Base-0x400+4,0x47);
	_outp(AWE32Base-0x400+5,BassR);
	}

/*****************/
/* Main function */
/*****************/
void main(int argc,char* argv[], char* envp[])
	{
	char* Bug = argv[1];

	_initgraphics();

	if(AWE32Detect() != 0)
		ExitWithError("Creative Labs Sound Blaster AWE32 not found");

	AWE32Init();
	CheckDRAM();
	if(DRAMSize == 0)
		ExitWithError("Your AWE32 doesn't have any RAM");

	SaveMixer();
	 SetReverbEffect(Room1);
		SetChorusEffect(Chorus3);

	 if((argc < 2) || (argc > 3))                                                                                  // first argument is our program
		ExitWithError("Usage: awe32mod example.mod [/on]\n\t/o  - automatic oversampling (default)\n\t/on - n-times oversampling (max. 5)");         // second argument is sound file

	 if((argc == 3) && (strncmpi(argv[2],"/o",2) == 0))
		{
		MAXOVERSAMPLES = min(4,atoi(argv[2]+2));
		if (MAXOVERSAMPLES == 0)
			MAXOVERSAMPLES = 4;
		}

	 if((Soundfile = fopen(Bug,"rb")) == NULL)              // open sound file
		ExitWithError("Could not open file");                   // file not found

	 fread(Header,1,sizeof(SongInfo),Soundfile);                    // read header
	 if(strncmp(Header->FileID,"M.K.",4))
		ExitWithError("File not a 31 sample 4 channel sound module");

	 cout << "SoundBlaster AWE32 found at " << hex << AWE32Base << "H";
	 cout << " with " << dec << DRAMSize << "kB onboard DRAM" << endl;
	 cout << endl;

	for(int k=0; k<128; k++)
		{
		if (Header->PattSeq[k] > NumberOfPatterns)
			NumberOfPatterns = Header->PattSeq[k];                  // get number of patterns in song
		}

	NumberOfPatterns++;

	for(k=0; k<NumberOfPatterns; k++)
		{
		Patt[k] = new Pattern;
		fread(Patt[k],1,1024,Soundfile);
		}

	DecodePatterns();

	LoadInstruments();
	Sleep(1500);

	Channel[0].Pan = Left;
	Channel[1].Pan = Right;
	Channel[2].Pan = Right;
	Channel[3].Pan = Left;
	for(i=0; i<4; i++)
		{
		Channel[i].Status = 0;
		Channel[i].FirstNote = 1;
		Channel[i].VolumeSlide = 0;
		Channel[i].PitchSlide = 0;
		Channel[i].MaxSlide = 113;
		Channel[i].MinSlide = 856;
		Channel[i].ArpeggioD[0] = 0;
		}
	CalcLogTable();

	_setvideomode(_VRES16COLOR);                           // 640*480 in 16 colors

	_clearscreen(_GCLEARSCREEN);

	_outp(0x3C8,0);
	for(i=0; i<48; i++)
		_outp(0x3C9,0);
	Sleep(750);

	PlayScreen();

	_disable();                                                                             // Return timer to normal operation
	for(i=0; i<4; i++)
		if(Channel[i].FirstNote == 0)
			NoteOff(Channel[i].AWE32Chan);

	_outp(0x40,0);
	_outp(0x40,0);
	_outp(0x43,0);
	_dos_setvect(IRQ0,OldIRQ0);

	regs.x.ax = 2;
	int86(0x33,&regs,&regs);
	_setvideomode(_DEFAULTMODE);                                                           // Return to same video mode
	RestoreMixer();
	}
