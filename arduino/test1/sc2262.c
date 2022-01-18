// From https://forum.arduino.cc/t/controlling-remote-controlled-sockets-sc2262-emulation-by-arduino/60513/
//
// Also see rtl_433 code here: https://github.com/merbanan/rtl_433/blob/master/src/devices/generic_remote.c  
//
// Also see RFSwitch code for protocols: https://github.com/sui77/rc-switch/blob/master/RCSwitch.cpp 
//
#define TRANSMITTER 13 // The Arduino output pin 13 is used to drive 433 MHz AM transmitter
#define SC2262Clock 100 // SC2262 internal clock is run at 10KHz for “smj” transmitter device (3.3MOhm timing resistor), therefore 100 microSecond wavelength

// sc2262pins is an array that indicates the voltage applied to the simulated SC2262 chip pins
char sc2262pins = “FFFFFFFFFFFF”; // H=High, L=Low or F=Floating for 12 pins

// These globals are defaults, for different devices they are changed by “SetSC2262Clock()”.
// 16 cycles per bit, 2 bits per SC2262 tri-state address/data pin, 12 address/data pins on SC2262
int DurationShort;
int DurationLong;
int DurationSyncShort;
int DurationSyncLong;

// -----------------------------------------------------------------------------
// Basic SC2262 output emulation

// Input wavelength of SC2262 internal clock in micro-seconds to get revised timings for basic components of packet that simulates SC2262 output
void setSC2262Clock (int sc2262Clock) { // One bit of two-bit tri-state pin state takes 16 cycles
  DurationShort = sc2262Clock * 4; // 4 clock cycles for short part of bit
  DurationLong = sc2262Clock * (16-4); // 12 clock cycles for long part of bit
  DurationSyncShort = sc2262Clock * 4; // Sync bit has a 4 cycle/short “high”, followed by 124 bit “low”
  DurationSyncLong = sc2262Clock * (128-4); // Sync bit has a 4 cycle/short “high”, followed by 124 bit “low”
}

void longShort () {
  digitalWrite (TRANSMITTER, HIGH);
  delayMicroseconds (DurationLong);
  digitalWrite (TRANSMITTER, LOW);
  delayMicroseconds (DurationShort);
}

void shortLong () {
  digitalWrite (TRANSMITTER, HIGH);
  delayMicroseconds (DurationShort);
  digitalWrite (TRANSMITTER, LOW);
  delayMicroseconds (DurationLong);
}

// Sync has a long pause after packet sent
void sync () {
  digitalWrite (TRANSMITTER, HIGH);
  delayMicroseconds (DurationSyncShort);
  digitalWrite (TRANSMITTER, LOW);
  delayMicroseconds (DurationSyncLong);
}

// Tri-state logic on/off/float of signals emulated here
void pinLow () {
  shortLong ();
  shortLong ();
}

void pinHigh () {
  longShort ();
  longShort ();
}

void pinFloat () {
  shortLong ();
  longShort ();
}

void syncBit () {
  sync();
}

void sendOneSC2262Packet () {
  noInterrupts();

  // 12-bit number
  for (int i=0; i<12; i++) {
    switch (sc2262pins*)
    {
      case ‘H’:
        pinHigh();
        break;
      case ‘L’:
        pinLow();
        break;
      case ‘F’:
        pinFloat();
        break;
    }
  } 
  syncBit ();
  interrupts();
}
