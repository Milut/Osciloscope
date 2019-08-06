int v1 = 0;
boolean s1 = true;
int v2 = 0;
boolean s2 = true;
int v3 = 0;
boolean s3 = true;
int count = 0;
void setup() {
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);

}

void loop() {
  if (v1 == 255) {
    s1 = false;
  } else if (v1 == 0) {
    s1 = true;
  }
  if (v2 == 255) {
    s2 = false;
  } else if (v2 == 0) {
    s2 = true;
  }
  if (v3 == 255) {
    s3 = false;
  } else if (v3 == 0) {
    s3 = true;
  }
  if (s1) {
    v1++;
  } else {
    v1--;
  }

  if (count % 3 == 0) {
    if (s2) {
      v2++;
    } else {
      v2--;
    }
  }

  if (count % 10 == 0) {
    if (s3) {
      v3++;
    } else {
      v3--;
    }
  }

  digitalWrite(9, v1);
  digitalWrite(10, v2);
  digitalWrite(11, v3);


  count++;
}
