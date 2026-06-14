// ---------------------------------------------------------------
//
// CONTROLADOR DEL MOTOR "MANDANTE"
//
// Este código se ocupa de mover el motor que hace rotar
// hacia la izquierda y hacia la derecha la cabeza del 
// "mandante" (donde está la cámara, parlante y luces). 
// El motor empleado es un "Nema 17", modelo JK42HS34-0404,
// con un controlador A4988.
// Los eventos que indican cómo girar el motor son recibidos
// por el puerto serial de comunicación.
//
// ---------------------------------------------------------------


// Declaración de constantes globales
#define PIN_PASO_MOTOR    4
#define PIN_DIR_MOTOR     5
#define MIN_ESPERA_CICLO  2      // En milisegundos
#define SERIAL_VELOCIDAD  115200

#define ANGULO_PASO_MOTOR 1.8
#define MAX_ANGULO_MOTOR  90
#define MIN_ANGULO_MOTOR  -90

#define COMANDO_MOVER     "M"
#define COMANDO_REINICIAR "R"
#define COMANDO_LEDS      "L"
#define COMANDO_SEPARADOR ' '
#define COMANDO_PARAMS     4

#define FEEDBACK_POSICION "POS="
#define FEEDBACK_LEDS     "LED="
#define FEEDBACK_ERROR    "ERROR="



// Variables globales
String comandoRecibido[4];
int  comando_pasos     = 0;  // MOVER #1: Cuantos pasos se girará el motor
int  comando_direccion = 0;  // MOVER #2: Si el valor == 0, gira en un sentido, sino en sentido opuesto
int  comando_velocidad = 0;  // MOVER #3: Cantidad de milisegundos a esperar entre paso y paso
int  comando_leds      = 0;  // LEDS  #1: Intensidad del led ("0" significa apagado)

int   motor_demora     = 0;
bool  motor_activado   = false;
float motor_posicion   = 0;


/**
 * setup
 * Inicialización del programa. Se definen los pines de
 * Arduino a utilizar y se incializa la comunicación por
 * el puerto serial que recibirá los comandos.
 */
void setup() {
  pinMode(PIN_PASO_MOTOR, OUTPUT);
  pinMode(PIN_DIR_MOTOR,  OUTPUT);
  Serial.begin(SERIAL_VELOCIDAD);
}


/**
 * loop
 * Ciclo principal del programa
 */
