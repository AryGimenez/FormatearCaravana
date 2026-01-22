# SNIG Formatter Pro: Solución Integral de Trazabilidad Ganadera
Optimización de flujo de datos entre lectores Tru-Test y el Sistema Nacional de Información Ganadera (SNIG - Uruguay).

## Propuesta de Valor (Comercial)
En el trabajo de campo, la eficiencia es dinero. Los lectores Tru-Test (XRS-2/SRS-2) generan archivos que la aplicación Data Link exporta en formatos no compatibles directamente con el SNIG.

**SNIG Formatter Pro** elimina la carga manual de datos. Permite al operador transformar, validar y comparar lecturas directamente en su celular o tablet, 100% offline, garantizando que la información esté lista para subir al portal oficial sin errores de formato.

## Funcionalidades Clave

### 🛠 Procesamiento y Transformación

Conversión Tru-Test a SNIG: Transforma CSVs de Data Link al formato de trama oficial [|A000...|] de forma instantánea.
Procesador de "Texto Sucio": Algoritmo inteligente que extrae números de caravana de mensajes de WhatsApp o notas, ignorando guiones, nombres y texto irrelevante.
Autocompletado Inteligente: Ingreso manual optimizado. El usuario digita los últimos 4 o 5 dígitos y el sistema completa el prefijo país/fabricante (8580000...) automáticamente.


### Validación y Simulación

