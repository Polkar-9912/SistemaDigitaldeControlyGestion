import 'package:flutter/material.dart';
import '../models/surtidor_model.dart';

class SurtidorCard extends StatelessWidget {
  final SurtidorModel surtidor;

  const SurtidorCard({super.key, required this.surtidor});

  @override
  Widget build(BuildContext context) {
    // 1. Cálculo de barra: Nivel Actual / Capacidad Máxima
    double porcentaje = surtidor.nivelActual / surtidor.capacidadMaxima;

    // 2. Lógica del LED (Verde, Amarillo, Rojo)
    Color ledColor;
    String mensajeEstado;
    bool parpadeo = false; // Bandera visual para el sombreado

    if (porcentaje <= 0.05) {
      ledColor = Colors.redAccent;
      mensajeEstado = 'Crítico';
      parpadeo = true;
    } else if (porcentaje <= 0.20) {
      ledColor = Colors.amber;
      mensajeEstado = 'Bajo';
    } else {
      ledColor = Colors.green;
      mensajeEstado = 'Óptimo';
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cabecera: Identificador del Surtidor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  surtidor.identificador,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(porcentaje * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ledColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de Progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                color: ledColor,
              ),
            ),
            const SizedBox(height: 16),

            // Pie de tarjeta: Datos y LED
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${surtidor.nivelActual} / ${surtidor.capacidadMaxima} Lts',
                  style: const TextStyle(color: Colors.black54),
                ),
                // Indicador LED
                Row(
                  children: [
                    Text(
                      mensajeEstado,
                      style: TextStyle(
                        color: ledColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ledColor,
                        boxShadow: parpadeo
                            ? [
                                BoxShadow(
                                  color: ledColor.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
