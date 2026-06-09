// 
// PROCESADOR
// Objeto que se encarga de procesar las imágenes de video capturadas por
// la cámara, analizarlas e interpretarlas para calcular el "Flujo Óptico", 
// es decir, la cantidad de movimiento en cada celda de la imagen.
// Se utiliza la librería "OpenCV" para Processing:
//
//   https://github.com/atduskgreg/opencv-processing
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

import gab.opencv.*;
import java.awt.Rectangle;


/**
 * Procesador
 * Componente responsable de interpretar las imágenes de video capturadas 
 * por la cámara para calcular su "Flujo Óptico" mediante la librería OpenCV.
 */
class Procesador {
  OpenCV opencv;
  Matriz matriz;
  float flujo[][];
  float evaluacion[];

  
  public Procesador(PApplet contenedor, int ancho, int alto, int columnas, int filas) {
    matriz = new Matriz(columnas, filas, ancho, alto);
    opencv = new OpenCV(contenedor, ancho, alto);
  }
  
  public void calcular(PImage imagen, float techo) {
    opencv.loadImage(imagen);
    opencv.calculateOpticalFlow();
    matriz.calcular(opencv);
    flujo = matriz.devolverCasillas(techo);
  }
  
  public void evaluar(PImage imagen, float techo) {
    opencv.loadImage(imagen);
    opencv.calculateOpticalFlow();
    matriz.evaluar(opencv);
    flujo = matriz.devolverCasillas(techo);
    evaluacion = matriz.devolverPosicionIntensidad(techo);
  }
  
  public float[][] flujoOptico() {
    return flujo;
  }
  
  public float[] posicionIntensidad() {
    return evaluacion;
  }
  
  public void mostrar(float x, float y, float techo) {
    push();
    matriz.dibujar(x, y, techo);
    pop();
  }  
}



/**
 * Matriz
 * Objeto auxiliar que define una matriz de filas y columnas para
 * poder realizar los cálculos de "Optical Flow" que provee la
 * librería OpenCV de Processing.
 */
class Matriz {
  int columnas;
  int filas;
  int ancho;
  int alto;
  float moduloH, moduloV;
  PVector m[][];
  float cuanto[][];
  int   maxCoordenada[];
  float maxValorFlujo;

  Matriz(int columnas_, int filas_, int ancho_, int alto_) {
    ancho = ancho_;
    alto = alto_;
    columnas = columnas_;
    filas = filas_;
    moduloH = ancho*1.0/columnas;
    moduloV = alto*1.0/filas;
    m = new PVector[columnas][filas];
    cuanto = new float[columnas][filas];
  }

  void calcular( OpenCV opencv ) {
    for ( int i=0; i<columnas; i++ ) {
      for ( int j=0; j<filas; j++ ) {
        //m[columnas-i-1][j] = opencv.getAverageFlowInRegion(int(i*moduloH), int(j*moduloV), int(moduloH), int(moduloV));
        //cuanto[columnas-i-1][j] = m[columnas-i-1][j].mag();
        m[i][j] = opencv.getAverageFlowInRegion(int(i*moduloH), int(j*moduloV), int(moduloH), int(moduloV));
        cuanto[i][j] = m[i][j].mag();
      }
    }
  }
  
  void evaluar( OpenCV opencv ) {
    maxValorFlujo = 0;
    int maxVal[] = {0, 0};
    for ( int i=0; i<columnas; i++ ) {
      for ( int j=0; j<filas; j++ ) {
        m[i][j] = opencv.getAverageFlowInRegion(int(i*moduloH), int(j*moduloV), int(moduloH), int(moduloV));
        cuanto[i][j] = m[i][j].mag();
        if (cuanto[i][j] > maxValorFlujo) {
          maxValorFlujo = cuanto[i][j];
          maxVal[0] = i;
          maxVal[1] = j;
        }
      }
    }
    maxCoordenada = maxVal;
  }

  float devolverCasilla( int columna, int fila, float techo ) {
    float valor = map( cuanto[columna][fila], 0, techo, 0, 255 );
    valor = constrain( valor, 0, 255 );
    return valor;
  }
  
  float[][] devolverCasillas(float techo) {
    float[][] casillas = new float[columnas][filas];
    for ( int i=0; i<columnas; i++ ) {
      for ( int j=0; j<filas; j++ ) {
        casillas[i][j] = obtenerValorNormalizado(cuanto[i][j], techo);
      }
    }
    return casillas;
  }
  
  float[] devolverPosicionIntensidad(float techo) {
    float[] salida = new float[2];
    if (maxValorFlujo == 0) {
      salida[0] = 0;
      salida[1] = 0;
    }
    else {
      salida[1] = map(maxCoordenada[0], 0, columnas, -1, 1);
      salida[0] = obtenerValorNormalizado(maxValorFlujo, techo);
    }
    return salida;
  }

  void dibujar( float x, float y, float techo ) {
    for ( int i=0; i<columnas; i++ ) {
      for ( int j=0; j<filas; j++ ) {
        float valor = map( cuanto[i][j], 0, techo, 0, 255 );
        valor = constrain( valor, 0, 255 );
        fill( valor );
        rect( x+i*moduloH, y+j*moduloV, moduloH, moduloV );
      }
    }
  }
  
  float obtenerValorNormalizado(float valor, float techo) {
    float resultado = map(valor, 0, techo, 0, 1.5);
    return constrain(resultado, 0, 1);
  }
  
}
