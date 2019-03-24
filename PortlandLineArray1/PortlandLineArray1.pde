import grafica.*;

// Plot sin(NKd)/Nsin(Kd)
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing
int N = 2;
GPlot chart;
float pi = (float)Math.PI;
boolean showZeros = false;
//PImage eq;
PShape eqq;
void setup() {
  size(1000, 500);
//  fullScreen();
//  eq = loadImage("LineArrayEquation.png");
  eqq = loadShape("lineArrayEquationA.svg");
  int fsize = (width + 1700)/300; 
  fsize *= 2;
  println(fsize);
  textSize(fsize);
  //chart = new GPlot(this, 0, 0, width, height);
  chart = new GPlot(this, width/20, height/20, width*.9, height*.9);
  chart.getXAxis().setAxisLabelText("Kd");
  chart.getYAxis().setAxisLabelText("D(Kd)");
  chart.getXAxis().setAllFontProperties("Arial", 0, fsize);
  chart.getYAxis().setAllFontProperties("Arial", 0, fsize);
  chart.getXAxis().setOffset(0);
  chart.getYAxis().setOffset(0);
  chart.setPointSize(0);
  chart.setLineColor(color(0, 0, 180));
  chart.setLineWidth(2);
  chart.setGridLineColor(color(200, 200, 255));
  chart.setGridLineWidth(1);
  chart.setXLim(-pi, pi);
  chart.setYLim(-1.0, 1.0);
  chart.setVerticalAxesTicksSeparation(.25);  
  update();
}

void update() {
  int L = 1000;
  GPoint[] pts = new GPoint[2*L+1];
  float x, y;
  for (int n = 0; n < pts.length; n++) {
    x = (float)(n - L - 1) * pi / (float)L;
    if (abs(sin(x)) < 1e-6)
      y = (abs(x) > 2 && N%2 == 0) ? -1.0 : 1.0;
    else
      y = sin(N*x)/N/sin(x);
    pts[n] = new GPoint(x, y);
  }
  chart.setPoints(new GPointsArray(pts));

  float[] p1xtick = new float[2*N+1];
  String[] plxlab = new String[2*N+1];
  for (int n = 0; n < 2*N+1; n++) {
    p1xtick[n] = (float)(n-N)*pi/(float)N;
    if ((N > 9 && (n-N)%2 != 0) || (N > 16 && (n-N)%4 != 0))
      plxlab[n] = "";
    else
      plxlab[n] = formatFraction(n-N, N);
  }
  chart.setHorizontalAxesTicks(p1xtick);
  chart.getXAxis().setTickLabels(plxlab);

  fill(255);
  noStroke();
  background(255);
  //    rect(pos.x,pos.y,size.x,size.y);
  chart.beginDraw();
  chart.drawBox();
  chart.drawGridLines(GPlot.BOTH);
  chart.drawXAxis();
  chart.drawYAxis();
  chart.drawLines();
  chart.endDraw(); 
  if (showZeros) {
    stroke(255, 0, 0);
    fill(255, 255, 0);
    strokeWeight(2);
    for (int n = 0; n < N-1; n++) {
      float[] p = chart.getScreenPosAtValue(pi*(float)(n+1)/(float)N, 0);
      circle(p[0], p[1], 10);
    }
  }
  fill(0);
  float[] p = chart.getScreenPosAtValue(-1.9, .825);
  text("N = "+N, p[0], p[1]);
  p = chart.getScreenPosAtValue(1.5, .825);
  //image(eq,p[0],p[1],387/2,50);
  pushMatrix();
  translate(p[0],p[1]);
  scale(width/700.0);
  shape(eqq);
  popMatrix();
}
String formatFraction(int num, int den) {
  if (num == 0) return "0";
  if (abs(num) == den) return (num < 0) ? "-π" : "π"; 
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
    }
  } else if (key == 'z' || key == 'Z') {
    showZeros = !showZeros;
    update();
  }
}

void draw() {
}
