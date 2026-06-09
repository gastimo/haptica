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
#define PIN_PASO_MOTOR 4
#define PIN_DIR_MOTOR  5
#define ESPERA_CICLO   2         // En milisegundos
#define SERIAL_VELOCIDAD 115200

#define ANGULO_PASO_MOTOR 1.8
#define MAX_ANGULO_MOTOR  180
#define MIN_ANGULO_MOTOR  -180

#define COMANDO_MOVER     "M"
#define COMANDO_REINICIAR "R"
#define COMANDO_SEPARADOR ' '
#define COMANDO_PARAMS     4
#define COMANDO_POSICION  "POS="


// Variables globales
String comando[4];
int  comando_pasos     = 0;  // PARAM #1: Cuantos pasos se girará el motor
int  comando_direccion = 0;  // PARAM #2: Si el valor == 0, gira en un sentido, sino en sentido opuesto
int  comando_velocidad = 0;  // PARAM #3: Cantidad de milisegundos a esperar entre paso y paso

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
  blanquearComando();
}


/**
 * loop
 * Ciclo principal del programa
 */
void loop() {
  leerComando();

  // Se verifica si se recibió un nuevo comando con la
  // información para hacer mover al motor.
  if (comando[0].equals(COMANDO_MOVER)) {
    if (!motor_activado) {
      comando_pasos     = comando[1].toInt();
      comando_direccion = comando[2].toInt() > 0 ? HIGH : LOW;
      comando_velocidad = comando[3].toInt() <= 0 ? ESPERA_CICLO : comando[3].toInt();
      motor_activado    = comando_pasos > 0;
      motor_demora      = comando_velocidad;
    }
    else {
      notificarComandoRechazado();
    }
  }
  else if (comando[0].equals(COMANDO_REINICIAR)) {
    motor_posicion = 0;
    motor_activado = false;
  }


  // 2. GIRO DEL MOTOR (ACTIVACIÓN DE A UN PASO A LA VEZ)
  // A continuación, se hace girar el motor según lo indicado en
  // el comando recibido. Cada iteración del ciclo "loop" activa
  // un paso del motor a la vez. El comando se mantiene activo
  // durante las iteraciones del ciclo hasta que se completen la
  // cantidad de pasos solicitados por el comando.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (motor_activado) {
    if (motor_demora == comando_velocidad) {
      digitalWrite(PIN_DIR_MOTOR,  comando_direccion); 
      digitalWrite(PIN_PASO_MOTOR, HIGH);
      delay(ESPERA_CICLO / 2);
      digitalWrite(PIN_PASO_MOTOR, LOW);
      delay(ESPERA_CICLO / 2);
      motor_demora -= ESPERA_CICLO;
      motor_posicion += (comando_direccion == HIGH ? ANGULO_PASO_MOTOR : -ANGULO_PASO_MOTOR);
      if (motor_posicion > MAX_ANGULO_MOTOR) {
        motor_posicion = MAX_ANGULO_MOTOR;
      }
      else if (motor_posicion < MIN_ANGULO_MOTOR) {
        motor_posicion = MIN_ANGULO_MOTOR;
      }
      enviarPosicionMotor();
    }
    else if (motor_demora > 0) {
      delay(ESPERA_CICLO);
      motor_demora -= ESPERA_CICLO;
    }
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
 * array global "comando".
 */
void leerComando() {
  blanquearComando();
  while (Serial.available() > 0) {
    int indice = 0;
    String mensaje = Serial.readStringUntil('\n');
    int posicionSeparador = mensaje.indexOf(COMANDO_SEPARADOR);
    while (posicionSeparador > 0 && indice < COMANDO_PARAMS) {
      comando[indice] = mensaje.substring(0, posicionSeparador);
      mensaje = mensaje.substring(posicionSeparador + 1);
      posicionSeparador = mensaje.indexOf(COMANDO_SEPARADOR);
      indice++;
    }
    comando[indice] = mensaje.substring(posicionSeparador + 1);
  }
}

/**
 * blanquearComando
 * Pone en blanco cada una de las posición del array
 * global "comando".
 */
void blanquearComando() {
  for (int i = 0; i < COMANDO_PARAMS; i++) {
    comando[i] = "";
  }
}


/**
 * enviarPosicionMotor
 * Envía un mensaje a Processing, a través del puerto serial,
 * indicando el ángulo actual (la posición) del motor.
 */
void enviarPosicionMotor() {
  Serial.print(COMANDO_POSICION);
  Serial.println(motor_posicion);
}


/**
 * notificarComandoRechazado
 * Envía un mensaje a Processing, a través del puerto serial,
 * indicando que el comando recibido fue rechazado.
 */
void notificarComandoRechazado() {
  Serial.print("ERROR=");
  Serial.print("Comando para girar el motor rechazado. Pasos=");
  Serial.print(comando[1]);
  Serial.print(", Dirección=");
  Serial.print(comando[2]);
  Serial.print(", Velocidad (ms)=");
  Serial.println(comando[3]);
}



