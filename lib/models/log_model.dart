class LogModel {
  final int id;
  final String accion;
  final String nivelCriticidad;
  final DateTime fechaHora;

  LogModel({
    required this.id,
    required this.accion,
    required this.nivelCriticidad,
    required this.fechaHora,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'],
      accion: json['accion'],
      nivelCriticidad: json['nivel_criticidad'],
      fechaHora: DateTime.parse(json['fecha_hora']),
    );
  }
}
