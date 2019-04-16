import grafica.*;

// Plot sin(NKd)/Nsin(Kd)
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing
int N = 2;
float[] a = {.5};
int dL = 4;  // dL = d/lambda * 20;
GPlotX[] chart = new GPlotX[2];
int thetaS = 0;
float pi = (float)Math.PI;
PVector polarPos;
float polarSize;
int fsize;
color arcCol = #FFD8D8;
boolean showBW = false;
enum Taper{NONE, BIN, CHEB20, CHEB30, CHEB40, TAYLOR20, TAYLOR30, TAYLOR40, HAMM};
Taper taper = Taper.NONE;
JSONArray cheb20data, cheb30data, cheb40data;
JSONArray taylor20data, taylor30data, taylor40data;
void setup() {
//  size(1024, 768);
  fullScreen(2);
  fsize = (width + 1700)/300; 
  fsize *= 2;
  println(fsize);
  //chart[0] = new GPlotX(this, 0, 0, width*2/3, height/2,fsize);
  //chart[1] = new GPlotX(this, 0, height/2, width*2/3, height/2,fsize);
  //polarPos = new PVector(width*5/6, height/4);
  //polarSize = width/7;
  chart[0] = new GPlotX(this, 0, 0, width-height*2/4.5, height/2,fsize);
  chart[1] = new GPlotX(this, 0, height/2, width-height*2/4.5, height/2,fsize);
  polarPos = new PVector(width-height/4.5, height/5);
  polarSize = height/5.5;
  
  chart[0].getXAxis().setAxisLabelText("Kd");
  chart[0].getYAxis().setAxisLabelText("D(Kd)");
  chart[0].setXLim(-2*pi, 2*pi);
  chart[1].getXAxis().setAxisLabelText("θ");
  chart[1].getYAxis().setAxisLabelText("D(θ)");
  chart[1].setXLim(-pi/2,pi/2);
  update();
  
  JSONObject json = loadJSONObject("chebwin.json");
  cheb20data = json.getJSONArray("cheb20");
  cheb30data = json.getJSONArray("cheb30");
  cheb40data = json.getJSONArray("cheb40");

  JSONObject json2 = loadJSONObject("taylorwin.json");
  taylor20data = json2.getJSONArray("taylor20");
  taylor30data = json2.getJSONArray("taylor30");
  taylor40data = json2.getJSONArray("taylor40");
}

float[] chebwin(JSONArray set, int i){
    JSONArray win = set.getJSONArray(i-1);
    float[] x = new float[win.size()];
    for(int n = 0; n < win.size(); n++)
      x[n] = win.getFloat(n);
    return x;
}


