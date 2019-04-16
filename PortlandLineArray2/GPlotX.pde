import grafica.*;

class GPlotX extends GPlot{
  GPlotX(PApplet parent, float x, float y, float w, float h, int fontSize){
    super(parent, x, y, w, h);
    getXAxis().setAllFontProperties("Arial", 0, fontSize);
    getYAxis().setAllFontProperties("Arial", 0, fontSize);
    getXAxis().setOffset(0);
    getYAxis().setOffset(0);
    setPointSize(0);
    setLineColor(color(0, 0, 180));
    setLineWidth(2);
    setGridLineColor(color(200, 200, 255));
    setGridLineWidth(1);
    setYLim(-1.0, 1.0);
    setVerticalAxesTicksSeparation(.25); 
  }  
  void defaultDraw(){
    beginDraw();
    drawBox();
    drawGridLines(GPlot.BOTH);
    drawXAxis();
    drawYAxis();
    drawLines();
    endDraw();     
  }  
}
