import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _litrosController = TextEditingController();

  bool _isLoading = false;

  // Listas para llenar los Dropdowns
  List<dynamic> _surtidores = [];
  List<dynamic> _metodosPago = [];

  // Variables de selección
  int? _selectedSurtidorId;
  int? _selectedMetodoPagoId;
  double _precioActualSeleccionado = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  // Obtenemos los surtidores (junto con su precio) y los métodos de pago
  Future<void> _cargarCatalogos() async {
    try {
      // Hacemos un JOIN implícito en Supabase para traer el precio del combustible
      final surtidoresData = await Supabase.instance.client
          .from('surtidores')
          .select('id, identificador, tipos_combustible(precio_actual)');

      final metodosData = await Supabase.instance.client
          .from('metodos_pago')
          .select('id, descripcion');

      setState(() {
        _surtidores = surtidoresData;
        _metodosPago = metodosData;
      });
    } catch (e) {
      _mostrarMensaje('Error al cargar catálogos: $e', esError: true);
    }
  }

  // La función principal transaccional
  Future<void> _registrarVenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double litros = double.parse(_litrosController.text);
      final double subtotal = litros * _precioActualSeleccionado;

      // 1. INSERT en Cabecera (ventas)
      // Usamos el turno_id = 2 por defecto (el que creamos abierto en el script SQL)
      // Usamos .select().single() para que Supabase nos devuelva el ID autogenerado
      final nuevaVenta = await Supabase.instance.client
          .from('ventas')
          .insert({
            'turno_id': 2,
            'metodo_pago_id': _selectedMetodoPagoId,
            'total_pagado': subtotal,
          })
          .select()
          .single();

      // 2. INSERT en Detalle (ventas_detalle)
      await Supabase.instance.client.from('ventas_detalle').insert({
        'venta_id': nuevaVenta['id'],
        'surtidor_id': _selectedSurtidorId,
        'litros_despachados': litros,
        'precio_unitario': _precioActualSeleccionado,
        'subtotal': subtotal,
      });

      // ¡Aquí termina Flutter! Los triggers de SQL descontarán el inventario
      // y generarán el Log si el nivel cae por debajo del umbral.

      _mostrarMensaje('✅ Venta registrada con éxito. Inventario actualizado.');
      _limpiarFormulario();
    } catch (e) {
      _mostrarMensaje('Error al registrar la venta: $e', esError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _litrosController.clear();
    setState(() {
      _selectedSurtidorId = null;
      _selectedMetodoPagoId = null;
      _precioActualSeleccionado = 0.0;
    });
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Venta'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_gas_station,
                        size: 64,
                        color: Color(0xFF1F2937),
                      ),
                      const SizedBox(height: 24),

                      // Dropdown de Surtidor
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Seleccionar Surtidor',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSurtidorId,
                        items: _surtidores.map((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'],
                            child: Text(s['identificador']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSurtidorId = value;
                            // Obtenemos el precio del JSON anidado
                            final surtidor = _surtidores.firstWhere(
                              (s) => s['id'] == value,
                            );
                            _precioActualSeleccionado =
                                (surtidor['tipos_combustible']['precio_actual']
                                        as num)
                                    .toDouble();
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Seleccione un surtidor' : null,
                      ),
                      const SizedBox(height: 16),

                      // Input de Litros
                      TextFormField(
                        controller: _litrosController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad (Litros)',
                          border: OutlineInputBorder(),
                          suffixText: 'Lts',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Ingrese los litros';
                          if (double.tryParse(value) == null)
                            return 'Ingrese un número válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de Método de Pago
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Método de Pago',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMetodoPagoId,
                        items: _metodosPago.map((m) {
                          return DropdownMenuItem<int>(
                            value: m['id'],
                            child: Text(m['descripcion']),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedMetodoPagoId = value),
                        validator: (value) => value == null
                            ? 'Seleccione un método de pago'
                            : null,
                      ),
                      const SizedBox(height: 32),

                      // Botón de Enviar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF10B981,
                            ), // Verde éxito
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading ? null : _registrarVenta,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'CONFIRMAR DESPACHO',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
