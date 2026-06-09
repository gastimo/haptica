// 
// TRANSMISOR SERIAL
// Funciones de inicialización del puerto serial de comunicación
// y de envío de datos a través de este mismo puerto.
// Se utiliza la libreria "Serial" de Processing:
//
//   https://processing.org/reference/libraries/serial/index.html
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import processing.serial.*;


class TransmisorSerial {
  Serial puertoSerial;
  String conexion = null;
  boolean inicializado = false;
  byte[] datos = {0x00, 0x00, 0x00, 0x00, 0x00};
  
  public TransmisorSerial(PApplet contenedor) {
    String[] puertos = Serial.list();
    for (int i = 0; i < puertos.length; i++) {
      println("PUERTOS SERIALES DETECTADOS=" + puertos[i]);
      if (puertos.length > 0 && puertos[i].startsWith(SERIAL_PREFIJO_PUERTO)) {
        conexion = Serial.list()[i];
        break;
      }
    }
    
    if (conexion == null && puertos.length > 0) {
      conexion = Serial.list()[0];
    }

    if (conexion != null) {
      // CREACIÓN DEL PUERTO 
      // Se crea un puerto serial que debe ser el mismo que el puerto
      // donde está conectado el Arduino. La velocidad de transferencia
      // también debe coincidir en ambos casos.
      puertoSerial = new Serial(contenedor, conexion, SERIAL_VELOCIDAD_PUERTO);
      inicializado = true;
      println("PUERTO SERIAL CONECTADO");
    }
    
    if (!inicializado) {
      println("No se detectó ningún puerto.");
    } 
  }
  
  public void enviar(byte[] datos) {
    if (inicializado) {
      puertoSerial.write(datos);
    }
  }
  
  public void enviar(String mensaje) {
    if (inicializado) {
      puertoSerial.write(mensaje);
    }
  }

}
