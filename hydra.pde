int opoof[9] = {2,3,4,5,6,7,8,9,10};
int opoofled[9] = {20,21,22,23,24,25,26,27,28};
int ipoofbtn[9] = {29,30,31,32,33,34,35,36,37};
int ostepled[12] = {48,49,38,40,39,41,42,43,44,45,46,47};
int irandombtn = 11;
int orandomled = 12;
int iallpoofbtn = 14;
int oallpoofled = 15;
int imusic = 16;
int omusicled = 17;
int inumsteps = 0;
int isetstep = 1;
int isteplength = 2;
int ipooflength = 3;

int poofstate[9] = {LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW};
int poofcount[9] = {0,0,0,0,0,0,0,0,0};
int musicstate[12][9] = {{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW},{LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW,LOW}};
int numsteps = 0;
int currstep = 0;
int nextstep = 0;
int setstep = 0;
int steplength = 0;
int pooflength = 0;
int randpoofprob = 0;
int randpooflength = 0;
long allpoofprob = 0;
int lastbtnpressed = 0;
int lastpressedtime = 0;
#define keybouncetime 50
int i=0;
int j=0;
int k=0;
int mode = 0;
int blinkcount = 0;
int blinkflipflop = LOW;
int btncount = 0;

void setup(){
  for (i=0;i<9;i++){
    pinMode(opoof[i], OUTPUT);
    pinMode(opoofled[i], OUTPUT);
    pinMode(ipoofbtn[i], INPUT);
  }
  for (i=0;i<12;i++){
    pinMode(ostepled[i], OUTPUT);
  }
  pinMode (irandombtn, INPUT);
  pinMode (orandomled, OUTPUT);
  pinMode (iallpoofbtn, INPUT);
  pinMode (oallpoofled, OUTPUT);
  pinMode (imusic, INPUT);
  pinMode (omusicled, OUTPUT);
  randomSeed(analogRead(5));
}

void loop(){
  domode();
  switch (mode){
    case 0:// no sequence, poof from buttons
      for (i=0;i<9;i++){
        if (digitalRead(ipoofbtn[i])){
          poofstate[i] = HIGH;
        }
        else{
          poofstate[i] = LOW;
        }
      }
     break;
    case 1://musical sequence
      numsteps = readknob(inumsteps);
      setstep = readknob(isetstep);
      steplength = 10 + (1023-analogRead(isteplength))/10;
      pooflength = 10 + (1023-analogRead(ipooflength))/10;
      for (k=0; k < 12; k++) {
        if (k <= numsteps && (k != currstep || currstep == setstep)){// turn on step leds
          if (k == setstep){//blink led for current step
            if (blinkcount < 1){
              if (blinkflipflop){
                blinkflipflop = LOW;
                blinkcount = 10;
              }
              else {
                blinkflipflop = HIGH;
                blinkcount = 40;
              }
            }
            digitalWrite(ostepled[k], blinkflipflop);
          }
          else {
            digitalWrite(ostepled[k], HIGH);
          }
        }
        else {
            digitalWrite(ostepled[k], LOW);
        }
      }
      if (setstep <= numsteps) {
        for (k=0; k<9; k++){
          if (readbtn(ipoofbtn[k])){
            musicstate[setstep][k] = musicstate[setstep][k]?LOW:HIGH;
          }
          digitalWrite(opoofled[k], musicstate[setstep][k]);
        }
      }
      if (j>steplength){
        j=0;
        currstep=nextstep;
        nextstep=(currstep+1)>numsteps?0:currstep+1;
        for (i=0; i<9; i++){
          if(musicstate[currstep][i]){
            if ((currstep != nextstep) && musicstate[nextstep][i]){
              poofcount[i]=steplength+1;
            }
            else {
              poofcount[i] = pooflength;
            }
            poofstate[i] = HIGH;
          }
        }
      }
      for (i=0; i<9; i++){
        if (poofcount[i] <= 0){
          poofstate[i] = LOW;
        }
        else {
          poofcount[i]--;
        }
      }
      j++;
    break;
    case 2:// random
      randpoofprob = 3 + 3 * (1023 - analogRead(isteplength));
      randpooflength = 10 + (1023 - analogRead(ipooflength))/10;
      allpoofprob = randpoofprob * 50;
      for (i=0; i<9; i++){
        if (poofcount[i] > 0) {
          poofstate[i] = HIGH;
          poofcount[i]--;
        }
        else {
          if (random(randpoofprob) == 3){
            poofcount[i] = randpooflength;
            poofstate[i] = HIGH;
          }
          else {
            poofstate[i] = LOW;
          }
        }
      }
      if (random(allpoofprob) == 3){
        for (i=0; i<9; i++){
          poofstate[i] = HIGH;
          poofcount[i] = randpooflength;
        }
      }
    break;
    case 3:// allpoof
      for (i=0; i<9; i++){
        poofstate[i]=HIGH;
      } 
    break;
   
  }
  for (i=0; i<9; i++){
    digitalWrite(opoof[i], poofstate[i]);
    if (mode != 1 || setstep > numsteps) {
      digitalWrite(opoofled[i], poofstate[i]);
    }
  }
  blinkcount--;
  btncount = btncount < 1 ? btncount -- : 0;
  delay(10);
}


