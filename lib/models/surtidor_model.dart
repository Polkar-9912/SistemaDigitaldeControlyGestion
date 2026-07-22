class SurtidorModel {
  final int id;
  final String identificador;
  final double capacidadMaxima;
  final double nivelActual;

  SurtidorModel({
    required this.id,
    required this.identificador,
    required this.capacidadMaxima,
    required this.nivelActual,
  });

  // Constructor que traduce el JSON de Supabase a Dart
  factory SurtidorModel.fromJson(Map<String, dynamic> json) {
    return SurtidorModel(
      id: json['id'],
      identificador: json['identificador'],
      // En Dart, es buena práctica forzar el casteo a double por seguridad
      capacidadMaxima: (json['capacidad_maxima'] as num).toDouble(),
      nivelActual: (json['nivel_actual'] as num).toDouble(),
    );
  }
}
