//const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
const char DATA[] = {12, 11, 10, 9, 8, 7, 6, 5, 4, 3};
#define CLOCK 2
#define PULSE 13

void setup() {
//  for (int n = 0; n < 16; n += 1) {
//    pinMode(ADDR[n], INPUT);
//  }
  for (int n = 0; n < 8; n += 1) {
    pinMode(DATA[n], INPUT);
  }
  pinMode(CLOCK, INPUT);
  pinMode(PULSE, INPUT);

  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);

  Serial.begin(57600);
}

void onClock() {
  char output[15];

//  unsigned int address = 0;
//  for (int n = 0; n < 16; n += 1) {
//    int bit = digitalRead(ADDR[n]) ? 1 : 0;
//    Serial.print(bit);
//    address = (address << 1) + bit;
//  }
//
//  Serial.print("   ");

  unsigned int data = 0;
  for (int n = 0; n < 10; n += 1) {
    int bit = digitalRead(DATA[n]) ? 1 : 0;
    Serial.print(bit);
    data = (data << 1) + bit;
  }

  sprintf(output, " %d %d", data, digitalRead(PULSE));
  Serial.println(output);
}

#define DELAY 1000000
void loop() {

}
