import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/log_model.dart';
import 'package:intl/intl.dart'; // Para formatear fechas y monedas

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  // Función 1: Sumarizar las ventas del día
  Future<double> _fetchTotalVentasDia() async {
    final now = DateTime.now();
    final inicioDelDia = DateTime(now.year, now.month, now.day);

    final response = await Supabase.instance.client
        .from('ventas')
        .select('total_pagado')
        // Filtramos donde la fecha sea mayor o igual a las 00:00 de hoy
        .gte('fecha_hora', inicioDelDia.toIso8601String());

    double total = 0.0;
    for (var fila in response) {
      total += (fila['total_pagado'] as num).toDouble();
    }
    return total;
  }

  // Función 2: Obtener los logs ordenados por el más reciente
  Future<List<LogModel>> _fetchLogs() async {
    final response = await Supabase.instance.client
        .from('logs')
        .select()
        .order('fecha_hora', ascending: false); // DESC en SQL

    return response.map((data) => LogModel.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Auditoría'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Panel Superior: Resumen de Ventas
          FutureBuilder<double>(
            future: _fetchTotalVentasDia(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }

              final total = snapshot.data ?? 0.0;
              // Formateador de moneda
              final formatMoneda = NumberFormat.currency(
                symbol: '\$',
                decimalDigits: 2,
              );

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text(
                      'Ingresos del Día (Turno Actual)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatMoneda.format(total),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1, thickness: 1),

          // 2. Título de la lista de Logs
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: const Color(0xFFF3F4F6),
            child: const Text(
              'BITÁCORA DE ALERTAS Y EVENTOS',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),

          // 3. Lista de Logs con formato condicional
          Expanded(
            child: FutureBuilder<List<LogModel>>(
              future: _fetchLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay registros en la bitácora.'),
                  );
                }

                final logs = snapshot.data!;
                final formatFecha = DateFormat('dd/MM/yyyy HH:mm');

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];

                    // Lógica del formato visual condicional
                    Color iconColor;
                    IconData iconData;

                    if (log.nivelCriticidad == 'Critico') {
                      iconColor = Colors.redAccent;
                      iconData = Icons.warning_rounded;
                    } else if (log.nivelCriticidad == 'Advertencia') {
                      iconColor = Colors.amber;
                      iconData = Icons.info_outline;
                    } else {
                      iconColor = Colors.blueGrey;
                      iconData = Icons.check_circle_outline;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.1),
                        child: Icon(iconData, color: iconColor),
                      ),
                      title: Text(
                        log.accion,
                        style: TextStyle(
                          fontWeight: log.nivelCriticidad == 'Critico'
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: log.nivelCriticidad == 'Critico'
                              ? Colors.red.shade900
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        formatFecha.format(log.fechaHora.toLocal()),
                      ),
                      isThreeLine: true,
                      dense: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
