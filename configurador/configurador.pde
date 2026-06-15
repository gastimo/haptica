// 
// MÓDULO "CONFIGURADOR"
// ---------------------
// Componente de testeo y calibración para la posición del motor y las
// luces del módulo mandante. Este programa simplemente envía mensajes 
// (comandos para el mandante) por OSC cada vez que se presiona alguna
// de las siguientes teclas:
//
// COMANDOS PARA CALIBRACIÓN:
//  "X" : Gira el motor un paso hacia la izquierda
//  "Z" : Gira el motor diez pasos hacia la izquierda
//  "V" : Gira el motor un paso hacia la derecha
//  "B" : Gira el motor diez pasos hacia la derecha
//  "C" : Calibra el motor (define la posición actual como punto de inicio)
//  "R" : Reinicia el motor (colocarlo en su posición inicial)
//
// COMANDOS PARA LUCES LEDS:
//  "0" : Apaga las luces leds
//  "1" a "9" : Enciende las luces leds con distintos grados de intensidad
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
  background(255, 255, 0);  
  transmisor = new TransmisorOSC(PUERTO_CONFIGURADOR, IP_MANDANTE, PUERTO_MANDANTE);
}



/**
 * Función estándar de Processing que se ejecuta en cada una de las
 * iteraciones del ciclo principal
 */
void draw() {
}


void keyPressed() {
  
  // CALIBRACIÓN DEL MOTOR
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (key == 'c' || key == 'C') {
    transmisor.enviar(CALIBRAR_POSICION, 0, DIR_CONFIGURADOR);
  }
  else if (key == 'r' || key == 'R') {
    transmisor.enviar(CALIBRAR_REINICIO, 0, DIR_CONFIGURADOR);
  }
  else if (key == 'x' || key == 'X') {
    transmisor.enviar(CALIBRAR_DIR_IZQ, 1, DIR_CONFIGURADOR);
  }
  else if (key == 'z' || key == 'Z') {
    transmisor.enviar(CALIBRAR_DIR_IZQ, 10, DIR_CONFIGURADOR);
  }
  else if (key == 'v' || key == 'V') {
    transmisor.enviar(CALIBRAR_DIR_DER, 1, DIR_CONFIGURADOR);
  }
  else if (key == 'b' || key == 'B') {
    transmisor.enviar(CALIBRAR_DIR_DER, 10, DIR_CONFIGURADOR);
  }
  
  // ENCENDIDO Y APAGADO DE LAS LUCES LEDS
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  else if (key == '0') {
    transmisor.enviar(CONTROL_LUCES_LED, 0, DIR_CONFIGURADOR);
  }
  else if (key == '1') {
    transmisor.enviar(CONTROL_LUCES_LED, 1, DIR_CONFIGURADOR);
  }
  else if (key == '2') {
    transmisor.enviar(CONTROL_LUCES_LED, 2, DIR_CONFIGURADOR);
  }
  else if (key == '3') {
    transmisor.enviar(CONTROL_LUCES_LED, 3, DIR_CONFIGURADOR);
  }
  else if (key == '4') {
    transmisor.enviar(CONTROL_LUCES_LED, 4, DIR_CONFIGURADOR);
  }
  else if (key == '5') {
    transmisor.enviar(CONTROL_LUCES_LED, 5, DIR_CONFIGURADOR);
  }
  else if (key == '6') {
    transmisor.enviar(CONTROL_LUCES_LED, 6, DIR_CONFIGURADOR);
  }
  else if (key == '7') {
    transmisor.enviar(CONTROL_LUCES_LED, 7, DIR_CONFIGURADOR);
  }
  else if (key == '8') {
    transmisor.enviar(CONTROL_LUCES_LED, 8, DIR_CONFIGURADOR);
  }
  else if (key == '9') {
    transmisor.enviar(CONTROL_LUCES_LED, 9, DIR_CONFIGURADOR);
  }
}
