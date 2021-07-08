Descripción de puertos / memoria:
P2: bus de datos de LCD
P1.4: RS de LCD
P1.5: E de LCD
P1.3 - P1.0: D - A de MM74C922 (dato de entrada)
P3.1: PUERTO SERIAL TXD
P3.2: lectura de matriz (INT0)
P3.3: ASCII mode (INT1)

TIMER 1 (de 100us)
TIMER 0 (9600 baudios)

R7: cantidad de veces a repetir el timer 1.
R6: cantidad de caracteres impresos en la pantalla LCD.
R5: caracteres almacenados (incrementar despues de lectura)
R0: dirección donde serán guardados los valores de conversión
R4: Datos enviados
R3 - R1: libre



Eduardo:
Para el teclado matricial, el funcionamiento es sencillo:
El 74c922 enviará al PIN P3.2 (INT0) un pulso en bajo cuando haya un
dato. Lo que debe de hacer el micro en esa interrupción será leer
del pin P1.3 - p1.0 el dato que mande, y convertirlo al valor que 
representa nuestro teclado matricial. Puedes convertir el valor de 
dos maneras: Haciendo una estructura if else, o guardando en RAM
La conversión y con un @R0 (siendo A el valor del 922) apuntar
al valor convertido. Para demostrar este funcionamiento, debes
imprimir el valor en la LCD.
Una vez terminado este proceso, deberás guardar el valor nuevo
en otra localización de RAM (Que luego leerá el puerto serial).
Para esto, puedes utilizar el DPTR (Guardando el valor de las dir.
en DPH y DPL, y solo sumando ese valor), para finalmente guardar
el valor de datos en un registro (Definido arriba).

Tamayo:
Para el puerto serial, debes configurar dependiendo del HC05. El
dato a mandar estará en una dirección de memoria, que podrás acceder
con el DPTR. En un registro (definido arriba) tendrás la cantidad
de caracteres a mandar. Deberán ser almacenado en SBUF y ser enviados
según las caracteristicas del HC05. Si necesitas un puerto extra,
favor de avisarme para no disponer de el. Deberás usar el TIMER1
para el Baud Rate.

No duden en mandarme mensaje o una llamda si tienen dudas, y manden
mensaje cuando vayan a pullear. Deberá estar probada su parte para
que yo acepte el pull.