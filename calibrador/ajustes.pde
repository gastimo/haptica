// 
// MÓDULO "AJUSTES"
// Parámetros globales para la configuración de los restantes
// módulos, por ejemplo, la cámara, los mensajes OSC, la
// mensajería por puesto serial, etc.
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// CONFIGURACIÓN DE LAS DIMENSIONES DE LA VENTANA PRINCIPAL
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
int VENTANA_ANCHO = 800;
int VENTANA_ALTO  = 450;


// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Direcciones IPs de los equipos y de los puertos para el protocolo OSC
final String  IP_MANDANTE        = "192.168.0.9";
final String  IP_CALIBRADOR      = "192.168.0.9";
final String  IP_ORQUESTADOR     = "192.168.0.9";
final int     PUERTO_MANDANTE    = 12000;
final int     PUERTO_CALIBRADOR  = 12011;
final int     PUERTO_ORQUESTADOR = 9000;
final String  DIR_FLUJO_OPTICO   = "/opticalflow";
final String  DIR_CALIBRADOR     = "/calibrador";


// CONFIGURACIÓN LOS COMANDOS DEL CALIBRADOR
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
String CALIBRAR_DIR_IZQ  = "izquierda";
String CALIBRAR_DIR_DER  = "derecha";
String CALIBRAR_POSICION = "calibrar";
String CALIBRAR_REINICIO = "reiniciar";
