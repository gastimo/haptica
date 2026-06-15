// 
// MÓDULO PRINCIPAL "MANDANTE"
// Módulo principal que controla el dispositivo montado sobre el 
// trípode sobre el que se dispone la cámara, luces y parlantes.
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// Parámetros generales para configuración del "Mandante"
boolean CAPTURA_VIDEO_ACTIVA = true;    // Captura el video de la webcam para su procesamiento
boolean SALIDA_VIDEO_ACTIVA  = true;    // Produce video de monitoreo en la ventana de Processing
boolean ENVIAR_FLUJO_OPTICO  = true;    // Envía por OSC la matriz del "Flujo Óptico" calculado


// Variables globales para el procesamiento
Camara camara;
PImage imagenOriginal;
Rotor rotor;
Fanal fanal;
Procesador procesador;
TransmisorSerial serializador;
TransmisorOSC transmisor;



/**
 * settings
 * Función estándar de Processing usada para definir las dimensiones
 * de la ventana de previsualización (la salida del video).
 */
void settings() {
  if (SALIDA_VIDEO_ACTIVA) {
    size(CAMARA_ANCHO * 2, CAMARA_ALTO);
  }
  else {
    size(200, 200);
  }
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
  transmisor   = new TransmisorOSC(PUERTO_MANDANTE, IP_CONTROLADOR, PUERTO_CONTROLADOR);
  serializador = new TransmisorSerial(this);
  rotor = new Rotor(serializador);
  fanal = new Fanal(serializador);
  transmisor.enviarDimensiones(FLUJO_OPTICO_COLUMNAS, FLUJO_OPTICO_FILAS, DIR_FLUJO_OPTICO_DIM);
}



/**
 * Función estándar de Processing que se ejecuta en cada una de las
 * iteraciones del ciclo principal
 */
void draw() {
  if (camara.inicializada() && camara.imagenDisponible() && CAPTURA_VIDEO_ACTIVA) {
    
     // 1. CAPTURA DE LA IMAGEN DE LA WEBCAM
     // Mediante la librería de video de Processing se obtienen
     // las imágenes capturadas por la webcam.
     // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
     camara.capturar();
     imagenOriginal = camara.video().get(0, 0, CAMARA_ANCHO, CAMARA_ALTO);
     
     
     // 2. PROCESAMIENTO DE LA IMAGEN
     // Mediante la librería de OpenCV se calcula el "Flujo Óptico"
     // para detectar el movimiento en el video capturado.
     // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
     procesador.evaluar(imagenOriginal, FLUJO_OPTICO_TECHO);
     //float[] e = procesador.posicionIntensidad();
     //println("POS=" + e[0] + ", INT=" + e[1]);  


     // 3. GENERACIÓN DEL VIDEO DE SALIDA
     // Se generan las imágenes en la ventana principal de Processing
     // (sólo si el parámetro está activo). Este video es utilizado
     // únicamente para monitoreo del funcionamiento del módulo.
     // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
     if (SALIDA_VIDEO_ACTIVA) {
       if (CAPTURA_VIDEO_ACTIVA) {
         image(imagenOriginal, 0, 0);
         procesador.mostrar(CAMARA_ANCHO, 0, FLUJO_OPTICO_TECHO);
       }
     }
    
    
     // 4. ENVÍO DE INFORMACIÓN AL "CONTROLADOR"
     // Se envía por OSC la matriz con los valores del "Flujo Óptico"
     // (sólo si el parámetro está activo). La información es enviada
     // al "Controlador" para determinar las acciones a ejecutar.
     // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv    
     if (ENVIAR_FLUJO_OPTICO) {
       if (CAPTURA_VIDEO_ACTIVA) {
         transmisor.enviar(procesador.flujoOptico(), DIR_FLUJO_OPTICO);
       }
     }
  }
  
}


/**
 * serialEvent
 * Función que recibe y procesa los mensajes recibidos
 * desde Arduino por el puerto serial.
 */
void serialEvent(Serial myPort) {
  String mensaje = myPort.readStringUntil('\n');
  if (mensaje != null) {
    mensaje = trim(mensaje);
    if (mensaje.startsWith(FEEDBACK_POSICION)) {
      rotor.guardarPosicion(float(mensaje.substring(4)));
      println(" ########## ARDUINO HA RESPONDIDO (Motor): " + mensaje);
    }
    else if (mensaje.startsWith(FEEDBACK_LEDS)) {
      println(" ########## ARDUINO HA RESPONDIDO (Leds): " + mensaje);
    }
    else {
      println(" ########## ARDUINO HA RESPONDIDO: " + mensaje);
    }
  }
}
