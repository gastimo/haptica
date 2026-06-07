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


// Variables globales
byte comando[4];  // El comando recibido tiene 4 bytes, según el detalle a continuación
int  comando_orden     = -1; // BYTE #0: Número identificador del comando a ejecutar
int  comando_pasos     = 0;  // BYTE #1: Cuantos pasos se girará el motor
int  comando_direccion = 0;  // BYTE #2: Si el valor == 0, gira en un sentido, sino en sentido opuesto
int  comando_velocidad = 0;  // BYTE #3: Cantidad de milisegundos a esperar entre paso y paso
int  motor_demora      = 0;
bool motor_activado    = false;


void setup() {
  pinMode(PIN_PASO_MOTOR, OUTPUT);
  pinMode(PIN_DIR_MOTOR,  OUTPUT);
  Serial.begin(SERIAL_VELOCIDAD); // Debe coincidir con la velocidad definida en Processing
}


void loop() {

  // 1. RECEPCIÓN DE COMANDOS POR PUERTO SERIAL
  // En primer lugar, se reciben los mensajes por el puerto serial
  // indicando cómo mover el motor (y cuánto tiempo esperar).
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  while (Serial.available() > 0) {
    int bytesLeidos = Serial.readBytes(comando, 4);
    if (bytesLeidos == 4) {
      // Se verifica si llegó un nuevo comando para hacer girar el motor
      int comando_recibido = int(comando[0]);
      if (comando_recibido != comando_orden) {
        comando_orden     = comando_recibido;
        comando_pasos     = int(comando[1]);
        comando_direccion = int(comando[2]) != 0 ? HIGH : LOW;
        comando_velocidad = int(comando[3]) <= 0 ? ESPERA_CICLO : int(comando[3]);
        motor_activado    = comando_pasos > 0;
        motor_demora      = comando_velocidad;
      }
    }
  }


  // 2. GIRO DEL MOTOR (ACTIVACIÓN DE A UN PASO A LA VEZ)
  // A continuación, se hace girar el motor según lo indicado en
  // el comando recibido. Cada iteración del ciclo "loop" activa
  // un paso del motor a la vez. El comando se mantiene activo
  // durante las iteraciones del ciclo hasta que se completen la
  // cantidad de pasos solicitados por el comando.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (motor_activado) {
    if (motor_demora > 0) {
      digitalWrite(PIN_DIR_MOTOR,  comando_direccion); 
      digitalWrite(PIN_PASO_MOTOR, HIGH);
      delay(ESPERA_CICLO / 2);
      digitalWrite(PIN_PASO_MOTOR, LOW);
      delay(ESPERA_CICLO / 2);
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

