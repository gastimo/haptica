// 
// AJUSTES (CONFIGURACIÓN DE LOS MÓDULOS)
// Parámetros globales para la configuración de los restantes
// módulos, por ejemplo, la cámara, los mensajes OSC, la
// mensajería por puesto serial, etc.
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// CONFIGURACIÓN DE LAS DIMENSIONES DE LA ENTRADA DEL VIDEO (WEBCAM)
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Dimensiones de cada fotograma capturado por la cámara principal
int CAMARA_ANCHO = 640;
int CAMARA_ALTO  = 480;


// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Direcciones IPs y puertos de los equipos para el protocolo OSC
final String  IP_MANDANTE        = "192.168.0.9";
final String  IP_CONTROLADOR     = "192.168.0.9";
final int     PUERTO_MANDANTE    = 9000;   // Donde recibe los mensajes ("escucha")
final int     PUERTO_CONTROLADOR = 8000;   // A donde se envían los mensajes


// PARÁMETROS PARA LA SERIALIZACIÓN DE MENSAJES
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final int    SERIAL_VELOCIDAD_PUERTO = 115200;
final String SERIAL_PUERTO_RASPBERRY = "/dev/ttyACM0";   // Puerto USB Raspberry (azul)
final String SERIAL_PUERTO_UBUNTU    = "/dev/ttyUSB";    // Puerto USB Ubuntu
final String SERIAL_PREFIJO_PUERTO   = SERIAL_PUERTO_RASPBERRY;


// CONFIGURACIÓN DEl CAMPO VISUAL DEL MANDANTE
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Define el rango de ángulos para mover la cabeza (el "cero" es el centro).
int MAX_ANGULO_MOTOR  = 90;
int MIN_ANGULO_MOTOR  = -90;


// PARÁMETROS PARA EL CÁLCULO DEL FLUJO OPTICO
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Valores para calcular el "flujo óptico" en la imagen de video capturada.
final float FLUJO_OPTICO_TECHO    = 30;
final int   FLUJO_OPTICO_COLUMNAS = 10;
final int   FLUJO_OPTICO_FILAS    = 10;


// Direcciones OSC para el intercambio de mensajes
final String  DIR_FLUJO_OPTICO_DIM = "/opticalflow/matriz"; // Envío hacia el  "Controlador"  (sólo 1ra vez)
final String  DIR_FLUJO_OPTICO     = "/opticalflow";        // Envío hacia el  "Controlador"  (de la matriz de FO)
final String  DIR_CONTROLADOR      = "/controlador";        // Recepción desde "Controlador"  (para giro del motor) 
final String  DIR_ENCENDEDOR       = "/encendedor";         // Recepción desde "Controlador"  (para luces LEDS) 
final String  DIR_CONFIGURADOR     = "/configurador";       // Recepción desde "Configurador" (para calibración y leds)


// CONFIGURACIÓN LOS COMANDOS DEL ROTOR (ENVIADOS A ARDUINO)
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String COMANDO_MOVER          = "M";  // Comando para mover el motor un número de pasos
final String COMANDO_REINICIAR      = "R";  // Comando para reiniciar el motor (reestablecer posición cero)
final String COMANDO_LEDS           = "L";  // Comando para controlar el encendido de las luces leds
final int    COMANDO_VELOCIDAD_GIRO = 10;   // Tiempo en milisengudos entre paso y paso del motor


// COMANDOS DEL "CONFIGURADOR" RECIBIDOS POR OSC
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String CALIBRAR_DIR_IZQ  = "izquierda";
final String CALIBRAR_DIR_DER  = "derecha";
final String CALIBRAR_POSICION = "calibrar";
final String CALIBRAR_REINICIO = "reiniciar";
final String CONTROL_LUCES_LED = "leds";


// CÓDIGOS DE "FEEDBACK" RECIBIDOS DESDE ARDUINO POR EL PUERTO SERIAL
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String FEEDBACK_POSICION = "POS=";
final String FEEDBACK_LEDS     = "LED=";
final String FEEDBACK_ERROR    = "ERROR=";
