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
  }
  
  void mover(int pasos, int direccion, int velocidad) {
    String comando = COMANDO_MOVER + " " + pasos + " " + direccion + " " + velocidad + "\n";
    transmisor.enviar(comando);
  }
    
  void rotar(int pasos, int direccion) {
    if (pasos != 0) {
      mover(abs(pasos), (direccion > 0 ? 1 : 0), COMANDO_VELOCIDAD_GIRO);
      println("  ==> COMANDO> ROTAR MOTOR: PASOS=" + abs(pasos) + ", DIRECCIÓN=" + direccion);
    }
  }
    
  void rotar(float posicion, float intensidad) {
    float angulo = map(posicion, -1, 1, MIN_ANGULO_MOTOR, MAX_ANGULO_MOTOR);
    int pasos = int((angulo - posicion_actual) / 1.8);
    if (pasos != 0) {
      mover(abs(pasos), pasos, int(map(intensidad, 0, 1, 1, COMANDO_VELOCIDAD_GIRO)));
      println("  ==> COMANDO> ROTAR MOTOR: PASOS=" + abs(pasos));
    }
  }
  
  void calibrar(String accion, int valor) {
    if (accion.equals(CALIBRAR_POSICION)) {
      transmisor.enviar(COMANDO_REINICIAR + " 0 0 0\n");
    }
    else if (accion.equals(CALIBRAR_DIR_DER)) {
      mover(valor, 0, valor * 3);
    }
    else if (accion.equals(CALIBRAR_DIR_IZQ)) {
      mover(valor, 1, valor * 3);
    }
    else if (accion.equals(CALIBRAR_REINICIO)) {
      if (posicion_actual != 0) {
        int sentido = -int(posicion_actual/abs(posicion_actual));
        mover(abs(int(posicion_actual / 1.8)), sentido <= 0 ? 0 : 1, 1);
      }
    }
  }

}
