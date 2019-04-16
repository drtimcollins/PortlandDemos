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
    setXLim(-4.0, 4.0);
    setYLim(-2, 2);
    setVerticalAxesTicksSeparation(1); 
    getTitle().setFontSize(fontSize+2);
  }  
  void defaultDraw(){
    beginDraw();
    drawBox();
    drawGridLines(GPlot.BOTH);
    drawXAxis();
    drawYAxis();
    drawLines();
    drawTitle();
    endDraw();     
  }  
}
