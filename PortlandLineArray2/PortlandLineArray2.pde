import grafica.*;

// Plot sin(NKd)/Nsin(Kd)
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing
int N = 2;
int dL = 2;  // dL = d/lambda * 10;
GPlot[] chart = new GPlot[2];
float pi = (float)Math.PI;
PVector polarPos;
float polarSize;
void setup() {
  size(1024, 800);
  //fullScreen();
  int fsize = (width + 1700)/300; 
  fsize *= 2;
  println(fsize);
  textSize(fsize);
  chart[0] = new GPlot(this, 0, 0, width*2/3, height/2);
  chart[1] = new GPlot(this, 0, height/2, width*2/3, height/2);
  polarPos = new PVector(width*5/6, height/2);
  polarSize = width/7;
  
  for(int n = 0; n < 2; n++){
    chart[n].getXAxis().setAllFontProperties("Arial", 0, fsize);
    chart[n].getYAxis().setAllFontProperties("Arial", 0, fsize);
    chart[n].getXAxis().setOffset(0);
    chart[n].getYAxis().setOffset(0);
    chart[n].setPointSize(0);
    chart[n].setLineColor(color(0, 0, 180));
    chart[n].setLineWidth(2);
    chart[n].setGridLineColor(color(200, 200, 255));
    chart[n].setGridLineWidth(1);
    chart[n].setYLim(-1.0, 1.0);
    chart[n].setVerticalAxesTicksSeparation(.25);  
  }
  chart[0].getXAxis().setAxisLabelText("Kd");
  chart[0].getYAxis().setAxisLabelText("D(Kd)");
  chart[0].setXLim(-2*pi, 2*pi);
  chart[1].getXAxis().setAxisLabelText("θ");
  chart[1].getYAxis().setAxisLabelText("D(θ)");
  chart[1].setXLim(-pi/2,pi/2);
  update();
}

void update() {
  GPoint[] pts = new GPoint[1001];
  float x;
  for (int n = 0; n < pts.length; n++) {
    x = (float)(n - 501) * pi / 250.0;
    pts[n] = new GPoint(x, Du(x));
  }
  chart[0].setPoints(new GPointsArray(pts));

  GPoint[] pts1 = new GPoint[1001];
  float x0;
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing
// dL = d/lambda * 10;
  for (int n = 0; n < pts1.length; n++) {
    x0 = (float)(n - 501) * pi / 1000.0;
    x = 2*pi*sin(x0)*(float)dL/10.0;    
    pts1[n] = new GPoint(x0, Du(x));
  }  
  chart[1].setPoints(new GPointsArray(pts1));

  float[] p1xtick = new float[4*N+1];
  String[] plxlab = new String[4*N+1];
  for (int n = 0; n < 4*N+1; n++) {
    p1xtick[n] = (float)(n-2*N)*pi/(float)N;
    if ((N > 3 && (n-2*N)%2 != 0) || (N > 6 && (n-2*N)%4 != 0))
      plxlab[n] = "";
    else
      plxlab[n] = formatFraction(n-2*N, N);
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
    chart[n].beginDraw();
    chart[n].drawBox();
    chart[n].drawGridLines(GPlot.BOTH);
    chart[n].drawXAxis();
    chart[n].drawYAxis();
    chart[n].drawLines();
    chart[n].endDraw(); 
  }
  stroke(255,100,100,100);
  for(int n = -9; n <= 9; n++){
  // Kd = 2.pi.sin(theta).dL
    float theta = pi*(float)n/18.0;
    float Kd = 0.2*pi*sin(theta)*(float)dL;
    float[] p0 = chart[0].getScreenPosAtValue(Kd, -1);
    float[] p1 = chart[1].getScreenPosAtValue(theta, 1);
    line(p0[0],p0[1],p1[0],p1[1]);  
  }
  stroke(150);
  ellipse(polarPos.x, polarPos.y, polarSize*2, polarSize*2);
  ellipse(polarPos.x, polarPos.y, polarSize, polarSize);
  line(polarPos.x+polarSize, polarPos.y, polarPos.x-polarSize, polarPos.y);
  line(polarPos.x, polarPos.y+polarSize, polarPos.x, polarPos.y-polarSize);
  PShape s;
  s = createShape();
  s.beginShape();
//  s.fill(0, 0, 255);
  s.stroke(0,0,255);
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
  shape(s, polarPos.x, polarPos.y);
  
  fill(0);
  float[] p = chart[0].getScreenPosAtValue(-3*pi/2, .825);
  text("N = "+N, p[0], p[1]);
  float[] q = chart[1].getScreenPosAtValue(-1.9, .825);
  text("d = "+(float)dL/10.0+"λ", p[0], q[1]);  
}

float Du(float x){
  if (abs(sin(x)) < 1e-6)
//    return (abs(x) > 2 && N%2 == 0) ? -1.0 : 1.0;
    return cos(N*x)*cos(x);
  else
    return sin(N*x)/N/sin(x);  
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
    if (keyCode == UP) {
      N++;
      update();
    } else if (keyCode == DOWN) {
      if (N > 1) N--;
      update();
    } else if (keyCode == RIGHT) {
      dL++;
      update();
    } else if (keyCode == LEFT) {
      if(dL > 1) dL--;
      update();
    }
  } else if (key == 'z' || key == 'Z') {
    // NOT NEEDED NOW
    update();
  }
}

void draw() {
}