void update() {
  textSize(fsize);
  strokeWeight(1);

  a = new float[(N+1)/2];
  for(int n = 0; n < (N+1)/2; n++) a[n] = 1/(float)N;
  
  if(N > 1 && taper == Taper.BIN)
  {
    double[] b_ = new double[(N+1)/2];
    b_[b_.length-1] = 1; //(N%2==0 && N>2) ? 0.5 :1;
    double[] a2 = b2a(b_,N);
    for(int n = 0; n < a2.length; n++){
      a[n] = (float)a2[n];
    }
  }
  if(N > 1 && taper == Taper.CHEB20)
    a = chebwin(cheb20data,N);
//    a = cheby_win(N,20);
  if(N > 1 && taper == Taper.CHEB30)
    a = chebwin(cheb30data,N);
//    a = cheby_win(N,30);
  if(N > 1 && taper == Taper.CHEB40)
    a = chebwin(cheb40data,N);
//    a = cheby_win(N,40);
  if(N > 1 && taper == Taper.TAYLOR20)
    a = chebwin(taylor20data,N);
  if(N > 1 && taper == Taper.TAYLOR30)
    a = chebwin(taylor30data,N);
  if(N > 1 && taper == Taper.TAYLOR40)
    a = chebwin(taylor40data,N);
  if(taper == Taper.HAMM) {
    float sum = 0;
    for(int n = 0; n < a.length; n++){
      a[n] = 0.54 + 0.46*cos(2*(n+(N%2==0?1:0))*pi/(float)N);
      sum+= a[n];
    }
    if(N%2!=0) sum -= a[0]/2;
    for(int n = 0; n < a.length; n++)
      a[n] /= sum*2;
  }
  
  GPoint[] pts = new GPoint[1001];
  float x;
  for (int n = 0; n < pts.length; n++) {
    x = (float)(n - 500) * pi / 250.0;
    pts[n] = new GPoint(x, Du(x - 2*pi*sin(radians(thetaS))*(float)dL/20.0));
  }
  chart[0].setPoints(new GPointsArray(pts));

  GPoint[] pts1 = new GPoint[1001];
  float x0;
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing
// dL = d/lambda * 20;
  for (int n = 0; n < pts1.length; n++) {
    x0 = (float)(n - 500) * pi / 1000.0;
    x = 2*pi*sin(x0)*(float)dL/20.0;    
    pts1[n] = new GPoint(x0, Du(x - 2*pi*sin(radians(thetaS))*(float)dL/20.0));
  }  
  chart[1].setPoints(new GPointsArray(pts1));

  // Find beamwidth
  int i0 = (int)(1000.0*asin(sin((float)thetaS*pi/180.0))/pi)+500;
  //println(i0);
  while(i0 < 0) i0 += 1000;
  while(i0 > 1000) i0 -= 1000;
  int[] bw = {i0,i0};
  float[] bwf = {0,0};
  while(bw[0] > 0 && pts1[bw[0]].getY() > 0.707) bw[0]--;
  while(bw[1] < 1001 && pts1[bw[1]].getY() > 0.707) bw[1]++;
//  bw[0] -= 10; bw[1] += 10;
  for(int n = 0; n < 2; n++)
    bwf[n] = (float)(bw[n] - 500) * pi / 1000.0 - pi/2;

  float[] p1xtick;
  String[] plxlab;
  if(N > 10){
    p1xtick = new float[5];
    plxlab = new String[5];
    for(int n = 0; n < 5; n++){
      p1xtick[n] = (float)(n-2)*pi;
      plxlab[n] = formatFraction(n-2,1);
    }
  } else {
    p1xtick = new float[4*N+1];
    plxlab = new String[4*N+1];
    for (int n = 0; n < 4*N+1; n++) {
      p1xtick[n] = (float)(n-2*N)*pi/(float)N;
      if ((N > 3 && (n-2*N)%2 != 0) || (N > 6 && (n-2*N)%4 != 0))
        plxlab[n] = "";
      else
        plxlab[n] = formatFraction(n-2*N, N);
    }
  }
  chart[0].setHorizontalAxesTicks(p1xtick);
  chart[0].getXAxis().setTickLabels(plxlab);

  float[] plxtick1 = {-0.5*pi, -0.25*pi, 0, 0.25*pi, 0.5*pi};
  String[] plxlab1 = {"-90°","-45°","0°","45°","90°"};
  chart[1].setHorizontalAxesTicks(plxtick1);
  chart[1].getXAxis().setTickLabels(plxlab1);

  fill(255);
  noStroke();
  background(255);
  //    rect(pos.x,pos.y,size.x,size.y);
  for(int n = 0; n < 2; n++){
    //chart[n].beginDraw();
    //chart[n].drawBox();
    //chart[n].drawGridLines(GPlot.BOTH);
    //chart[n].drawXAxis();
    //chart[n].drawYAxis();
    //chart[n].drawLines();
    //chart[n].endDraw();
    chart[n].defaultDraw();
  }
  stroke(255,100,100,100);
  for(int n = -9; n <= 9; n++){
  // Kd = 2.pi.sin(theta).dL
    float theta = pi*(float)n/18.0;
    float Kd = 0.1*pi*sin(theta)*(float)dL;
    float[] p0 = chart[0].getScreenPosAtValue(Kd, -1);
    float[] p1 = chart[1].getScreenPosAtValue(theta, 1);
    line(p0[0],p0[1],p1[0],p1[1]);  
  }

  pushMatrix();
  translate(polarPos.x, polarPos.y);
  if(showBW){
  fill(arcCol); noStroke();
  arc(0,0, polarSize*2, polarSize*2,bwf[0],bwf[1]);
  arc(0,0, polarSize*2, polarSize*2,-bwf[1],-bwf[0]);
  }
  noFill();stroke(150);
  ellipse(0,0, polarSize*2, polarSize*2);
  ellipse(0,0, polarSize, polarSize);
  line(polarSize, 0, -polarSize, 0);
  line(0, polarSize, 0, -polarSize);
  stroke(150,150,255);
  ellipse(0,0, polarSize*sqrt(2), polarSize*sqrt(2));
  PShape s;
  s = createShape();
  s.beginShape();
//  s.fill(0, 0, 255);
  s.stroke(0,0,180);
  s.strokeWeight(1.5);
  s.noFill();
  for(int n = 0; n < pts1.length; n++) {
    float r = polarSize * abs(pts1[n].getY());
    s.vertex(r*sin(pts1[n].getX()), r*cos(pts1[n].getX()));
  }
  for(int n = pts1.length-2; n > 0; n--) {
    float r = polarSize * abs(pts1[n].getY());
    s.vertex(r*sin(pts1[n].getX()), -r*cos(pts1[n].getX()));
  }
  s.endShape(CLOSE);
  shape(s, 0, 0);
  fill(0);
  textAlign(CENTER,TOP);
  text("Linear plot", 0, polarSize);
  textSize(fsize*.75);
  textAlign(LEFT,TOP);
  text("1",polarSize,0);
  text("0.5",polarSize/2,0);
  textAlign(RIGHT,TOP);
  text("1",-polarSize,0);
  text("0.5",-polarSize/2,0);
  textSize(fsize);
  popMatrix();

  pushMatrix();
  translate(polarPos.x, 3*polarPos.y);
  if(showBW){
  fill(arcCol); noStroke();
  arc(0,0, polarSize*2, polarSize*2,bwf[0],bwf[1]);
  arc(0,0, polarSize*2, polarSize*2,-bwf[1],-bwf[0]);
  }
  stroke(150);noFill();
  ellipse(0,0, polarSize*2, polarSize*2);
  ellipse(0,0, polarSize, polarSize);
  line(polarSize, 0, -polarSize, 0);
  line(0, polarSize, 0, -polarSize);
  stroke(150,150,255);
  ellipse(0,0, polarSize*1.85, polarSize*1.85);
  s = createShape();
  s.beginShape();
//  s.fill(0, 0, 255);
  s.stroke(0,0,180);
  s.strokeWeight(1.5);
  s.noFill();
  for(int n = 0; n < pts1.length; n++) {
    float r = polarSize * (log10(abs(pts1[n].getY())+1e-9)/2 + 1); // 0-40dB
    if(r < 0) r = 0;
    s.vertex(r*sin(pts1[n].getX()), r*cos(pts1[n].getX()));
  }
  for(int n = pts1.length-2; n > 0; n--) {
    float r = polarSize * (log10(abs(pts1[n].getY())+1e-9)/2 + 1); // 0-40dB
    if(r < 0) r = 0;
    s.vertex(r*sin(pts1[n].getX()), -r*cos(pts1[n].getX()));
  }
  s.endShape(CLOSE);
  shape(s, 0, 0);
  fill(0); //<>//
  textAlign(CENTER,TOP);
  text("Log plot [dB]", 0, polarSize);
  textSize(fsize*.75);
  textAlign(LEFT,TOP);
  text("0",polarSize,0);
  text("-20",polarSize/2,0);
  textAlign(RIGHT,TOP);
  text("0",-polarSize,0);
  text("-20",-polarSize/2,0);
  textSize(fsize);
  popMatrix();

  pushMatrix();
  float sp = polarSize*2.0/float(N-1);
  translate(polarPos.x, 4*polarPos.y+polarSize*.8);
  stroke(255,0,0);
  strokeWeight(5);
  for(int n = 0; n < a.length; n++){
    float xx = (float)n*sp + (N%2==0 ? sp/2 : 0);
    line(xx,0,xx,-polarSize*0.6*a[n]/a[0]);
    line(-xx,0,-xx,-polarSize*0.6*a[n]/a[0]);
  }
  popMatrix();
  
  textAlign(LEFT,BOTTOM);
  fill(0);
  float[] p = chart[0].getScreenPosAtValue(-3*pi/2, .825);
  text("N = "+N, p[0], p[1]);
  if(thetaS != 0) text("θs = "+thetaS+"°", p[0], p[1]+20);
  float[] q = chart[1].getScreenPosAtValue(-1.9, .825);
  text("d = "+(float)dL/20.0+"λ", p[0], q[1]);  
}

