// 
// ROTOR
// Controlador del motor. Se trata de un objeto intermediario
// que arma los comandos a enviar al motor a través del puerto
// de comunicación serial.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


class Rotor {
  
  int posicion_actual;
  TransmisorSerial transmisor;

  public Rotor(TransmisorSerial serializador) {
    posicion_actual = 0;
    transmisor = serializador;
  }
  
  void girar(float posicion, float intensidad) {
  }

}
