#include <RCSwitch.h>

RCSwitch s = RCSwitch();
volatile byte state = LOW;

static void handleInterrupt() {
  state = !state;
  digitalWrite(LED_BUILTIN, state);
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.begin(9600);

  //s.enableTransmit(4);
  //s.setRepeatTransmit(1);
  //attachInterrupt(digitalPinToInterrupt(2), handleInterrupt, CHANGE);
  s.enableReceive(digitalPinToInterrupt(2));

  Serial.println("[+] Listening");
}

void loop() {

  //unsigned long value = 7; 
  //s.send(value, 32);

  if (s.available()) {
    // digitalWrite(LED_BUILTIN, true);
    //Serial.println("Received!");
    //Serial.println(s.getReceivedValue());
    //Serial.println(s.getReceivedBitlength());
    //Serial.println(s.getReceivedProtocol());
    Serial.print("#");
    Serial.flush();
    s.resetAvailable();

    // echo the received value
    //s.send(value, s.getReceivedBitLength());
    // digitalWrite(LED_BUILTIN, false);
  }
  delay(5);
}
