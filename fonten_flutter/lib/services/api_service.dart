// fonten_flutter/lib/services/api_service
import 'package:fonten_flutter/services/base_service.dart';
import 'package:fonten_flutter/services/csv_service.dart';
import 'package:fonten_flutter/services/txt_service.dart';
import 'package:fonten_flutter/models/caravana_models.dart';
import 'package:fonten_flutter/services/pdf-simulador_service.dart';

// class ApiService extends BaseApi with AuthModule, ClientsModule {
class ApiService extends BaseService
    with CsvService, TxtService, PdfSimuladorService {
  /// Instancia estática y privada que almacena la única referencia de la clase.
  ///
  /// Este atributo es el corazón del patrón Singleton, asegurando que
  /// el estado de la API (como los tokens y la URL base) se mantenga
  /// idéntico en toda la ejecución de la aplicación.
  static final ApiService _instance = ApiService._internal();

  /// Constructor de tipo 'factory' que gestiona el acceso a la instancia.
  ///
  /// En lugar de crear un nuevo objeto cada vez que se invoca, este constructor
  /// intercepta la llamada y devuelve la instancia única [_instance].
  /// Esto permite acceder a los servicios de la API desde cualquier parte del
  /// código usando simplemente 'ApiService()'.
  factory ApiService() {
    return _instance;
  }

  /// Constructor privado y nombrado encargado de la inicialización interna.
  ///
  /// Al ser privado, impide la creación de instancias externas accidentales.
  /// Aquí se define la [baseUrl] fija y se dispara la lógica de [_init] para
  /// recuperar datos persistentes (como el token) al momento de arrancar el servicio.
  ApiService._internal() {
    //_cargarDatosEjemplo();
  }

  // Ejemplo de carga inicial (opcional)
  void _cargarDatosEjemplo() {
    listCaravanas = [
      CaravanaModel(
          caravana: "858000051983700",
          hf_lectura: DateTime(2024, 7, 2, 08, 00),
          gia: "C43434",
          esOk: true,
          seleccionada: true),
      CaravanaModel(
          caravana: "858000051983701",
          hf_lectura: DateTime(2024, 7, 2, 08, 01),
          gia: "C43434",
          esOk: true,
          seleccionada: true),
      CaravanaModel(
          caravana: "858000051983702",
          hf_lectura: DateTime(2024, 7, 2, 08, 02),
          gia: "C43434",
          esOk: true,
          seleccionada: true),
      CaravanaModel(
          caravana: "858000051983703",
          hf_lectura: DateTime(2024, 7, 2, 08, 03),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983704",
          hf_lectura: DateTime(2024, 7, 2, 08, 04),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983705",
          hf_lectura: DateTime(2024, 7, 2, 08, 05),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983706",
          hf_lectura: DateTime(2024, 7, 2, 08, 06),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983707",
          hf_lectura: DateTime(2024, 7, 2, 08, 07),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983708",
          hf_lectura: DateTime(2024, 7, 2, 08, 08),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983709",
          hf_lectura: DateTime(2024, 7, 2, 08, 09),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983710",
          hf_lectura: DateTime(2024, 7, 2, 08, 10),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983711",
          hf_lectura: DateTime(2024, 7, 2, 08, 11),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983712",
          hf_lectura: DateTime(2024, 7, 2, 08, 12),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983713",
          hf_lectura: DateTime(2024, 7, 2, 08, 13),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983714",
          hf_lectura: DateTime(2024, 7, 2, 08, 14),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983715",
          hf_lectura: DateTime(2024, 7, 2, 08, 15),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983716",
          hf_lectura: DateTime(2024, 7, 2, 08, 16),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983717",
          hf_lectura: DateTime(2024, 7, 2, 08, 17),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983718",
          hf_lectura: DateTime(2024, 7, 2, 08, 18),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983719",
          hf_lectura: DateTime(2024, 7, 2, 08, 19),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983720",
          hf_lectura: DateTime(2024, 7, 2, 08, 20),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983721",
          hf_lectura: DateTime(2024, 7, 2, 08, 21),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983722",
          hf_lectura: DateTime(2024, 7, 2, 08, 22),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983723",
          hf_lectura: DateTime(2024, 7, 2, 08, 23),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983724",
          hf_lectura: DateTime(2024, 7, 2, 08, 24),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983725",
          hf_lectura: DateTime(2024, 7, 2, 08, 25),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983726",
          hf_lectura: DateTime(2024, 7, 2, 08, 26),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983727",
          hf_lectura: DateTime(2024, 7, 2, 08, 27),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983728",
          hf_lectura: DateTime(2024, 7, 2, 08, 28),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983729",
          hf_lectura: DateTime(2024, 7, 2, 08, 29),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983730",
          hf_lectura: DateTime(2024, 7, 2, 08, 30),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983731",
          hf_lectura: DateTime(2024, 7, 2, 08, 31),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983732",
          hf_lectura: DateTime(2024, 7, 2, 08, 32),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983733",
          hf_lectura: DateTime(2024, 7, 2, 08, 33),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983734",
          hf_lectura: DateTime(2024, 7, 2, 08, 34),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983735",
          hf_lectura: DateTime(2024, 7, 2, 08, 35),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983736",
          hf_lectura: DateTime(2024, 7, 2, 08, 36),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983737",
          hf_lectura: DateTime(2024, 7, 2, 08, 37),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983738",
          hf_lectura: DateTime(2024, 7, 2, 08, 38),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983739",
          hf_lectura: DateTime(2024, 7, 2, 08, 39),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983740",
          hf_lectura: DateTime(2024, 7, 2, 08, 40),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983741",
          hf_lectura: DateTime(2024, 7, 2, 08, 41),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983742",
          hf_lectura: DateTime(2024, 7, 2, 08, 42),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983743",
          hf_lectura: DateTime(2024, 7, 2, 08, 43),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983744",
          hf_lectura: DateTime(2024, 7, 2, 08, 44),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983745",
          hf_lectura: DateTime(2024, 7, 2, 08, 45),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983746",
          hf_lectura: DateTime(2024, 7, 2, 08, 46),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983747",
          hf_lectura: DateTime(2024, 7, 2, 08, 47),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983748",
          hf_lectura: DateTime(2024, 7, 2, 08, 48),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983749",
          hf_lectura: DateTime(2024, 7, 2, 08, 49),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983750",
          hf_lectura: DateTime(2024, 7, 2, 08, 50),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983751",
          hf_lectura: DateTime(2024, 7, 2, 08, 51),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983752",
          hf_lectura: DateTime(2024, 7, 2, 08, 52),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983753",
          hf_lectura: DateTime(2024, 7, 2, 08, 53),
          gia: "C43434",
          esOk: false,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983754",
          hf_lectura: DateTime(2024, 7, 2, 08, 54),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983755",
          hf_lectura: DateTime(2024, 7, 2, 08, 55),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983756",
          hf_lectura: DateTime(2024, 7, 2, 08, 56),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983757",
          hf_lectura: DateTime(2024, 7, 2, 08, 57),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983758",
          hf_lectura: DateTime(2024, 7, 2, 08, 58),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
      CaravanaModel(
          caravana: "858000051983759",
          hf_lectura: DateTime(2024, 7, 2, 08, 59),
          gia: "C43434",
          esOk: true,
          seleccionada: false),
    ];
  }
}
