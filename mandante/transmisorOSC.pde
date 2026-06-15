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
  
  public void enviarDimensiones(int columnas, int filas, String direccion) {
    OscMessage mensaje;
    if (oscInicializado) {
      mensaje = new OscMessage(direccion);
      mensaje.add(columnas);
      mensaje.add(filas);
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
    
    // RECEPCIÓN DE MENSAJES DEL "CONFIGURADOR"
    // Este mensaje contiene la información de los comandos del "Configurador"
    // Estos mensajes permiten, por un lado, calibrar el motor y, por otro, encencer las luces.
    //  1. ACCION (String): Acción a realizar ("calibrar", "reiniciar", "izquierda", "derecha", "leds")
    //  2. VALOR (integer): Nro. de pasos (ACCIÓN=izquierda/derecha) o intensidad del led (ACCIÓN=leds).
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    else if (mensajeEntrante.checkAddrPattern(DIR_CONFIGURADOR)) {
      if (mensajeEntrante.checkTypetag("si")) {
        String accion = mensajeEntrante.get(0).stringValue();
        int    valor  = mensajeEntrante.get(1).intValue();
        if (accion.equals(CONTROL_LUCES_LED)) {
          println("");
          println(" ### CALIBRACIÓN -> Prueba del fanal. Intensidad LED=" + valor);
          fanal.intensidad(valor);
        }
        else {
          println("");
          println(" ### CALIBRACIÓN -> Calibración del motor. Acción=" + accion + ", Valor=" + valor);
          rotor.calibrar(accion, valor); 
        }
      }
    }
    
    
    // RECEPCIÓN DE MENSAJES DEL "CONTROLADOR" PARA EL MOTOR
    // Este mensaje contiene valores numéricos para controlar el giro del motor.
    //  1. PASOS (float)     : Indica cuántos pasos se debe mover el motor
    //  2. DIRECCION (float) : Indica el sentido de giro (>0 en un sentido y <=0 en sentido opuesto
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    else if (mensajeEntrante.checkAddrPattern(DIR_CONTROLADOR)) {
      if (mensajeEntrante.checkTypetag("ii")) {
        int pasos = mensajeEntrante.get(0).intValue();
        int direccion = mensajeEntrante.get(1).intValue();
        println(" ### CONTROLADOR ==> Mover el motor. Pasos=" + pasos + ", Dirección=" + direccion);
        rotor.rotar(pasos, direccion);
      }
    }
    
    // RECEPCIÓN DE MENSAJES DEL "CONTROLADOR" PARA LAS LUCES LEDS
    // Este mensaje recibe único valor (entre 0 y 1) que indica la intensidad para las luces leds 
    // (cero significa que deben apagarse los leds).
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    else if (mensajeEntrante.checkAddrPattern(DIR_ENCENDEDOR)) {
      if (mensajeEntrante.checkTypetag("f")) {
        float valor = mensajeEntrante.get(0).floatValue();
        println(" ### CONFIGURADOR ==> Encender el fanal. Intensidad=" + valor);
        fanal.intensidad(valor);
      }
    }
}
  
  
}
