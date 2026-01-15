// fonten_flutter/lib/services/base_service.dart
import 'package:flutter/material.dart';

import '../models/caravana_models.dart';

/// Definimos una excepción personalizada (como en Java)
class CaravanaException implements Exception {
  final String message;
  CaravanaException(this.message);
  @override
  String toString() => "Error de Caravana: $message";
}

/// Excepción personalizada para errores en la importación masiva.
class ImportException implements Exception {
  final String message;
  /// Carabans duplicadas para mandar en la excepcion (El error)
  final List<CaravanaModel> caravanasDuplicadas; // Lista de IDs que ya existían

  ImportException(this.message, {this.caravanasDuplicadas = const []});

  @override
  String toString() => message;
}

abstract class BaseService {
  @protected
  List <CaravanaModel> listCaravanas = [];

  List <CaravanaModel> get getListCaravanas => listCaravanas;

  // Gia Seleccionada para asiganr a las caravanas
  String gia = ""; //<!> Capas esto solo tendria que traerlo de persistencia si cierro el progrma pero no lo tengo claro 

  /// Agrega una [pCaravana] a la colección actual.
  /// 
  /// Si la caravana ya existe (basado en su EID):
  /// * Si [pAgregarSiNoExiste] es true, la agrega igualmente.
  /// * Si [pAgregarSiNoExiste] es false, lanza una [CaravanaException].
  /// 
  /// Nota: El método siempre lanzará la excepción si el EID está duplicado, 
  /// independientemente de si terminó agregando el registro o no.
  void addCaravana(CaravanaModel pCaravana, {bool pAgregarSiNoExiste = false}) {
    
    // Ejemplo: No duplicar caravanas
    bool xExiste = listCaravanas.any((c) => c.caravana == pCaravana.caravana);
    if (!xExiste || pAgregarSiNoExiste)
      listCaravanas.add(pCaravana);
      
    
    if (xExiste) {
      throw CaravanaException("La caravana con EID ${pCaravana.caravana} ya existe.");
    }

    
  }

  /// Elimina una caravana de la lista por su índice.
  void removeCaravana(int index) {
    listCaravanas.removeAt(index);
  }

  /// <!> Este es mi algoritmo abria que probar cual anda 
  void asignarFechaLectura_2(DateTime nuevaFechaInicio) {
  if (listCaravanas.isEmpty) return; // Si la lista está vacía, no hacemos nada
  int index = 0;
  
  DateTime fechaOriginal = nuevaFechaInicio;

  do{
    
    CaravanaModel caravana = listCaravanas[index];
    
    // Si no es el primer elemento y no es el ultimo
    if (index > 0 && index < (listCaravanas.length - 1)){
      Duration diferencia = caravana.hf_lectura.difference(listCaravanas[index + 1].hf_lectura);
      fechaOriginal = fechaOriginal.add(diferencia);
    }

    fechaOriginal = caravana.hf_lectura;
    

    caravana.hf_lectura = fechaOriginal;

    index++;
  }while(index < listCaravanas.length);
}


/// Asigna una fecha de lectura a cada caravana en la lista.
/// 
/// El primer elemento toma la fecha proporcionada directamente,
/// y cada elemento subsiguiente se ajusta según la diferencia
/// con el elemento anterior.
void asignarFechaLectura(DateTime nuevaFechaInicio) {
  if (listCaravanas.isEmpty) return;

  // 1. La primera vaca toma la nueva fecha directamente
  DateTime horaAnteriorOriginal = listCaravanas.first.hf_lectura;
  listCaravanas.first.hf_lectura = nuevaFechaInicio;

  // 2. Empezamos desde la segunda vaca (índice 1)
  int index = 1;

  int cantidadElementos = listCaravanas.length;

  if (cantidadElementos < 2) return;
  
  while (index < cantidadElementos) {
    CaravanaModel vacaActual = listCaravanas[index];

    // 3. Calculamos la diferencia entre la vaca actual y la ANTERIOR (usando la hora original)
    Duration diferencia = vacaActual.hf_lectura.difference(horaAnteriorOriginal);

    // 4. Guardamos la hora original de esta vaca ANTES de cambiarla 
    // para que sirva de referencia a la que viene después
    horaAnteriorOriginal = vacaActual.hf_lectura;

    // 5. La nueva hora de esta vaca es: Hora de la vaca anterior (ya cambiada) + su diferencia original
    vacaActual.hf_lectura = listCaravanas[index - 1].hf_lectura.add(diferencia);

    index++;
  }
  
}

  /// Actualiza el número de GIA únicamente en las caravanas marcadas.
  /// 
  /// Recorre la lista completa y asigna el valor [gia] a cada elemento 
  /// cuya propiedad `seleccionada` sea verdadera. Las caravanas no 
  /// seleccionadas permanecen con su GIA original.
  void asignarGia(String gia){ 
    for (var xCaravana in listCaravanas) {
      if(xCaravana.seleccionada){
        xCaravana.gia = gia;
      }
    } // Fin del for 
  }

  /// Elimina todos los elementos de la lista de caravanas actual.
  /// 
  /// Utilice este método para reiniciar el proceso de carga o 
  /// limpiar la memoria antes de una nueva importación.
  void clearCaravanas() {
    listCaravanas.clear();
  }


}