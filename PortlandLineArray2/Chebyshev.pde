import org.apache.commons.math3.linear.*;

double[] b2a(double[] b, int N){
  int L = (N+1)/2;
  
  double[][] Adat = new double[L][L];
  Adat[0][0] = 1;
  for(int n = 1; n < L; n++){
    if(N%2 == 0)
      Adat[0][n] = 3.0*Adat[0][n-1]+Adat[1][n-1];
    else
      Adat[0][n] = 2.0*(Adat[0][n-1]+Adat[1][n-1]);
    for(int m = 1; m < n; m++){
      Adat[m][n] = Adat[m-1][n-1] + 2.0*Adat[m][n-1] + Adat[m+1][n-1];
    }
    Adat[n][n] = 1;
  }
  RealMatrix A = new Array2DRowRealMatrix(Adat);
  RealMatrix B = new Array2DRowRealMatrix(b);
  //println("A");println(A);
  double div = (N%2==0) ? 2 : 1;
  for(int n = 0; n < L; n++){
    B.setEntry(n,0,b[n]/div);
    div = div*4;
  }
  
  RealMatrix y = A.multiply(B).transpose();
  double[][] ret = y.getData();
  return ret[0];
}

class ChebPoly{
  int N;
  class CoeffStruct{ int [] Tn; int[] Tn1; }
  double[] a;
  
  ChebPoly(int order){
    N = order;
    CoeffStruct c = calculateCoefficients(N);
    a = new double[N+1];
    for(int n = 0; n < order+1; n++)
      a[n] = (double)c.Tn[n];
  }
  
  float eval(float x){
    float y = (float)a[0];
    float xx = x;
    for(int n = 1; n < N+1; n++){
      y += a[n]*xx;
      xx *= x;
    }
    return y;
  }
  double eval(double x){
    double y = a[0];
    double xx = x;
    for(int n = 1; n < N+1; n++){
      y += a[n]*xx;
      xx *= x;
    }
    return y;
  } 
  CoeffStruct calculateCoefficients(int order){
    CoeffStruct c = new CoeffStruct();
    if(order == 1){
      c.Tn = new int[2];
      c.Tn1 = new int[1];
      c.Tn[1] = 1; c.Tn1[0] = 1;
    } else {
      CoeffStruct c1 = calculateCoefficients(order-1);
      c.Tn = new int[order+1];
      c.Tn1 = new int[order];
      arrayCopy(c1.Tn, c.Tn1);
      for(int n = 0; n < order; n++)
        c.Tn[n+1] = 2*c1.Tn[n];
      for(int n = 0; n < order-1; n++)
        c.Tn[n] -= c1.Tn1[n];
    }
    return c;
  }
}

/***************************************************************************
 calculate a chebyshev window of size N, store coeffs in out as in Antoniou
-out should be array of size N 
-atten is the required sidelobe attenuation (e.g. if you want -60dB atten, use '60')
***************************************************************************/
float[] cheby_win(int N, float atten){
    int L = (N+1)/2;
    float[] out = new float[L];
    int nn, i;
    float M, sum = 0, max=0;
    double tg = pow(10,atten/20);  /* 1/r term [2], 10^gamma [2] */
    double x0 = Math.cosh((1.0/(N-1))*acosh(tg));
    ChebPoly cp = new ChebPoly(N-1);
    
    double[] b_ = new double[L];
    for(int n = 0; n < b_.length; n++){
      i = 2*n + 1 - (N%2);
      b_[n] = cp.a[i] * Math.pow(x0, i);
    }    
    double[] a2 = b2a(b_,N);
    for(int n = 0; n < a2.length; n++)
       out[n] = (float)a2[n];
    for(nn=0; nn<L; nn++) sum += out[nn];
    if(N%2==1) sum -= out[0]/2;
    for(nn=0; nn<L; nn++) out[nn] /= sum*2;       
    return out;      
}
float[] cheby_win0(int N, float atten){
    float[] out = new float[N];
    int nn, i;
    float M, n, sum = 0, max=0;
    float tg = pow(10,atten/20);  /* 1/r term [2], 10^gamma [2] */
    float x0 = (float)Math.cosh((1.0/(N-1))*acosh(tg));
    ChebPoly cp = new ChebPoly(N-1);
    M = (N-1)/2;
    if(N%2==0) M = M + 0.5; /* handle even length windows */
    for(nn=0; nn<(N/2+1); nn++){
        n = nn-M;
        sum = 0;
        for(i=1; i<=M; i++){
            sum += cp.eval(x0*cos(PI*i/(float)N))*cos((float)(2.0*n*PI*i/(float)N));
        }
        out[nn] = tg + 2*sum;
        out[N-nn-1] = out[nn];
        if(out[nn]>max)max=out[nn];
    }
//    for(nn=0; nn<N; nn++) out[nn] /= max; /* normalise everything */
//    return out;
    sum = 0;
    for(nn=0; nn<N; nn++) sum += out[nn];
    for(nn=0; nn<N; nn++) out[nn] /= sum;
    float[] halfOut = new float[(N+1)/2];
    for(nn = 0; nn < halfOut.length; nn++)
      halfOut[halfOut.length-1-nn] = out[nn];
    return halfOut;
}

double acosh(double x)
{
  return Math.log(x + Math.sqrt(x*x - 1.0));
}
