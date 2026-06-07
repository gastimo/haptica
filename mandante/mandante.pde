// 
// MÓDULO "MANDANTE"
// Módulo principal que controla el dispositivo montado sobre el 
// trípode sobre el que se dispone la cámara, luces y parlantes.
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// Variables globales para el procesamiento
Camara camara;
PImage imagenOriginal;
Procesador procesador;
TransmisorSerial serializador;
TransmisorOSC    transmisor;



/**
 * settings
 * Función estándar de Processing usada para definir las dimensiones
 * de la ventana de previsualización (la salida del video).
 */
void settings() {
  size(CAMARA_ANCHO * 2, CAMARA_ALTO);
}


/**
 * setup
 * Función estándar de Processing para ejecutar las tareas
 * iniciales y de configuración.
 */
void setup() {
  background(0);  
  
  // 1. INICIALIZACIÓN DE LA CÁMARA Y EL PROCESADOR DE VIDEO
  // Se crean las instancias de los objetos para capturar el video mediante
  // la webcam y procesarlo en tiempo real (con la librería de OpenCV).
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  
  camara     = new Camara(this);
  procesador = new Procesador(this, CAMARA_ANCHO, CAMARA_ALTO, FLUJO_OPTICO_COLUMNAS, FLUJO_OPTICO_FILAS);
  

  // 2. INICIALIZACIÓN DE LOS TRANSMISORES (OSC Y SERIAL)
  // Se crean las instancias de los transmisores encargados de enviar los 
  // mensajes a través del protocolo OSC y a través del puerto serial.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  
  transmisor   = new TransmisorOSC(PUERTO_MANDANTE, IP_ORQUESTADOR, PUERTO_ORQUESTADOR);
  serializador = new TransmisorSerial(this);
}



/**
 * Función estándar de Processing que se ejecuta en cada una de las
 * iteraciones del ciclo principal
 */
void draw() {
  if (camara.inicializada() && camara.imagenDisponible()) {
     // Captura de la imagen de video de la webcam
     camara.capturar();
     imagenOriginal = camara.video().get(0, 0, CAMARA_ANCHO, CAMARA_ALTO);
     image(imagenOriginal, 0, 0);
     
     // Procesamiento con OpenCV (para calcular el flujo óptico)
     procesador.calcular(imagenOriginal, FLUJO_OPTICO_TECHO);
     procesador.mostrar(CAMARA_ANCHO, 0, FLUJO_OPTICO_TECHO);
    
    // Envío por OSC de la matriz con los valores del flujo óptico
    transmisor.enviar(procesador.flujoOptico(), DIR_FLUJO_OPTICO);
  }
}
