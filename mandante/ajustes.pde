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


int MAX_ANGULO_MOTOR  = 90;
int MIN_ANGULO_MOTOR  = -90;


// PARÁMETROS PARA EL CÁLCULO DEL FLUJO OPTICO
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Valores para calcular el "flujo óptico" en la imagen de video capturada.
final float FLUJO_OPTICO_TECHO    = 30;
final int   FLUJO_OPTICO_COLUMNAS = 10;
final int   FLUJO_OPTICO_FILAS    = 10;



// PARÁMETROS PARA LA SERIALIZACIÓN DE MENSAJES
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final int    SERIAL_VELOCIDAD_PUERTO = 115200;
final String SERIAL_PREFIJO_PUERTO   = "/dev/ttyUSB";



// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Direcciones IPs de los equipos y de los puertos para el protocolo OSC
final String  IP_MANDANTE        = "192.168.0.9";
final String  IP_CALIBRADOR      = "192.168.0.9";
final String  IP_CONTROLADOR     = "192.168.0.9";
final int     PUERTO_MANDANTE    = 9000;
final int     PUERTO_CALIBRADOR  = 12011;
final int     PUERTO_CONTROLADOR = 8000;
final String  DIR_FLUJO_OPTICO_DIM = "/opticalflow/matriz";
final String  DIR_FLUJO_OPTICO     = "/opticalflow";
final String  DIR_CALIBRADOR       = "/calibrador";
final String  DIR_CONTROLADOR      = "/controlador";


// CONFIGURACIÓN LOS COMANDOS DEL ROTOR (ENVIADOS A ARDUINO)
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String COMANDO_MOVER     = "M";
final String COMANDO_REINICIAR = "R";


// CONFIGURACIÓN LOS COMANDOS DEL CALIBRADOR
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String CALIBRAR_DIR_IZQ  = "izquierda";
final String CALIBRAR_DIR_DER  = "derecha";
final String CALIBRAR_POSICION = "calibrar";
final String CALIBRAR_REINICIO = "reiniciar";