void loop() {
  leerComando();

  // VERIFICACIÓN DE COMANDOS PARA "LEDS"
  // Se verifica, en primer lugar, si se trata de un comando
  // para encender o apagar las luces leds.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (comandoRecibido[0].equals(COMANDO_LEDS)) {
    comando_leds = comandoRecibido[1].toInt();
    enviarFeedbackLeds();
  }

  // VERIFICACIÓN DE COMANDOS PARA "GIRO DEL MOTOR"
  // Se verifica, luego, si se recibió un nuevo comando con la
  // información para hacer mover al motor.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  else if (comandoRecibido[0].equals(COMANDO_MOVER)) {
    if (!motor_activado) {
      comando_pasos     = comandoRecibido[1].toInt();
      comando_direccion = comandoRecibido[2].toInt() > 0 ? HIGH : LOW;
      comando_velocidad = comandoRecibido[3].toInt() <= 0 ? MIN_ESPERA_CICLO : comandoRecibido[3].toInt();
      motor_activado    = comando_pasos > 0;
      motor_demora      = comando_velocidad;
    }
    else {
      enviarFeedbackRechazo();
    }
  }

  // VERIFICACIÓN DE COMANDOS PARA "REINICIO"
  // Por último, se verifica si se trata de un comando
  // para reestablecer la posición inicial del motor
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  else if (comandoRecibido[0].equals(COMANDO_REINICIAR)) {
    motor_posicion = 0;
    motor_activado = false;
  }



  // GIRO DEL MOTOR (ACTIVACIÓN DE A UN PASO A LA VEZ)
  // A continuación, se hace girar el motor según lo indicado en
  // el comando recibido. Cada iteración del ciclo "loop" activa
  // un paso del motor a la vez (o ninguno, en caso que se deba 
  // aguardar el tiempo de "demora"). El comando se mantiene activo
  // durante las iteraciones del ciclo hasta que se completen la
  // cantidad de pasos solicitados (con sus respectivas "demoras")-
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (motor_activado) {

    // Primero se verifica si se trata de un nuevo comando, recién
    // recibido, para girar el motor (motor_demora==comando_velocidad)
    if (motor_demora == comando_velocidad) {  
      motor_posicion += (comando_direccion == HIGH ? ANGULO_PASO_MOTOR : -ANGULO_PASO_MOTOR);
      // Se chequean los topes para no hacer girar la cabeza más de 180 grados
      if (motor_posicion > MAX_ANGULO_MOTOR) {
        motor_posicion = MAX_ANGULO_MOTOR;
        motor_activado = false;
        comando_pasos = 0;
        delay(MIN_ESPERA_CICLO);
      }
      else if (motor_posicion < MIN_ANGULO_MOTOR) {
        motor_posicion = MIN_ANGULO_MOTOR;
        motor_activado = false;
        comando_pasos = 0;
        delay(MIN_ESPERA_CICLO);
      }
      // Acá, efectivamente, es donde se mueve el motor PAP
      else {
        digitalWrite(PIN_DIR_MOTOR,  comando_direccion); 
        digitalWrite(PIN_PASO_MOTOR, HIGH);
        delay(MIN_ESPERA_CICLO / 2);
        digitalWrite(PIN_PASO_MOTOR, LOW);
        delay(MIN_ESPERA_CICLO / 2);
        motor_demora -= MIN_ESPERA_CICLO;
      }
      enviarFeedbackMotor();
    }

    // Sino, signficia que aún se encuentra en medio de la ejecución
    // de alguno de los pasos del comando (esperar la "demora")
    else if (motor_demora > 0) {
      delay(MIN_ESPERA_CICLO);
      motor_demora -= MIN_ESPERA_CICLO;
    }

    // Si ya no queda "demora" por esperar, significa que acaba de
    // terminar de mover un paso. Se debe verificar si hay más pasos
    // o si ya se completaron todos los pasos pedidos en el comando.
    else {
      if (comando_pasos > 0) {
        comando_pasos -= 1;
        motor_activado = comando_pasos > 0;
        motor_demora = comando_velocidad;
      }
    }
  }

}


/**
 * leerComando
 * Recibe los comandos que ingresan por el puerto serial,
 * interpreta sus parámetros y deja la información en el
 * array global "comandoRecibido".
 */
void leerComando() {
  blanquearComando();
  while (Serial.available() > 0) {
    int indice = 0;
    String mensaje = Serial.readStringUntil('\n');
    int posicionSeparador = mensaje.indexOf(COMANDO_SEPARADOR);
    while (posicionSeparador > 0 && indice < COMANDO_PARAMS) {
      comandoRecibido[indice] = mensaje.substring(0, posicionSeparador);
      mensaje = mensaje.substring(posicionSeparador + 1);
      posicionSeparador = mensaje.indexOf(COMANDO_SEPARADOR);
      indice++;
    }
    comandoRecibido[indice] = mensaje.substring(posicionSeparador + 1);
  }
}


/**
 * blanquearComando
 * Pone en blanco cada una de las posiciones del array
 * global "comandoRecibido".
 */
void blanquearComando() {
  for (int i = 0; i < COMANDO_PARAMS; i++) {
    comandoRecibido[i] = "";
  }
}


/**
 * enviarFeedbackMotor
 * Envía un mensaje a Processing, a través del puerto serial,
 * indicando el ángulo actual (la posición) del motor.
 */
void enviarFeedbackMotor() {
  Serial.print(FEEDBACK_POSICION);
  Serial.println(motor_posicion);
}


/**
 * enviarFeedbackLeds
 * Envía un mensaje a Processing, a través del puerto serial,
 * indicando el estado de los leds (intensidad)-
 */
void enviarFeedbackLeds() {
  Serial.print(FEEDBACK_LEDS);
  Serial.println(comando_leds);
}


/**
 * enviarFeedbackRechazo
 * Envía un mensaje a Processing, a través del puerto serial,
 * indicando que el comando recibido fue rechazado.
 */
void enviarFeedbackRechazo() {
  Serial.print(FEEDBACK_ERROR);
  Serial.print("Comando para girar el motor rechazado. Pasos=");
  Serial.print(comandoRecibido[1]);
  Serial.print(", Dirección=");
  Serial.print(comandoRecibido[2]);
  Serial.print(", Velocidad (ms)=");
  Serial.println(comandoRecibido[3]);
}
