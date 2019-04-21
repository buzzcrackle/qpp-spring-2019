// pins a4-7 for the motor control
int mc1 = A4
int mc2 = A5
int mc3 = A6
int mc4 = A7
void setup() {
  // put your setup code here, to run once:
  pinMode(mc1, OUTPUT);
  pinMode(mc2, OUTPUT);
  pinMode(mc3, OUTPUT);
  pinMode(mc4, OUTPUT);
}

int num = 0;
void loop() {
  // put your main code here, to run repeatedly:
  int i;
  for (i = 0; i < 256; i++) {
    digitalWrite(mc1, i);
    digitalWrite(mc3, i);
    delay(100);
  }
  for (i = i; i >= 0; i--) {
    digitalWrite(mc1, i);
    digitalWrite(mc3, i);
    delay(100);
  }
  for (i = 0; i < 256; i++) {
    digitalWrite(mc2, i);
    digitalWrite(mc4, i);
    delay(100);
  }
  for (i = i; i >= 0; i--) {
    digitalWrite(mc2, i);
    digitalWrite(mc4, i);
    delay(100);
  }
}
