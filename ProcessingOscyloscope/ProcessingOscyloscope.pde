import processing.serial.*;

Serial serial;
public int c0;
public int [] c0Data;
public int c1;
public int [] c1Data;
public int m = 1;
public String tmpStr;
public int timeReadout;
public int preTrigger = 200;
public int triggerLevel = 500;
final int w = 3200 + 1 + preTrigger;
public int offset;
int peak1 = 0;
int peak2 = 0;
void setup()
{
  serial = new Serial(this, Serial.list()[1], 230400);
  serial.bufferUntil('\n');
  size(1600, 600);
  tmpStr = "";
  c0Data = new int [w];
  c1Data = new int [w];
  smooth();
  frameRate(60);
  timeReadout = 1;
  //offset = (w-width)/2;
  offset = 0;
}

void smoothOut() {
  for (int i = 2; i < w - 2; i++) {
    if (abs(c0Data[i] - c0Data[i-1]) > 50) {
    }
  }
}

int getY(int val) {
  return (int)(height - val / 1023.0f * (height - 1));
}
//int max;
//int min;
void drawLines() {
  int max = 0;
  int min = 1023;
  stroke(0, 255, 0);
  int displayWidth = (int) (width / m);
  int k = offset;
  //println(k);
  int cx0 = 0;
  int cy0 = getY(c0Data[k]);
  for (int i=1; i<displayWidth-1; i++) {
    k++;
    if (max < c0Data[k]) {
      max = c0Data[k];
    }
    if (min > c0Data[k]) {
      min = c0Data[k];
    }
    int cx1 = (int) (i * (width-1) / (displayWidth-1));
    int cy1  = 0;
    cy1 = getY((c0Data[k]+c0Data[k-1]+c0Data[k+1])/3);
    line(cx0, cy0, cx1, cy1);
    cx0 = cx1;
    cy0 = cy1;
  }
  stroke(0, 0, 255);
  k = offset;
  //println(k);
  int max2 = 0;
  int min2 = 1023;
  int x0 = 0;
  int y0 = getY(c0Data[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int y1  = 0;
    y1 = getY((c1Data[k]+c1Data[k-1]+c1Data[k+1])/3);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
    if (max2 < c1Data[k]) {
      max2 = c1Data[k];
    }
    if (min2 > c1Data[k]) {
      min2 = c1Data[k];
    }
  }
  stroke(100, 255, 100);
  text(max, 5, getY(max)-2);
  line(0, getY(max), width, getY(max));
  text(min, 5, getY(min)-2);
  line(0, getY(min), width, getY(min));

  stroke(100, 100, 255);
  text(max2, 5, getY(max2)-2);
  line(0, getY(max2), width, getY(max2));
  text(min2, 5, getY(min2)-2);
  line(0, getY(min2), width, getY(min2));

  stroke(50, 255, 255);
  int step = 60;
  line(preTrigger-offset, getY(min(min, min2) - step), preTrigger-offset, getY(max(max, max2) + step));
  line(preTrigger-offset, getY(min(min, min2) - step), width, getY(min(min, min2) - step));
  text((timeReadout/(w/width))+"ms", 220, getY((min(min, min2) - step))+12);
  if (!mouseFinished) {
    rect(mX1, mY1, mX2, mY2);
  } else {
    fill(255);
  }
}


void drawGrid() {
  stroke(125, 0, 0);
  line(0, height/2, width, height/2);
  stroke(255);
  line(0-offset, getY(triggerLevel), preTrigger-offset, getY(triggerLevel));
  if (peak1 > 0) {
    line(peak1 - offset, 50, peak1 - offset, getY(400));
    line(peak1 - offset, 50, peak2 - offset, 50);
    //println("p2: "+peak1);
  }
  if (peak2 > 0) {
    line(peak2 - offset, 50, peak2 - offset, getY(400));
    text(nf((float)freq,2,  1)+"Hz", (peak1+peak2)/2 - 20, 45);
  }
}
int mX1;
int mY1;
int mX2;
int mY2;
boolean mouseFinished = true;
void  mousePressed() {
  mouseFinished = false;
  mX1 = mouseX;
  mY1 = mouseY;
}
int holdCounter = 0;

void mouseHeld() {
  if (mousePressed && (mouseButton == LEFT)) {
    holdCounter++;
    mX2 = mouseX-mX1;
    mY2 = mouseY-mY1;
  }
}
double freq;
void mouseReleased() {
  mouseFinished = true;
  holdCounter = 0;
  peak1 = getPeakPos(mX1, mX1+(mX2/2), c0Data);
  peak2 = getPeakPos(mX1+(mX2/2), mX1+mX2, c0Data);
  println("m1: "+mX1 + " p1: " + peak1);
  println("m2: "+mX2 + " p2: " + peak2);
  freq = getFreq(peak1, peak2);
  println(nf((float)freq,2,  1)+"Hz");
}

double getFreq(int x1, int x2) {
  double sampleTime = ((double)(w-preTrigger) / (double)timeReadout);
  //String t = ""+sampleTime;
  //println(w-preTrigger + " " + timeReadout);
  println("sampleTime: "+sampleTime);
  println("sample count: "+abs(x1 - x2));
  return 1000 / (abs(x1 - x2) / sampleTime);
}

int getPeakPos(int pos1, int pos2, int [] data) {
  int max = 0;
  int maxi = 0;
  for (int i = pos1; i < pos2; i++) {
    if (data[i] > max) {
      max = data[i];
      maxi = i;
    }
  }
  return maxi;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      offset -= 10;
    }
    if (keyCode == RIGHT) {
      offset += 10;
    }
    if (keyCode == DOWN) {
      offset -= 50;
    }
    if (keyCode == UP) {
      offset += 50;
    }
    if (keyCode == TAB) {
      println("sending!");
      serial.write(85);
    }
  }else{
    if(key == ' '){
      println("sending!");
      serial.write('T');
      peak1 = 0;
      peak2 = 0;
    }
  }
  if (offset < 0) {
    offset = 0;
  }
  if (offset > (w-width)) {
    offset = (w-width)-1;
  }
}
void draw()
{
  background(0);
  drawGrid();
  drawLines();
  text(frameRate, 5, 15);
  mouseHeld();
}

void pushValue0(int v) {
  for (int i=0; i<w-1; i++) {
    c0Data[i] =c0Data[i+1];
  }
  c0Data[w-1] = v;
}
void pushValue1(int v) {
  for (int i=0; i<w-1; i++) {
    c1Data[i] = c1Data[i+1];
  }
  if (abs(c1Data[w-2] - v) > 20 && c1Data[w-2] != 0) {
    println("Drop!");
  }
  c1Data[w-1] = v;
  //}
}


int serialCount = 0;
boolean sc = false;
boolean hitLow = false;
boolean hitHigh = false;
void serialEvent(Serial s) {
  //serialCount++;

  while (serial.available() > 0) {
    tmpStr = s.readString().trim();
    if (tmpStr.startsWith("T")) {
      timeReadout = int(tmpStr.replace("T", ""));
      println(tmpStr);
    } else {
      int tmp = int(tmpStr.split(":")[0]);
      pushValue0(tmp);
      if (tmp > 1000) {
        hitHigh = true;
      }
      tmp = int(tmpStr.split(":")[1]);
      pushValue1(tmp);
      if (tmp < 5) {
        hitLow = true;
      }
    }
  }
  if (hitLow) {
    //println("Hit low!");
  }
  if (hitHigh) {
    //println("Hit high!");
  }
  hitLow = false;
  hitHigh = false;
}
