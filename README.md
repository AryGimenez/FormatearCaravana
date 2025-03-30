# Transformador de Cadenas Numéricas para Caravanas

Este proyecto en Python toma una lista de cadenas numéricas (como números de caravanas) y las transforma a un formato específico, añadiendo prefijos, sufijos y otra información relevante.

## Tabla de Contenidos

*   [Introducción](#introducción)
*   [Instalación](#instalación)
*   [Uso](#uso)
*   [Formato de Entrada](#formato-de-entrada)
*   [Formato de Salida](#formato-de-salida)
*   [Ejemplo](#ejemplo)
*   [Contribución](#contribución)
*   [Licencia](#licencia)

## Introducción

Este script de Python fue desarrollado para facilitar la gestión y el procesamiento de números de identificación, específicamente aquellos relacionados con caravanas. Permite convertir una serie de números sin formato a un formato estandarizado que incluye información adicional, lo que facilita su uso en bases de datos, hojas de cálculo u otros sistemas.

## Instalación

1.  Asegúrate de tener Python 3.x instalado en tu sistema.
2.  Clona este repositorio: `git clone https://github.com/<tu-usuario>/<nombre-del-repositorio>.git`
3.  Navega al directorio del proyecto: `cd <nombre-del-repositorio>`

## Uso

Para ejecutar el script, utiliza el siguiente comando:

```bash
python transformador.py <archivo_entrada> <archivo_salida>

```

**<archivo_entrada>:** Archivo de texto plano con la lista de números de caravanas sin formato, uno por línea.
**<archivo_salida>:** Archivo de texto plano donde se guardarán los números transformados.
Formato de Entrada
El archivo de entrada debe contener una lista de números de caravanas, uno por línea. Por ejemplo:

059761617
059761665
059761645
...
Formato de Salida
El archivo de salida contendrá los números transformados, uno por línea, en el siguiente formato:

[|A0000000<numero_caravana>|<fecha>|<hora>|<codigo>|]
<numero_caravana>: Número de caravana con ceros a la izquierda para completar 9 dígitos.
<fecha>: Fecha en formato DDMMYYYY (ejemplo: 14122023).
<hora>: Hora en formato HHMMSS (ejemplo: 121011).
<codigo>: Código alfanumérico (ejemplo: C788853).
Ejemplo
Si el archivo de entrada (entrada.txt) contiene:

059761617
059761665
Y se ejecuta el script con:

Bash

python transformador.py entrada.txt salida.txt
El archivo de salida (salida.txt) contendrá:

[|A000000059761617|14122023|121011|C788853|]
[|A000000059761665|14122023|121011|C788853|]
Contribución
¡Las contribuciones son bienvenidas! Si deseas mejorar este proyecto, por favor, abre un "issue" o envía un "pull request" en GitHub.

Licencia
Este proyecto está bajo la licencia MIT.

Recuerda reemplazar <tu-usuario> y <nombre-del-repositorio> con la información correcta. ¡Espero que esto te sea útil!



## Tambien Esta pensado para tranformar de el formato de caravanas SVG Para el lector trutest https://latam.tru-test.com/