int readknob(int knob){
  int divs[14]={-100, 0, 92, 185, 278, 372, 465, 558, 651, 744, 837, 930, 1023, 1200};
  int thisreading = analogRead(knob);
  int upperlimit;
  int lowerlimit;
  int out;
  for (i=1;i<13;i++){
    upperlimit = divs[i] + ((divs[i+1] - divs[i]) / 2);
    lowerlimit = divs[i] - ((divs[i] - divs[i-1]) / 2);
    if (thisreading >= lowerlimit && thisreading < upperlimit){
      out = i-1;
    }
  }
  return out;
}

int readbtn(int btn){
  int out = false;
  if (digitalRead(btn)){
    if (lastbtnpressed != btn){
      out = true;
    }
    lastbtnpressed = btn;
    btncount = keybouncetime;
  }
  else if (lastbtnpressed == btn && btncount < 1) {
    lastbtnpressed = 0;
  }
  return out;
}

void domode(){
  int newmode = mode;
  if (readbtn(imusic)){
    if (mode == 1) {
      newmode = 0;
    }
    else {
      newmode = 1;
    } 
  }
  else if (readbtn(irandombtn)){
    if (mode == 2) {
      newmode = 0;
    }
    else {
      newmode = 2;
    }
  }
  else if (digitalRead(iallpoofbtn)){
    newmode = 3;
  }
  else if (mode==3){
    newmode = 0;
  }
  if (newmode != mode){
    for (k=0; k<9; k++){
      poofcount[k] = 0;
      poofstate[k]=LOW;
      digitalWrite(opoofled[k],LOW);
    }
    for (k=0; k<12; k++){
      digitalWrite(ostepled[k],LOW);
    }
    switch(newmode){
      case 0:          
        digitalWrite(omusicled, LOW);
        digitalWrite(orandomled, LOW);
        digitalWrite(oallpoofled, LOW);
      break;
      case 1:
        digitalWrite(omusicled, HIGH);
        digitalWrite(orandomled, LOW);
        digitalWrite(oallpoofled, LOW);
        currstep=0;
        nextstep=0;
        j=10000;
      break;
      case 2:
        digitalWrite(omusicled, LOW);
        digitalWrite(orandomled, HIGH);
        digitalWrite(oallpoofled, LOW);
      break;
      case 3:
        digitalWrite(omusicled, LOW);
        digitalWrite(orandomled, LOW);
        digitalWrite(oallpoofled, HIGH);
      break;
    }
    if (digitalRead(iallpoofbtn) && digitalRead(imusic)){
      for (i=0; i<12; i++){
        for (k=0; k<9; k++) {
          musicstate[i][k]=LOW;
        }
      }
    }
    mode = newmode;
  }
}
 