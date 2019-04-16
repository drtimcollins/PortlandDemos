PShape s;
int L = 1000;
int N = 8;
int mode = 0;

void setup() {
  fullScreen(2);
//  size(1024, 768);
  s = createShape();
  s.beginShape();
  s.stroke(0, 0, 180);
  s.strokeWeight(2);
  s.noFill();
  for (int n = 0; n < L; n++) {
    float kd = 2.0*(float)n*PI/(L-1)-PI;
    s.vertex(kd*width/8.0, -height*.2*sin(N*kd)/N/sin(kd));
  }
  s.endShape();
  textSize(18);
}

void draw() {
  float shift = 4.0*PI/N*(mouseX-width/2.0)/width;
  float wt = 1.5*mouseY/(float)(height);
  background(255);
  pushMatrix();
  translate(width/2, height/4);
  line(-width*.4,0,width*.4,0);
  line(0,-height*.22,0,height*.2);
  shape(s, 0, 0);

  if (mode > 0) {
    PShape [] x = new PShape[2];
    for(int m = 0; m < min(mode,2); m++){
    x[m] = createShape();
    x[m].beginShape();
    x[m].stroke(180, 0, 0);
    x[m].strokeWeight(2);
    x[m].noFill();
    for (int n = 0; n < L; n++) {
      float kd = 2.0*(float)n*PI/(L-1)-PI - shift*(m==0?1:-1);
      x[m].vertex((kd + shift *(m==0?1:-1))*width/8.0, -wt*height*.2*sin(N*kd)/N/sin(kd));
    }
    x[m].endShape();
    shape(x[m], 0, 0);
    }
    PShape y;
    y = createShape();
    y.beginShape();
    y.stroke(0, 180, 0);
    y.strokeWeight(2);
    y.noFill();
    for (int n = 0; n < L; n++)
      y.vertex(0, 0);
    y.endShape();
    for (int n = 0; n < L; n++)
    {
      PVector p = x[0].getVertex(n).add(s.getVertex(n));
      if(mode > 1)
        p.y += x[1].getVertex(n).y;
      p.x /= 2;
      if(mode == 3) p.y = -30.0*log(abs(p.y));
      y.setVertex(n, p);
    }
    translate(0, width*.3);
  line(-width*.4,0,width*.4,0);
  line(0,-height*.22,0,height*.2);
    shape(y, 0, 0);
  }
  popMatrix();
  fill(0);
  text("N = 8", 30, height-30);
  if(mode > 0){
    text("Kd shift = " + nf(shift/PI*8) + " x π/8", 30, 30);
    text("Amplitude = " + nf(wt), 30, 60);
  }
  noFill();
}

void mouseClicked(){
  mode++;
  if(mode > 3) mode = 0;
}
