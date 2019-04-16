import grafica.*;
import org.apache.commons.math3.complex.*;
import org.apache.commons.math3.transform.*;

int fsize;
GPlotX [] p = new GPlotX[4];
int N = 1024;
GPoint[] pts = new GPoint[N];
float[] noise = new float[N];
Filters f = new Filters();
Complex[] y = new Complex[N];
int NLEV = 1;
boolean isMultiple = false;

void setup(){
  //size(1024, 800);
  fullScreen(2);
  fsize = (width + 1700)/300; 
  fsize *= 2;
  frameRate(10);
  
  for(int n = 0; n < 2; n++){
    p[n] = new GPlotX(this,0,n*height/2,width/2,height/2,14);
    p[n+2] = new GPlotX(this,width/2,n*height/2,width/2,height/2,14);
  }
  p[0].setTitleText("SIGNAL & NOISE");
  p[1].setTitleText("UNFILTERED");
  p[2].setTitleText("INVERSE FILTER");
  p[3].setTitleText("MATCHED FILTER");
  p[0].addLayer("n",new GPointsArray(pts));
  p[0].getLayer("n").setLineColor(color(180, 0, 0));
  p[0].getLayer("n").setLineWidth(2);
//  update();
}

void update(){
  background(255);
  for(int n = 0; n < N; n++){
    noise[n] = randomGaussian() * 0.02 * (float)NLEV;
  }
  
  for(int n = 0; n < N; n++)
    pts[n] = new GPoint((float)(n-N/2)/128.0, (float)f.s[n].getReal() + (isMultiple?(float)f.s[(N+n-64)%N].getReal()/2:0));
  p[0].setPoints(new GPointsArray(pts));
  for(int n = 0; n < N; n++)
    pts[n] = new GPoint((float)(n-N/2)/128.0, noise[n]);
  p[0].setPoints(new GPointsArray(pts),"n");

  for(int n = 0; n < N; n++)
    pts[n] = new GPoint((float)(n-N/2)/128.0, (float)f.s[n].getReal() + noise[n] + (isMultiple?(float)f.s[(N+n-64)%N].getReal()/2:0));
  p[1].setPoints(new GPointsArray(pts));
 
  for(int n = 0; n < N; n++)
    y[n] = new Complex(f.s[n].getReal() + noise[n] + (isMultiple?(float)f.s[(N+n-64)%N].getReal()/2:0), 0);
  Complex[] Y = f.MakeY(y);
  Complex[] r = f.matchedFilterF(Y);  
  for(int n = 0; n < N; n++)
    pts[n] = new GPoint((float)(n-N/2)/128.0, (float)r[n + N/2].getReal()/128.0);
  p[3].setPoints(new GPointsArray(pts));

  r = f.inverseFilterF(Y);
  for(int n = 0; n < N; n++)
    pts[n] = new GPoint((float)(n-N/2)/128.0, (float)r[n + N/2].getReal()/1.0);
  p[2].setPoints(new GPointsArray(pts));

  
  
  for(int n = 0; n < 4; n++)
    p[n].defaultDraw();  
}

void keyPressed() {
  if (key == CODED) {
   //println(keyCode);
    if (keyCode == UP) {
      NLEV++;
    } else if (keyCode == DOWN) {
      if (NLEV > 0) NLEV--;
    }
  } else if(key == 'm' || key == 'M'){
   isMultiple = !isMultiple;    //<>//
  }
}

void draw(){
  update();  
}
