char[] sup = new char[10];
char[] sub = new char[10];
float []xPhi = new float[8];
float []xCompPhi = new float[8];
float []xMag = new float[8];
boolean isExp = true;
int r = 0;
float rDraw = 0;
int f = 2;
float fDraw = f;
float aLen = 55;

void setup(){
  fullScreen(2);
//  size(1024,768);
//  size(1200,768); // 1024 by 768
//  for(int n = 0; n < 8; n++){
//    xPhi[n] = (float)(n*3*45)*PI/180.0;
//  }
  for(int n = 0; n < 10; n++){
    sup[n] = char(0x2070 + n);
    sub[n] = char(0x2080 + n);
  }
  sup[1] = '¹';sup[2] = '²';sup[3] = '³';
  fill(0);
  textSize(18);
}

void draw(){
  scale(0.9);
  background(255);
  rDraw = rDraw + ((float)r - rDraw)*0.1;
  fDraw = fDraw + ((float)f - fDraw)*0.1;
  textAlign(LEFT);
  text("x(k) = exp("+f+".j2πk/8)",60,30);
  text("r = "+r,60, 250);
  textAlign(CENTER);
  PVector sum = new PVector(0,0);
  for(int n = 0; n < 8; n++){
    float phi = (float)(n*45)*fDraw*PI/180.0;
    if(isExp){
      xPhi[n] = phi;
      xMag[n] = 1;
    } else {
      xPhi[n] = (cos(phi)>0) ? 0 : PI;
      xMag[n] = abs(cos(phi));
      xCompPhi[n] = phi;
    }
    float x = 80+140*n; //<>//
    text("x"+sub[n],x,70);
    text("x"+sub[n]+"W"+supNum(n*r),x,280);
    if(!isExp){
      arrow(x, 360,50, xCompPhi[n]-(rDraw*(float)n)*PI/4,color(250,180,180),2);
      arrow(x, 360,50, -xCompPhi[n]-(rDraw*(float)n)*PI/4,color(220,180,130),2);
      arrow(x, 150,50, xCompPhi[n],color(200,150,200),2); 
      arrow(x, 150,50, -xCompPhi[n],color(150,200,200),2); 
    }
    arrow(x, 150,50*xMag[n], xPhi[n],color(0,0,180),3); 
    arrow(x, 360,50*xMag[n], xPhi[n]-(rDraw*(float)n)*PI/4,color(180,0,0),3);
    sum.add(new PVector(xMag[n]*cos(xPhi[n]-(rDraw*(float)n)*PI/4),xMag[n]*sin(xPhi[n]-(rDraw*(float)n)*PI/4)));
  }  
  pushMatrix();
  stroke (0);
  strokeWeight(1);
  translate(width/2,600);
  text("Sum",0,-aLen*2.1);
  line(-aLen*8,0,aLen*8,0);
  line(0,-aLen*2,0,aLen*2);
  arrow(0,0,50*sum.mag(),PVector.angleBetween(sum,new PVector(1,0)), color(200,0,0),4);
  popMatrix();
}

String supNum(int x){
  char[] z = nf(x).toCharArray();
  for(int n = 0; n < z.length; n++){
    z[n] = sup[int(z[n] - '0')];
  }
  return new String(z);
}

void ax(float x0, float y0, float len){
  pushMatrix();
  stroke (0);
  strokeWeight(1);
  translate(x0,y0);
  line(-aLen,0,aLen,0);
  line(0,-aLen,0,aLen);
  popMatrix();
}

void arrow(float x0, float y0, float len, float phi, color col, float w){
  ax(x0,y0,len*1.1);
  pushMatrix();
  stroke(col);
  strokeWeight(w);
  translate(x0,y0);
  rotate(-phi);
  line(0,0,len,0);
  if(len > aLen*.1){
  line(len-aLen*.1,aLen*.07,len,0);
  line(len-aLen*.1,-aLen*.07,len,0);
  }
  popMatrix();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      f++;
    } else if (keyCode == DOWN) {
      f--;
    }
  } else if (key >= '0' && key <= '8') {
    r = int(key - '0');
  } else if (key == 'c') {
    isExp = false;
  } else if (key == 'e') {
    isExp = true;
  }
}
