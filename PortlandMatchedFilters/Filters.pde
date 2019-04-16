import org.apache.commons.math3.complex.*;
import org.apache.commons.math3.transform.*;

class Filters {
  Complex[] s = new Complex[N];
  Complex[] S, Sinv;
  
  int L = 2*N;
  FastFourierTransformer fft = new FastFourierTransformer(DftNormalization.STANDARD);
  
  Filters() {
    for(int n = 0; n < N; n++)
      s[n] = new Complex(0,0);
    for(int n = 0; n < 128; n++)
      s[448+n] = new Complex(1,0);
    MakeS();
  }

  void MakeS() {
    Complex[] s_padded = new Complex[L];
    for (int n = 0; n < N; n++)
    {
      s_padded[n] = new Complex(0, 0);
      s_padded[n + N] = s[n];
    }
    S = fft.transform(s_padded, TransformType.FORWARD);    
    for (int n = 0; n < L; n++)
      S[n] = S[n].conjugate();
      
    Complex[] s_inv = new Complex[L];
    for (int n = 0; n < L; n++)
      s_inv[n] = new Complex(0, 0);
    float[] coeffs = {0.03, 0.14, 0.3, 0.5};
    for(int n = 0; n < 4; n++){
      int i = N + 64 + n*128;
      s_inv[i] = new Complex(-coeffs[n],0);
      s_inv[i+1] = new Complex(coeffs[n],0);
      s_inv[512+i] = new Complex(coeffs[3-n],0);
      s_inv[513+i] = new Complex(-coeffs[3-n],0);
    }
    Sinv = fft.transform(s_inv, TransformType.FORWARD);    
    for (int n = 0; n < L; n++)
      Sinv[n] = Sinv[n].conjugate();    
  }
  
  Complex[] MakeY(Complex[] y){
    Complex[] y_padded = new Complex[L];
    for (int n = 0; n < L; n++)
      if (n < y.length)
        y_padded[n] = y[n];
      else
        y_padded[n] = new Complex(0, 0);
    Complex[] Y = fft.transform(y_padded, TransformType.FORWARD);    
    return Y;
  }
  
  Complex[] matchedFilter(Complex[] y){
    Complex[] Y = MakeY(y);
    return matchedFilterF(Y);
   }
  
  Complex[] matchedFilterF(Complex[] Y0){
    Complex[] Y = new Complex[Y0.length];
    arrayCopy(Y0, Y);
   for (int n = 0; n < L; n++)
      Y[n] = Y[n].multiply(S[n]);  
    Complex[] r = fft.transform(Y, TransformType.INVERSE);
    return r;
  }
  Complex[] inverseFilterF(Complex[] Y0){
    Complex[] Y = new Complex[Y0.length];
    arrayCopy(Y0, Y);
   for (int n = 0; n < L; n++)
      Y[n] = Y[n].multiply(Sinv[n]);  
    Complex[] r = fft.transform(Y, TransformType.INVERSE);
    return r;
  }
}
