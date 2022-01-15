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

  s.enableReceive(digitalPinToInterrupt(2));
  s.enableTransmit(4);
  s.setRepeatTransmit(10);
  //attachInterrupt(digitalPinToInterrupt(2), handleInterrupt, CHANGE);

  Serial.println("[+] Listening");
}

void loop() {

  unsigned long value = 2796202; 
  s.send(value, 32);

  if (s.available()) {
    // digitalWrite(LED_BUILTIN, true);
    Serial.println("Received!");
    Serial.println(s.getReceivedValue());
    Serial.flush();

    // echo the received value
    //s.send(value, s.getReceivedBitLength());

    s.resetAvailable();
    // digitalWrite(LED_BUILTIN, false);
  }
  delay(2000);
}
