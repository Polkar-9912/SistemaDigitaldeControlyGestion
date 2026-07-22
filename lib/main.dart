import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_layout.dart';

// El main debe ser asíncrono para esperar a que Supabase se conecte
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase. Reemplaza con tus credenciales reales.
  await Supabase.initialize(
    url: 'https://avzprrexpamgujctredm.supabase.co',
    anonKey: 'sb_publishable_kbD3h45PnhWse9k0xime8w_qmyfub_n',
  );

  runApp(const PetroControlApp());
}

class PetroControlApp extends StatelessWidget {
  const PetroControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetroControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Paleta de colores industriales que definimos en los prototipos
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF1F2937),
      ),
      home: const MainLayout(),
    );
  }
}
