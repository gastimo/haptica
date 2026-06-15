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
#include <Adafruit_NeoPixel.h>


// Declaración de constantes globales
#define PIN_PASO_MOTOR    4
#define PIN_DIR_MOTOR     5
#define PIN_PIXEL_LEDS    6
#define ESPERA_CICLO      36      // En milisegundos
#define MIN_ESPERA_CICLO  20      // En milisegundos
#define SERIAL_VELOCIDAD  9600

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

#define CANTIDAD_PIXELS   8
#define MAX_BRILLO_PIXEL  255
#define MAX_INTENSIDAD    40.0


// Variables globales
String comandoRecibido[4];
int  comando_pasos     = 0;  // MOVER #1: Cuantos pasos se girará el motor
int  comando_direccion = 0;  // MOVER #2: Si el valor == 0, gira en un sentido, sino en sentido opuesto
int  comando_velocidad = 0;  // MOVER #3: Cantidad de milisegundos a esperar entre paso y paso
int  comando_leds      = -1;  // LEDS  #1: Intensidad del led ("0" significa apagado)

int   motor_demora     = 0;
float motor_posicion   = 0;

Adafruit_NeoPixel strip(8, PIN_PIXEL_LEDS, NEO_GRB + NEO_KHZ800);


/**
 * setup
 * Inicialización del programa. Se definen los pines de Arduino
 * a utilizar, se incializa la comunicación por el puerto serial
 * y la tira de pixel leds.
 */
void setup() {
  pinMode(PIN_PASO_MOTOR, OUTPUT);
  pinMode(PIN_DIR_MOTOR,  OUTPUT);
  Serial.begin(SERIAL_VELOCIDAD);
  strip.begin(); 
  strip.fill(strip.Color(0,0,0)); // Se apagan los leds
  strip.show();
}


/**
 * loop
 * Código del bucle principal de ejecución. 
 * Se lee continuamente el puerto serial para recibir los comandos.
 * Los comandos se analizan e interpretan para determinar si se
 * trata de instrucciones para mover el motor o encender/apagar 
 * la tira de pixel leds. Finalmente, se ejecuta el comando.
 */
void loop() {

  leerComando();

  // VERIFICACIÓN DE COMANDOS PARA "LEDS"
  // Se verifica, en primer lugar, si se trata de un comando
  // para encender o apagar las luces leds.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (comandoRecibido[0].equals(COMANDO_LEDS)) {
    comando_leds = map(comandoRecibido[1].toInt(), 0, 9, 0, 255);
    //enviarFeedbackLeds();
  }

  // VERIFICACIÓN DE COMANDOS PARA "GIRO DEL MOTOR"
  // Se verifica, luego, si se recibió un nuevo comando con la
  // información para hacer mover al motor.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  else if (comandoRecibido[0].equals(COMANDO_MOVER)) {
    comando_pasos     = comandoRecibido[1].toInt();
    comando_direccion = comandoRecibido[2].toInt() > 0 ? HIGH : LOW;
    comando_velocidad = comandoRecibido[3].toInt();
    //enviarFeedbackMotor();

    for (int i = 0; i < comando_pasos; i++) {
      motor_posicion += (comando_direccion == HIGH ? ANGULO_PASO_MOTOR : -ANGULO_PASO_MOTOR);
      // Se chequean los topes para no hacer girar la cabeza más de 180 grados
      if (motor_posicion > MAX_ANGULO_MOTOR) {
        motor_posicion = MAX_ANGULO_MOTOR;
        comando_pasos = 0;
        break;
      }
      else if (motor_posicion < MIN_ANGULO_MOTOR) {
        motor_posicion = MIN_ANGULO_MOTOR;
        comando_pasos = 0;
        break;
      }
      // Acá, efectivamente, es donde se mueve el motor PAP
      else {
        digitalWrite(PIN_DIR_MOTOR,  comando_direccion); 
        digitalWrite(PIN_PASO_MOTOR, HIGH);
        delay(ESPERA_CICLO / 2);
        digitalWrite(PIN_PASO_MOTOR, LOW);
        delay(ESPERA_CICLO / 2);
      }
    }
  }

  // VERIFICACIÓN DE COMANDOS PARA "REINICIO"
  // Por último, se verifica si se trata de un comando
  // para reestablecer la posición inicial del motor
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  else if (comandoRecibido[0].equals(COMANDO_REINICIAR)) {
    motor_posicion = 0;
  }


  // ACTIVACIÓN DE LA TIRA DE LEDS
  // En este punto simplemente se encienden (o apagan) los píxeles 
  // de la tira led, independientemente de si llegó o no un comando
  // con la información RGB (si no llegó, se mantiene el último).
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  if (comando_leds >= 0) {
    int intensidad = comando_leds * MAX_INTENSIDAD / MAX_BRILLO_PIXEL;
    strip.fill(strip.Color(intensidad, intensidad, intensidad));
    comando_leds = -1;
    delay(MIN_ESPERA_CICLO);
  }
  strip.show();
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
  Serial.print(motor_posicion);
  Serial.print(" ");
  Serial.print(comando_pasos);
  Serial.print(" ");
  Serial.println(comando_direccion);
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
