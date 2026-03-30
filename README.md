# 🐄 SNIG Connect (FormatearCaravana)

**Solución integral multiplataforma para la gestión, validación y formateo de lecturas de caravanas electrónicas (EID) enfocada en el Sistema Nacional de Información Ganadera (SNIG - Uruguay).**

Este proyecto nació originalmente como un script de Python para formatear lecturas, pero ha evolucionado hacia una **Aplicación Flutter completa (Android / iOS / Web / Desktop)** diseñada específicamente para el trabajo de campo (mangas y tubos).

---

## 📱 Propuesta de Valor

Los lectores RFID (ej. Tru-Test XRS-2) generan archivos que las aplicaciones por defecto exportan en formatos no compatibles directamente con las plataformas oficiales. **SNIG Connect** elimina la carga manual y la manipulación de Excel, permitiendo al operario transformar, validar y comparar lecturas en su celular, **100% offline**, garantizando que la información esté lista para subir al portal oficial sin errores.

## ✨ Funcionalidades Principales

### 📥 Carga y Extracción Inteligente
* **Importación CSV:** Soporte directo para archivos generados por balanzas y lectores (Tru-Test Data Link).
* **Procesador "Texto Sucio" (WhatsApp):** Algoritmo inteligente que extrae números de caravana desde mensajes de texto pegados, ignorando letras, DICOSEs y guiones.
* **Ingreso Manual Optimizado:** Autocompletado inteligente. Si el usuario digita el número visual (ej. `12345`), el sistema lo transforma al estándar ISO de 15 dígitos uruguayo (`858000000001234`).

### 🔍 Simulación y Validación (SNIG)
* **Comparador de Simulador:** Carga un PDF o TXT oficial del SNIG y comparalo en tiempo real con la lectura actual. La interfaz marcará visualmente los animales **OK (Verde)** y los **Faltantes (Rojo)**.
* **Validación Estricta:** Motor de validación que asegura la integridad de la trama ISO (Exactamente 15 dígitos, prefijo `858`, solo valores numéricos).

### 🛠 Edición y Gestión de Lote
* **Edición Masiva:** Menú lateral para cambiar rápidamente la GIA (Guía), Fecha y Hora de todo un lote de animales seleccionado.
* **Edición Individual:** Pop-up ágil para modificar datos específicos de un animal directamente desde la lista.
* **Horas Correlativas:** Al procesar textos masivos, el sistema asigna horas de lectura secuenciales con intervalos aleatorios realistas (simulando el paso por el tubo).

### 📤 Exportación
* Exportación directa al formato de trama oficial `.txt` (`[|A000...|]`).

---

## 🏗 Arquitectura y Tecnologías

La aplicación está construida utilizando **Flutter** y **Dart**, siguiendo principios de código limpio y arquitectura escalable:

* **Separación de Responsabilidades (UI vs Lógica):** Uso estricto de `StatelessWidget` para la interfaz visual y clases `ChangeNotifier` (Handlers) para la lógica de negocio.
* **State Management:** Implementación del patrón Observer mediante `Provider`.
* **Multiplataforma:** Lógica condicional (`kIsWeb`) para manejar el procesamiento de archivos nativo (Path/Streams) en móviles/escritorio, y lectura en memoria (Bytes) en navegadores web.

---

## 🚀 Instalación y Uso (Desarrolladores)

### Requisitos Previos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22 o superior).
* Android Studio (para compilar en Android).
* Visual Studio 2022 con C++ (para compilar el ejecutable de Windows).

### Clonar y Ejecutar

1. Clona el repositorio:
   ```bash
   git clone https://github.com/AryGimenez/FormatearCaravana.git
   cd FormatearCaravana/fonten_flutter