float Du(float x){
  //if (abs(sin(x)) < 1e-6)
  //  return cos(N*x)*cos(x);
  //else
  //  return sin(N*x)/N/sin(x);  
  float y = 0;
  if(N%2 == 0){  // even
    for(int n = 0; n < N/2; n++)
      y += 2*a[n]*cos(x*(2.0*(float)n + 1.0));    
  } else {
    y = a[0];
    for(int n = 1; n < (N+1)/2; n++)
      y += 2*a[n]*cos(2.0*x*(float)n);
  }
  return y;
}
float log10 (float x) {
  return (log(x) / log(10));
}
String formatFraction(int num, int den) {
  if (num == 0) return "0";
  if (abs(num) == den) return (num < 0) ? "-π" : "π"; 
  if (abs(num) == 2*den) return (num < 0) ? "-2π" : "2π";   
  for (int dn = 2; dn <= abs(num); dn++) {
    while (num % dn == 0 && den % dn == 0) {
      num /= dn;
      den /= dn;
    }
  }
  if (abs(num) == 1) return (num < 0) ? "-π/"+den : "π/"+den;   
  return num+"π/"+den;
}

void keyPressed() {
  if (key == CODED) {
    switch(keyCode){
    case UP:
      if (N < 100) N++;
      update(); break;
    case DOWN:
      if (N > 1) N--;
      update(); break;
    case RIGHT:
      dL++;
      update(); break;
    case LEFT:
      if(dL > 1) dL--;
      update(); break;
    case 33:
      thetaS+=5;
      update(); break;
    case 34:
      thetaS-=5;
      update(); break;
    }
  } else
    switch(key){
      case 'b':
      case 'B':
        showBW = !showBW;
        update(); break;
      case '0':
        taper = Taper.NONE;
        update(); break;
      case '1':
        taper = Taper.BIN;
        update(); break;      
      case '2':
        taper = Taper.CHEB20;
        update(); break;      
      case '3':
        taper = Taper.CHEB30;
        update(); break;      
      case '4':
        taper = Taper.CHEB40;
        update(); break;     
      case '"':
        taper = Taper.TAYLOR20;
        update(); break;     
      case '£':
        taper = Taper.TAYLOR30;
        update(); break;     
      case '$':
        taper = Taper.TAYLOR40;
        update(); break;     
      case 'h':
      case 'H':
        taper = Taper.HAMM;
        update(); break;     
  }
}

void draw() {
}
