// 
// TRANSMISOR OSC
// Objeto a cargo de la inicialización de los servicios de envío y
// recepción de mensajes mediante el protocolo de red OSC (Open Sound
// Control). Utiliza la librería "oscP5" de Andreas Schelegel:
//
//   https://sojamo.de/libraries/oscp5/
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import oscP5.*;
import netP5.*;

OscP5 oscP5;
int puertoEntrante = 0;
boolean oscInicializado = false;


class TransmisorOSC {  
  NetAddress direccionRemota;
  NetAddress direccionAdicional;
  OscMessage mensajeOSC;
  boolean replicador = false;

  
  public TransmisorOSC() {
    this(12000, "127.0.0.1", 12001);
  }

  public TransmisorOSC(int puertoLocal, String ipDestino, int puertoDestino) {
    if (!oscInicializado) {
      oscP5 = new OscP5(this, puertoLocal);
      puertoEntrante = puertoLocal;
      oscInicializado = true;
    }
    else {
      if (puertoEntrante != puertoLocal) {
        println("Error creando transmisor OSC para el puerto " + puertoLocal + 
                ". El servidor ya se encuentra escuchando en el puerto " + puertoEntrante);
      }
    }
    direccionRemota = new NetAddress(ipDestino, puertoDestino);
  }
  
  public TransmisorOSC replicar(String ipDestino, int puertoDestino) {
    direccionAdicional = new NetAddress(ipDestino, puertoDestino);
    replicador = true;
    return this;
  }
  
  
  public void enviar(byte[] paquete, String direccion) {
    if (oscInicializado) {
      mensajeOSC = new OscMessage(direccion);
      mensajeOSC.add(paquete);
      oscP5.send(mensajeOSC, direccionRemota);
      if (replicador) {
        oscP5.send(mensajeOSC, direccionAdicional);
      }
    }
  }
  
  public void enviar(String discriminador, int valor, String direccion) {
    if (oscInicializado) {
      mensajeOSC = new OscMessage(direccion);
      mensajeOSC.add(discriminador);
      mensajeOSC.add(valor);
      oscP5.send(mensajeOSC, direccionRemota);
      if (replicador) {
        oscP5.send(mensajeOSC, direccionAdicional);
      }
    }
  }
  
  public void enviar(float[][] matriz, String direccion) {
    OscMessage mensaje;
    if (oscInicializado) {
      mensaje = new OscMessage(direccion);
      for (int i = 0; i < matriz.length; i++) {
        for (int j = 0; j < matriz[i].length; j++) {
          mensaje.add(matriz[i][j]);
        }
      }
      oscP5.send(mensaje, direccionRemota);
      if (replicador) {
        oscP5.send(mensaje, direccionAdicional);
      }
    }
  }
  
  
  /**
   * oscEvent
   * Función principal de la librería oscP5 que es invocada de
   * forma automática cada vez que un evento OSC es recibido.
   */
  public void oscEvent(OscMessage mensajeEntrante) {
  
    // Recibir mensaje de prueba
    if (mensajeEntrante.checkAddrPattern("/test")) {
      if (mensajeEntrante.checkTypetag("ifs")) {
        int firstValue     = mensajeEntrante.get(0).intValue();
        float secondValue  = mensajeEntrante.get(1).floatValue();
        String thirdValue  = mensajeEntrante.get(2).stringValue();
        println(" #Mensaje OSC de prueba recibido. Valores: " + firstValue + ", " + secondValue + ", " + thirdValue);
      }
    }
    
    // Recibir mensaje del "Calibrador"
    else if (mensajeEntrante.checkAddrPattern(DIR_CALIBRADOR)) {
      if (mensajeEntrante.checkTypetag("si")) {
        String discriminador = mensajeEntrante.get(0).stringValue();
        int    valor = mensajeEntrante.get(1).intValue();
        println(" #Mensaje OSC del CALIBRADOR recibido. Discriminador=" + discriminador + ", Valor=" + valor);
      }
    }
    
  }
  
  
}
