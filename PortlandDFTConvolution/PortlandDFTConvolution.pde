int step = 0;
int run = 0;
boolean[] isFlipped = {false, true, true, true,  true,  true,  true,  true,  true,  true};
int[] shifts = {0, 0, 0, 1, 2, 3, 4, 5, 6, 7};
int [] x = {1,2,3,4};
int [] y = {2,0,1,3};
int [] xy = {11,17,19,13};
int [] xyz = {2,4,7,13,9,13,12};
void setup(){
//  size(1024,768);
  fullScreen(2);
  drawStep();
}


void drawStep(){
  boolean yFlipped = isFlipped[step];
  int yshift = shifts[step];
  background(255);
  textAlign(CENTER,CENTER);
  fill(0);
  textSize(36);
  text("x = {1,2,3,4}, y = {2,0,1,3}",width/2,50);
  text("x[n]",100,200);
  if(run == 0 && step == 5)
  text("Matlab equivalent: ifft(fft([1 2 3 4]).*fft([2 0 1 3]))",width/2,740);
  if(step == 8)
  text("ifft(fft([1 2 3 4 0 0 0]).*fft([2 0 1 3 0 0 0]))",width/2,740);  
  if(yFlipped){
    if(yshift == 0)
      text("y[-n]",100,350);    
    else
      text("y["+nf(yshift)+"-n]",100,350);    
  } else {
    text("y[n]",100,350);
  }
  if(step > 1){
    text("prod",100,500);
    text("x*y",100,650);
  }
  for(int n = 0; n < x.length; n++){
    pushMatrix();
    translate(250+n*100,200);
    fill(0);
//    int yval = yFlipped ? y[(yshift-n+3)%4] : y[n];
    int yval = yFlipped ? y[(yshift-n+y.length)%y.length] : y[n];
    text(x[n],0, 0);
    text(yval,0, 150);
    if(step > 1){
      text(x[n]*yval,0,300);
      if(yshift == n) fill(255,0,0); else fill(0);
      if(yshift >= n)
        text(xy[n],0,450);      
      line(0,60,0,90);
      line(0,210,0,240);
      line(0,360,(yshift-n)*100,390);
    }
    noFill();
    for(int m = 0; m < ((step > 1)?4:2); m++)
      rect(-50,-50+150*m,100,100);
    popMatrix();
  }
}

void draw(){}

void mouseClicked(){
  if(run == 0)
    if(step < 5)
      step++;
    else {
      step = 0;
      run = 1;
      x = expand(x, 7);
      y = expand(y, 7);  
      xy = new int[7];
      arrayCopy(xyz,xy);
    } else if(step < 8) step++;
  drawStep();
}
