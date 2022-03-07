#include <math.h>

float logR2, R2, T;
float c1 = 1.009249522e-03, c2 = 2.378405444e-04, c3 = 2.019202697e-07;
// float c1 = 0.001129148, c2 = 0.000234125, c3 = 0.0000000876741;


void setup() {
  Serial.begin(9600);
  Serial.println("[+] Listening");
}

void loop() {
  int raw = analogRead(A0);

  float R1 = 10.0e3;
  float R2 = R1 * raw / (1024.0 - raw);

  // Resistance to temp using Steinhart-Hart equation
  // http://playground.arduino.cc/ComponentLib/Thermistor2 

  // Temperature in K
  float T = 1.0 / (1.0 / 298.15f + (1.0 /4300.0) * log( R2 / 50e3));

  // Temp in Celcius
  T = T - 273.15;

  // Temp in F
  T = T * 9.0 / 5.0 + 32.0; 

  //Serial.print("ADC: ");
  //Serial.print(raw);
  //Serial.print(", Volts: ");
  //Serial.print(raw * 5.14 / 1024.0);
  //Serial.print(", Resistance: ");
  //Serial.print(R2);
  //Serial.print(", Temp F: ");
  Serial.println(T);
  
  //Serial.println(R2);
  Serial.flush();

  delay(500);
}
