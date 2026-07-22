import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'ventas_screen.dart';
import 'reportes_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Lista de las pantallas que ya construiste
  final List<Widget> _screens = [
    // Quitamos el 'const' para forzar que se reconstruyan (y recarguen datos) al cambiar de pestaña
    DashboardScreen(),
    VentasScreen(),
    ReportesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar de Navegación Industrial
          NavigationRail(
            backgroundColor: const Color(0xFF1F2937),
            unselectedIconTheme: const IconThemeData(color: Colors.white54),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex =
                    index; // Cambia la pantalla y fuerza la recarga
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_gas_station),
                label: Text('Despacho'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Auditoría'),
              ),
            ],
          ),

          // Área principal donde se dibuja la pantalla seleccionada
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
