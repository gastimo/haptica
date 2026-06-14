// 
// MÓDULO "AJUSTES"
// Parámetros globales para la configuración de los restantes
// módulos, por ejemplo, la cámara, los mensajes OSC, la
// mensajería por puesto serial, etc.
// 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// CONFIGURACIÓN DE LAS DIMENSIONES DE LA VENTANA PRINCIPAL
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
int VENTANA_ANCHO = 720;
int VENTANA_ALTO  = 400;


// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Direcciones IPs de los equipos y de los puertos para el protocolo OSC
final String  IP_MANDANTE         = "192.168.0.9";
final int     PUERTO_MANDANTE     = 9000;
final int     PUERTO_CONFIGURADOR = 12011;
final String  DIR_CONFIGURADOR    = "/configurador"; // Envío hacia "Mandante" (para calibración y leds)


// COMANDOS DEL "CONFIGURADOR" ENVIADOS POR OSC
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
final String CALIBRAR_DIR_IZQ  = "izquierda";
final String CALIBRAR_DIR_DER  = "derecha";
final String CALIBRAR_POSICION = "calibrar";
final String CALIBRAR_REINICIO = "reiniciar";
final String CONTROL_LUCES_LED = "leds";
