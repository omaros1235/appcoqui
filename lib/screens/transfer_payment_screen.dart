import 'package:file_picker/file_picker.dart';
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
  TransferReceiptFile? _comprobante;

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

  Future<void> _seleccionarComprobante() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'pdf', 'webp'],
      withData: true,
    );

    final archivo = resultado?.files.single;
    if (archivo == null) {
      return;
    }

    setState(() {
      _comprobante = TransferReceiptFile(
        name: archivo.name,
        bytes: archivo.bytes,
        path: archivo.path,
      );
    });
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
        transferReceipt: _comprobante,
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
                      labelText: 'Referencia de transferencia',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                    ),
                    validator: _validarRequerido,
                  ),
                  const SizedBox(height: 18),
                  _ComprobanteField(
                    fileName: _comprobante?.name,
                    isLoading: provider.isLoading,
                    onPick: _seleccionarComprobante,
                    onClear: _comprobante == null
                        ? null
                        : () {
                            setState(() {
                              _comprobante = null;
                            });
                          },
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

class _ComprobanteField extends StatelessWidget {
  const _ComprobanteField({
    required this.fileName,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? fileName;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            'Comprobante',
            style: TextStyle(
              color: Color(0xFF7C5C49),
              fontSize: 16,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF8A6A57)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: Color(0xFF5B3A29),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName ?? 'Adjunta PNG, JPG, JPEG, WEBP o PDF',
                      style: TextStyle(
                        color: fileName == null
                            ? const Color(0xFF9B7B68)
                            : const Color(0xFF4B2A18),
                        fontWeight: fileName == null ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : onPick,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(fileName == null ? 'Seleccionar archivo' : 'Cambiar archivo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFA34E41),
                      side: const BorderSide(color: Color(0xFFA34E41)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  if (onClear != null)
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : onClear,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Quitar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA34E41),
                        side: const BorderSide(color: Color(0xFFA34E41)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
