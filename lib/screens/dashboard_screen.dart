import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/surtidor_model.dart';
import '../widgets/surtidor_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. Condición: Hacer un SELECT a la tabla surtidores (Solo lectura)
  Future<List<SurtidorModel>> _fetchSurtidores() async {
    final response = await Supabase.instance.client
        .from('surtidores')
        .select()
        .order('id', ascending: true);

    return response.map((data) => SurtidorModel.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⛽ PetroControl - Monitoreo en Vivo'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('Actualizar Niveles'),
        onPressed: () {
          // Al llamar a setState, el FutureBuilder se vuelve a ejecutar y trae los datos frescos
          setState(() {});
        },
      ),

      body: FutureBuilder<List<SurtidorModel>>(
        future: _fetchSurtidores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay surtidores registrados.'));
          }

          final surtidores = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              // Layout adaptable para que parezca un Dashboard industrial
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: surtidores.length,
              itemBuilder: (context, index) {
                return SurtidorCard(surtidor: surtidores[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
