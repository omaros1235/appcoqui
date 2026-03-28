import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/payment_model.dart';
import '../providers/payment_provider.dart';
import '../widgets/loading_button.dart';

class TransferPaymentScreen extends StatefulWidget {
  const TransferPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  final int orderId;
  final double amount;

  @override
  State<TransferPaymentScreen> createState() => _TransferPaymentScreenState();
}

class _TransferPaymentScreenState extends State<TransferPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bancoController = TextEditingController();
  final _cuentaController = TextEditingController();
  final _referenciaController = TextEditingController();
  DateTime? _fechaTransferencia;

  @override
  void dispose() {
    _bancoController.dispose();
    _cuentaController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaTransferencia ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (seleccionada != null) {
      setState(() {
        _fechaTransferencia = seleccionada;
      });
    }
  }

  Future<void> _registrarTransferencia() async {
    if (!_formKey.currentState!.validate() || _fechaTransferencia == null) {
      if (_fechaTransferencia == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la fecha de transferencia.')),
        );
      }
      return;
    }

    final provider = context.read<PaymentProvider>();
    final pago = await provider.createTransferPayment(
      TransferPaymentRequest(
        order: widget.orderId,
        amount: widget.amount,
        bankName: _bancoController.text.trim(),
        accountNumber: _cuentaController.text.trim(),
        transactionReference: _referenciaController.text.trim(),
        transferDate: _fechaTransferencia!,
      ),
    );

    if (!mounted) {
      return;
    }

    final mensaje = pago != null
        ? 'Transferencia registrada correctamente.'
        : provider.errorMessage ?? 'No se pudo registrar la transferencia.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));

    if (pago != null) {
      context.go('/payments/confirm/${pago.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('yyyy-MM-dd');

    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Pago por transferencia',
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
                  _ResumenPago(orderId: widget.orderId, amount: widget.amount),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _bancoController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del banco',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                    validator: _validarRequerido,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cuentaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Numero de cuenta',
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el numero de cuenta.';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                        return 'Solo se permiten numeros.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _referenciaController,
                    decoration: const InputDecoration(
                      labelText: 'Referencia o comprobante',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    validator: _validarRequerido,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _seleccionarFecha,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de transferencia',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _fechaTransferencia == null
                            ? 'Seleccionar fecha'
                            : formatoFecha.format(_fechaTransferencia!),
                        style: TextStyle(
                          color: _fechaTransferencia == null
                              ? Colors.brown.shade400
                              : const Color(0xFF4B2A18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    texto: 'Registrar Transferencia',
                    icono: Icons.send_rounded,
                    isLoading: provider.isLoading,
                    onPressed: _registrarTransferencia,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }
}

class _ResumenPago extends StatelessWidget {
  const _ResumenPago({
    required this.orderId,
    required this.amount,
  });

  final int orderId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDCC)),
      ),
      child: Text(
        'Pedido #$orderId\nMonto a registrar: \$${amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Color(0xFF4B2A18),
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}
