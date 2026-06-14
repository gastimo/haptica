// 
// FANAL
// Controlador del encendido y apagado de las luces del "Mandante"
// Se trata de un objeto intermediario que arma los comandos a enviar
// a la tira de leds a través del puerto de comunicación serial.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


class Fanal {
  
  TransmisorSerial transmisor;

  public Fanal(TransmisorSerial serializador) {
    transmisor = serializador;
  }
  
  void intensidad(float valor) {
    String comando = COMANDO_LEDS + " " + int(valor) + "\n";
    transmisor.enviar(comando);
  }
}
  
