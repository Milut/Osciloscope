#include <SPI.h>
#include <SpiRAM.h>

#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit)) //0
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))  //1
#define SS_PIN 10
#define Ch0 A0
#define Ch1 A1

byte clock = 0;
SpiRAM SpiRam(0, SS_PIN);
int preTrigger = 200;
const int buffSize = 3200 + preTrigger;
int triggerLevel = 500;
int countdown = buffSize - preTrigger;
int timeStart;
int memPos = 0;
int trigPos = 0;

bool trig = false;

void setup()
{
  sbi(ADCSRA, ADPS2);
  cbi(ADCSRA, ADPS1);
  cbi(ADCSRA, ADPS0);
  
  pinMode(Ch0, INPUT);
  pinMode(Ch1, INPUT);
  Serial.begin(230400);
}

int byteBuff = buffSize * 4;
bool r = true;
void loop()
{
  if(Serial.available()){
    char code = Serial.read();
    if(code == 'T'){
      restartTrigger();
    }
  }
  if(r){
  if(memPos > byteBuff){
    memPos = 0;
  }
  int v1 = 0;
  int v2 = 0;
  if (countdown > 0)
  {
    v1 = analogRead(Ch0);
    v2 = analogRead(Ch1);
    pushToRam(v1,v2);
  }
  if (trig)
  {
    if (timeStart == 0)
    {
      timeStart = millis();
    }
    countdown--;
    triggerAction();
  }
  else
  {
    if (v1 > triggerLevel)
    {
      trig = true;
      trigPos = memPos;
    }
  }
  }
}

void restartTrigger(){
  countdown = buffSize - preTrigger;
  r = true;
}

void triggerAction()
{
  if (countdown == 0)
  {
    timeStart = millis() - timeStart;
    memPos = trigPos - preTrigger * 4;
    if(memPos < 0){
      memPos += byteBuff;
    }
    int t1 = millis();
    pushToSerial();
    t1 = millis() - t1;
//    Serial.println("Took: "+t1);
    timeStart = 0;
    delay(1500);
    trig = false;
    countdown = -1;
    r = false;
  }
}

void pushToSerial(){
  for (int i = 0; i < buffSize; i++)
  {
    int tmp[2];
    pullFromRam(tmp);
    Serial.print(tmp[0], DEC);
    Serial.print(":");
    Serial.println(tmp[1], DEC);
    if (memPos > buffSize * 4)
    {
      memPos = 0;
    }
  }
  Serial.print("T");
  Serial.println(timeStart);
}

void pushToRam(int v1, int v2)
{
  byte tmp[4];
  intToByte4(v1, v2, tmp);
//  SpiRam.write_stream(memPos, tmp, 4);
  SpiRam.write_byte(memPos,tmp[0]);
  memPos++;
  SpiRam.write_byte(memPos,tmp[1]);
  memPos++;
  SpiRam.write_byte(memPos,tmp[2]);
  memPos++;
  SpiRam.write_byte(memPos,tmp[3]);
  memPos++;
//  memPos += 4;
}

void pullFromRam(int result[])
{
  byte tmp[4];
  SpiRam.read_stream(memPos, tmp, 4);
  byteToInt4(tmp, result);
  memPos += 4;
}

void intToByte(int i, byte arr[])
{
  arr[0] = i / 256;
  arr[1] = i % 256;
}
void intToByte4(int v1, int v2, byte arr[])
{
  arr[0] = v1 / 256;
  arr[1] = v1 % 256;
  arr[2] = v2 / 256;
  arr[3] = v2 % 256;
}

int byteToInt(byte arr[])
{
  return arr[0] * 256 + arr[1];
}

void byteToInt4(byte arr[], int result[])
{
  result[0] = arr[0] * 256 + arr[1];
  result[1] = arr[2] * 256 + arr[3];
}
