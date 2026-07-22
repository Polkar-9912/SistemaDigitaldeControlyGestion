import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos el archivo .env
  await dotenv.load(fileName: ".env");

  // Leemos las variables usando dotenv.env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
