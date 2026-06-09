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
  
    // RECEPCIÓN DE MENSAJES DEL "PRUEBA"
    // Mensaje plantilla para ejemplificar la recepción de mensajes a través de la librería OSC.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    if (mensajeEntrante.checkAddrPattern("/test")) {
      if (mensajeEntrante.checkTypetag("ifs")) {
        int firstValue     = mensajeEntrante.get(0).intValue();
        float secondValue  = mensajeEntrante.get(1).floatValue();
        String thirdValue  = mensajeEntrante.get(2).stringValue();
        println(" #Mensaje OSC de prueba recibido. Valores: " + firstValue + ", " + secondValue + ", " + thirdValue);
      }
    }
    
    // RECEPCIÓN DE MENSAJES DEL "CALIBRADOR"
    // Este mensaje contiene la información para mover y calibrar la posición 
    // inicial del motor del mandante. Sus argumentos son:
    //  1. ACCION (String) : Acción a realizar ("calibrar", "reiniciar", "izquierda", "derecha")
    //  2. VALOR (integer) : Cantidad de pasos a girar (sólo cuando la acción es "izquierda" o "derecha")
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    else if (mensajeEntrante.checkAddrPattern(DIR_CALIBRADOR)) {
      if (mensajeEntrante.checkTypetag("si")) {
        String accion = mensajeEntrante.get(0).stringValue();
        int    valor  = mensajeEntrante.get(1).intValue();
        println(" #Mensaje OSC del CALIBRADOR recibido. Acción=" + accion + ", Valor=" + valor);
      }
    }
    
    
    // RECEPCIÓN DE MENSAJES DEL "CONTROLADOR"
    // Este mensaje contiene valores numéricos para controlar el giro del motor.
    //  1. POSICIÓN (float)   : Es un valor entre -1 y 1 indicando la posición de giro del motor
    //  2. INTENSIDAD (float) : Es un valor entre 0 y 1 indicanto la velocidad de giro.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    else if (mensajeEntrante.checkAddrPattern(DIR_CONTROLADOR)) {
      if (mensajeEntrante.checkTypetag("ff")) {
        float posicion   = mensajeEntrante.get(0).floatValue();
        float intensidad = mensajeEntrante.get(1).floatValue();
        println(" #Mensaje OSC del CONTROLADOR recibido. Posición=" + posicion + ", Intensidad=" + intensidad);
        rotor.girar(posicion, intensidad);
      }
    }

}
  
  
}
