import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/payment_model.dart';
import '../providers/payment_provider.dart';
import '../widgets/loading_button.dart';

class CashPaymentScreen extends StatefulWidget {
  const CashPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  final int orderId;
  final double amount;

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoRecibidoController = TextEditingController();
  final _confirmadoPorController = TextEditingController();

  double get _montoRecibido =>
      double.tryParse(_montoRecibidoController.text.replaceAll(',', '.')) ?? 0;

  double get _cambio => _montoRecibido - widget.amount;

  @override
  void initState() {
    super.initState();
    _montoRecibidoController.addListener(_refrescar);
  }

  @override
  void dispose() {
    _montoRecibidoController.removeListener(_refrescar);
    _montoRecibidoController.dispose();
    _confirmadoPorController.dispose();
    super.dispose();
  }

  void _refrescar() {
    setState(() {});
  }

  Future<void> _registrarPago() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<PaymentProvider>();
    final pago = await provider.createCashPayment(
      CashPaymentRequest(
        order: widget.orderId,
        amount: widget.amount,
        cashReceived: _montoRecibido,
        confirmedBy: _confirmadoPorController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    final mensaje = pago != null
        ? 'Pago en efectivo registrado correctamente.'
        : provider.errorMessage ?? 'No se pudo registrar el pago.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));

    if (pago != null) {
      context.go('/payments/confirm/${pago.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Pago en efectivo',
              style: TextStyle(
                color: Color(0xFF4B2A18),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CajaMonto(
                    titulo: 'Monto total a pagar',
                    valor: widget.amount,
                    icono: Icons.request_quote_outlined,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _montoRecibidoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto recibido',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (value) {
                      final monto = double.tryParse((value ?? '').replaceAll(',', '.'));
                      if (monto == null) {
                        return 'Ingresa un monto valido.';
                      }
                      if (monto < widget.amount) {
                        return 'El monto recibido debe ser mayor o igual al total.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _CajaMonto(
                    titulo: 'Cambio calculado',
                    valor: _cambio < 0 ? 0 : _cambio,
                    icono: Icons.change_circle_outlined,
                    destacado: _cambio >= 0,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmadoPorController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmado por',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa quien confirma el pago.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    texto: 'Registrar Pago en Efectivo',
                    icono: Icons.payments_rounded,
                    isLoading: provider.isLoading,
                    onPressed: _registrarPago,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CajaMonto extends StatelessWidget {
  const _CajaMonto({
    required this.titulo,
    required this.valor,
    required this.icono,
    this.destacado = false,
  });

  final String titulo;
  final double valor;
  final IconData icono;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: destacado ? const Color(0xFFE9F5E8) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDCC)),
      ),
      child: Row(
        children: [
          Icon(icono, color: const Color(0xFFC63D2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF8C5A3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${valor.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF4B2A18),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
