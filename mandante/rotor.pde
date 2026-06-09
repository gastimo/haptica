// 
// ROTOR
// Controlador del motor. Se trata de un objeto intermediario
// que arma los comandos a enviar al motor a través del puerto
// de comunicación serial.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


class Rotor {
  
  float posicion_actual;
  TransmisorSerial transmisor;

  public Rotor(TransmisorSerial serializador) {
    posicion_actual = 0;
    transmisor = serializador;
  }
  
  void guardarPosicion(float pos) {
    posicion_actual = pos;
    println("Posición del motor=" + posicion_actual);
  }
  
  void mover(int pasos, int direccion, int velocidad) {
    String comando = COMANDO_MOVER + " " + pasos + " " + direccion + " " + velocidad + "\n";
    transmisor.enviar(comando);
  }
  
  void calibrar(String accion, int valor) {
    if (accion.equals(CALIBRAR_POSICION)) {
      transmisor.enviar(COMANDO_REINICIAR + " 0 0 0\n");
    }
    else if (accion.equals(CALIBRAR_DIR_DER)) {
      mover(valor, 1, valor * 2);
    }
    else if (accion.equals(CALIBRAR_DIR_IZQ)) {
      mover(valor, -1, valor * 2);
    }
    else if (accion.equals(CALIBRAR_REINICIO)) {
      if (posicion_actual != 0) {
        mover(abs(int(posicion_actual / 1.8)), -int(posicion_actual/abs(posicion_actual)), 40);
      }
    }
  }
  
  void girar(float posicion, float intensidad) {
  }

}