Comparador de Lecturas (Simulador): Carga un listado (vía PDF y comparalo con la lectura actual. El sistema marcará con un icono rojo aquellas caravanas faltantes o sobrantes.
Validación Estricta ISO: Control de 15 dígitos y prefijo 858 para evitar errores de digitación.
**Filtros Avanzados:** Segmentación por fecha y estado de selección para exportaciones parciales.


### 📱 Experiencia de Usuario (UX) en el Tubo
Sistema Undo (Ctrl+Z): Recuperación instantánea de caravanas borradas o modificadas por error.
Persistencia Total: Los datos se guardan automáticamente en el dispositivo (Móvil/Desktop). Si la app se cierra, el trabajo no se pierde.
Exportación Ágil: Generación de archivos .txt y botón directo para Compartir por WhatsApp a la oficina o al escritorio del SNIG.


### Estrategia Web y Captación de Leads (Demo)
La versión Web funciona como un entorno de demostración y captación de clientes.
Flujo de Acceso (Backend FastAPI):
Registro Obligatorio: Para usar la demo, el usuario ingresa Nombre, Email, WhatsApp y Rubro.
Validación WhatsApp: El backend (FastAPI) envía un código de activación o mensaje de confirmación.
Conversión a Venta: Una vez validado el lead, se habilita la demo web (sin persistencia). El objetivo es ofrecer luego la versión Offline Pro (Instalada) para trabajo real en el campo.

## Arquitectura TécnicaSNIG Formatter Pro: Solución Integral de Trazabilidad Ganadera
Optimización de flujo de datos entre lectores Tru-Test y el Sistema Nacional de Información Ganadera (SNIG - Uruguay).
1. Propuesta de Valor (Comercial)
En el trabajo de campo, la eficiencia es dinero. Los lectores Tru-Test (XRS-2/SRS-2) generan archivos que la aplicación Data Link exporta en formatos no compatibles directamente con el SNIG.
SNIG Formatter Pro elimina la carga manual de datos. Permite al operador transformar, validar y comparar lecturas directamente en su celular o tablet, 100% offline, garantizando que la información esté lista para subir al portal oficial sin errores de formato.
2. Funcionalidades Clave
🛠 Procesamiento y Transformación
Conversión Tru-Test a SNIG: Transforma CSVs de Data Link al formato de trama oficial [|A000...|] de forma instantánea.
Procesador de "Texto Sucio": Algoritmo inteligente que extrae números de caravana de mensajes de WhatsApp o notas, ignorando guiones, nombres y texto irrelevante.
Autocompletado Inteligente: Ingreso manual optimizado. El usuario digita los últimos 4 o 5 dígitos y el sistema completa el prefijo país/fabricante (8580000...) automáticamente.
🔍 Validación y Simulación
Comparador de Lecturas (Simulador): Carga un listado (vía PDF o TXT) y comparalo con la lectura actual. El sistema marcará con un icono rojo aquellas caravanas faltantes o sobrantes.
Validación Estricta ISO: Control de 15 dígitos y prefijo 858 para evitar errores de digitación.
Filtros Avanzados: Segmentación por fecha y estado de selección para exportaciones parciales.
📱 Experiencia de Usuario (UX) en el Tubo
Sistema Undo (Ctrl+Z): Recuperación instantánea de caravanas borradas o modificadas por error.
Persistencia Total: Los datos se guardan automáticamente en el dispositivo (Móvil/Desktop). Si la app se cierra, el trabajo no se pierde.
Exportación Ágil: Generación de archivos .txt y botón directo para Compartir por WhatsApp a la oficina o al escritorio del SNIG.
3. Estrategia Web y Captación de Leads (Demo)
La versión Web funciona como un entorno de demostración y captación de clientes.
Flujo de Acceso (Backend FastAPI):
Registro Obligatorio: Para usar la demo, el usuario ingresa Nombre, Email, WhatsApp y Rubro.
Validación WhatsApp: El backend (FastAPI) envía un código de activación o mensaje de confirmación.
Conversión a Venta: Una vez validado el lead, se habilita la demo web (sin persistencia). El objetivo es ofrecer luego la versión Offline Pro (Instalada) para trabajo real en el campo.
4. Arquitectura Técnica
Frontend: Flutter (Dart) - Multiplataforma (Android, iOS, Web, Linux, Windows).
Backend (Demo): FastAPI (Python) para gestión de usuarios y validación de contactos.
Procesamiento: 100% en el cliente (Dart) para garantizar privacidad y funcionamiento sin internet.
Logs y Monitoreo: Sistema de telemetría integrado para registrar errores de parseo y mejorar el rendimiento del algoritmo de extracción.
5. Guía de Desarrollo (Comandos Rápidos)
Probar en dispositivo físico (Android):
code
Bash
flutter run --release -d <DEVICE_ID>
Probar en navegador (Web Demo):
code
Bash
flutter run -d chrome
Generar APK para distribución (WhatsApp):
code
Bash
flutter build apk --split-per-abi
6. Roadmap / Próximos Pasos

Implementación de sistema de "Deshacer" (Undo) con SnackBar.

Integración de lectura de PDF para el simulador de comparación.

Finalización del módulo de autenticación vía WhatsApp en FastAPI.

Sistema de logs rotativos para diagnóstico offline.
Desarrollado por Ary Gimenez
Soluciones tecnológicas para el sector agropecuario uruguayo.
¿Qué te parece esta redacción?
He incluido todos tus puntos:
La diferencia entre la versión instalada (con persistencia) y la web (demo/captación).
La lógica de autocompletado y el "texto sucio" de WhatsApp.
El comparador con el simulador (marcado en rojo).
El backend con FastAPI para quedarte con los datos de los clientes.
El sistema de logs y el botón de deshacer.

Frontend: Flutter (Dart) - Multiplataforma (Android, iOS, Web, Linux, Windows).
Backend (Demo): FastAPI (Python) para gestión de usuarios y validación de contactos.
Procesamiento: 100% en el cliente (Dart) para garantizar privacidad y funcionamiento sin internet.
Logs y Monitoreo: Sistema de telemetría integrado para registrar errores de parseo y mejorar el rendimiento del algoritmo de extracción.
5. Guía de Desarrollo (Comandos Rápidos)
Probar en dispositivo físico (Android):
code
Bash
flutter run --release -d <DEVICE_ID>
Probar en navegador (Web Demo):
code
Bash
flutter run -d chrome
Generar APK para distribución (WhatsApp):
code
Bash
flutter build apk --split-per-abi
6. Roadmap / Próximos Pasos

Implementación de sistema de "Deshacer" (Undo) con SnackBar.

Integración de lectura de PDF para el simulador de comparación.

Finalización del módulo de autenticación vía WhatsApp en FastAPI.

Sistema de logs rotativos para diagnóstico offline.
Desarrollado por Ary Gimenez
Soluciones tecnológicas para el sector agropecuario uruguayo.
¿Qué te parece esta redacción?
He incluido todos tus puntos:
La diferencia entre la versión instalada (con persistencia) y la web (demo/captación).
La lógica de autocompletado y el "texto sucio" de WhatsApp.
El comparador con el simulador (marcado en rojo).
El backend con FastAPI para quedarte con los datos de los clientes.
El sistema de logs y el botón de deshacer.





--------------------------

























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


# probar en el dispositivo fijo 
flutter run --release -d R83YA0W74KR

# Probar en el navegador
flutter run -d chrome



