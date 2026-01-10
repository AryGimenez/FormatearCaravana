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
  final List<String> eidsDuplicados; // Lista de IDs que ya existían

  ImportException(this.message, {this.eidsDuplicados = const []});

  @override
  String toString() => message;
}

abstract class BaseService {
  @protected
  List <CaravanaModel> listCaravanas = [];

  List <CaravanaModel> get caravanas => listCaravanas;

  /// Método concreto (con lógica) que pueden usar todos los hijos
  void addCaravana(CaravanaModel nueva) {
    // Validaciones (Condiciones que mencionabas)
    if (nueva.eid.isEmpty) {
      throw CaravanaException("El EID no puede estar vacío.");
    }
    
    // Ejemplo: No duplicar caravanas
    bool existe = listCaravanas.any((c) => c.eid == nueva.eid);
    if (existe) {
      throw CaravanaException("La caravana con EID ${nueva.eid} ya existe.");
    }

    listCaravanas.add(nueva);
  }

  void removeCaravana(int index) {
    listCaravanas.removeAt(index);
  }

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
  

  void asignarGia(String gia){ 
    listCaravanas.forEach((element) {
      if(element.seleccionada){
        element.gia = gia;
      }
    });
  }

  void clearCaravanas() {
    listCaravanas.clear();
  }


}