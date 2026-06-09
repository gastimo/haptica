// 
// MÓDULO "CALIBRADOR"
// Componentes para establecer la posición inicial del motor
// utilizado por el módulo "Mandante".
// Para calibrar el motor, se utilizan las siguientes teclas:
//
//  "X" : Gira el motor un paso hacia la izquierda
//  "Z" : Gira el motor diez pasos hacia la izquierda
//  "V" : Gira el motor un paso hacia la derecha
//  "B" : Gira el motor diez pasos hacia la derecha
//  "C" : Calibra el motor (define la posición actual como punto de inicio)
//  "R" : Reinicia el motor (colocarlo en su posición inicial)
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


TransmisorOSC    transmisor;



/**
 * settings
 * Función estándar de Processing usada para definir las dimensiones
 * de la ventana de previsualización (la salida del video).
 */
void settings() {
  size(VENTANA_ANCHO, VENTANA_ALTO);
}


/**
 * setup
 * Función estándar de Processing para ejecutar las tareas
 * iniciales y de configuración.
 */
void setup() {
  background(0);  
  transmisor = new TransmisorOSC(PUERTO_CALIBRADOR, IP_MANDANTE, PUERTO_MANDANTE);
}



/**
 * Función estándar de Processing que se ejecuta en cada una de las
 * iteraciones del ciclo principal
 */
void draw() {
}


void keyPressed() {
  if (key == 'c' || key == 'C') {
    transmisor.enviar(CALIBRAR_POSICION, 0, DIR_CALIBRADOR);
  }
  else if (key == 'r' || key == 'R') {
    transmisor.enviar(CALIBRAR_REINICIO, 0, DIR_CALIBRADOR);
  }
  else if (key == 'x' || key == 'X') {
    transmisor.enviar(CALIBRAR_DIR_IZQ, 1, DIR_CALIBRADOR);
  }
  else if (key == 'z' || key == 'Z') {
    transmisor.enviar(CALIBRAR_DIR_IZQ, 10, DIR_CALIBRADOR);
  }
  else if (key == 'v' || key == 'V') {
    transmisor.enviar(CALIBRAR_DIR_DER, 1, DIR_CALIBRADOR);
  }
  else if (key == 'b' || key == 'B') {
    transmisor.enviar(CALIBRAR_DIR_DER, 10, DIR_CALIBRADOR);
  }
}
