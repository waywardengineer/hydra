int opoof[9] = {3,4,5,6,7,8,9,10,11};
int opoofled[9] = {12,14,15,16,17,18,19,20,21};
int ipoofbtn[9] = {22,23,24,25,26,27,28,29,30};
int irandombtn = 31;
int orandomled = 32;
int iallpoofbtn = 33;
int oallpoofled = 34;
int imusic = 35;
int omusicled = 36;
int osetstepled = 37;
int inumsteps = 1;
int isetstep = 2;
int isteplength = 3;
int ipooflength = 4;

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
#define keybouncetime 100
int i=0;
int j=0;
int k=0;
int mode = 0;


void setup(){
  for (i=0;i<9;i++){
    pinMode(opoof[i], OUTPUT);
    pinMode(opoofled[i], OUTPUT);
    pinMode(ipoofbtn[i], INPUT);
  }  
  pinMode (irandombtn, INPUT);
  pinMode (orandomled, OUTPUT);
  pinMode (iallpoofbtn, INPUT);
  pinMode (oallpoofled, OUTPUT);
  pinMode (imusic, INPUT);
  pinMode (omusicled, OUTPUT);
  pinMode (osetstepled, OUTPUT); 
  randomSeed(analogRead(0));
}

void loop(){
  domode();
  if (mode == 1){
    numsteps=readknob(inumsteps);
    steplength = 10 + analogRead(isteplength)/10;
    pooflength = 10 + analogRead(ipooflength)/10;
    if (readknob(isetstep) != setstep){
      setstep = readknob(isetstep);
      domusicleds();
    }
    for (i=0; i<9; i++){
      if (readbtn(ipoofbtn[i])){
        musicstate[setstep][i] = musicstate[setstep][i]?LOW:HIGH;
        digitalWrite(opoofled[i], musicstate[setstep][i]);
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
  }  
  if (mode == 2){
    randpoofprob = 3 + 3 * analogRead(isteplength);
    randpooflength = 10 + analogRead(ipooflength)/100;
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
  }
  for (i=0; i<9; i++){
    digitalWrite(opoof[i], poofstate[i]);
  }
  delay(10);  
}


int readknob(int knob){
  int divs[14]={1200, 1023, 1000, 900, 800, 700, 650, 600, 550, 500, 450, 350, 300, -100};
  int thisreading = analogRead(knob);
  int upperlimit;
  int lowerlimit;
  int out;
  for (i=1;i=12;i++){
    upperlimit = divs[i] + (divs[i-1] - divs[i]) / 2;
    lowerlimit = divs[i] - (divs[i] - divs[i+1]) / 2;
    if (thisreading >= lowerlimit && thisreading < upperlimit){
      out = i-1;
    }
  }
  return out;   
}

int readbtn(int btn){
  if (digitalRead(btn) && !(lastbtnpressed == btn && lastpressedtime > (millis()-keybouncetime))){
    lastbtnpressed = btn;
    lastpressedtime = millis();
    return true;
    
  }
  else {
    return false;
  }
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
  if (newmode != mode){
    for (k=0; k<9; k++){
      poofstate[k] = mode == 3 ? HIGH : LOW;
      poofcount[k] = 0;
      if (newmode != 1){
        digitalWrite(opoofled[k],LOW);
      }
    }
    switch(newmode){
      case 0:
        digitalWrite(omusicled, LOW);        
        digitalWrite(orandomled, LOW);
      break;   
      case 1:
        digitalWrite(omusicled, HIGH);        
        digitalWrite(orandomled, LOW);
        domusicleds();
        currstep=0;
        j=10000;
        nextstep=0;
        currstep=0;
      break;    
      case 2:
        digitalWrite(omusicled, LOW);        
        digitalWrite(orandomled, HIGH);
      break;
      case 3:
        digitalWrite(omusicled, LOW);        
        digitalWrite(orandomled, LOW);
      break;
    }
    mode = newmode;
  }
}

void domusicleds(){
  if (setstep > numsteps){
    for (k=0; k<9; k++){
      digitalWrite(opoofled[k], LOW);
    }
    digitalWrite(osetstepled, HIGH);
  }
  else {
    for (k=0; k<9; k++){
      digitalWrite(opoofled[k], musicstate[setstep][k]);
    }
    digitalWrite(osetstepled, LOW);
  }
}  
    
