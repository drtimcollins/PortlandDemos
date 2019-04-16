import controlP5.*;
import grafica.*;

// Plot sin(NKd)/Nsin(Kd)
// N = num elelemnts, K = ksin(theta), k = 2pi/lambda, 2d=el spacing

ControlP5 cp5;
void setup(){
  size(400, 400);
  noStroke();
  
  cp5 = new ControlP5(this);
//  cp5.addRadioButton("Sel");
  RadioButton rb = new RadioButton(cp5,"Sel");
//  RadioButton rb = ((RadioButton)cp5.getController("Sel"));
  rb.addItem("Option 1",0);
  rb.addItem("Option 2",1);
  cp5.addTextfield("textA", 100, 290, 100, 20);
//  cp5.addNumberbox("numberboxC", 0, 100, 220, 100, 14).setId(3);
  cp5.addSlider("sliderA", 50, 200, 50, 100, 260, 100, 14);  
  // change individual settings for a controller
//  cp5.getController("numberboxC").setMax(255);
//  cp5.getController("numberboxC").setMin(0);  
  Slider sa = ((Slider)cp5.getController("sliderA"));
  sa.setLabel("Wavelength");
}

//public void numberboxC(int theValue) {
//  println("### got an event from numberboxC : "+theValue);
//}

// an event from slider sliderA will change the value of textfield textA here
public void sliderA(int theValue) {
  Textfield txt = ((Textfield)cp5.getController("textA"));
  txt.setValue(""+theValue);
}

void draw(){
}
