import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/payment_model.dart';
import '../providers/payment_provider.dart';
import '../widgets/loading_button.dart';
import '../widgets/payment_method_icon.dart';
import '../widgets/payment_status_badge.dart';

class PaymentConfirmScreen extends StatefulWidget {
  const PaymentConfirmScreen({
    super.key,
    required this.paymentId,
  });

  final int paymentId;

  @override
  State<PaymentConfirmScreen> createState() => _PaymentConfirmScreenState();
}

class _PaymentConfirmScreenState extends State<PaymentConfirmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().getPayment(widget.paymentId);
    });
  }

  Future<void> _confirmarPago() async {
    final provider = context.read<PaymentProvider>();
    final pago = await provider.confirmPayment(widget.paymentId);

    if (!mounted) {
      return;
    }

    final mensaje = pago != null
        ? 'Pago confirmado correctamente.'
        : provider.errorMessage ?? 'No se pudo confirmar el pago.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final pago = provider.currentPayment;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Confirmar pago',
              style: TextStyle(
                color: Color(0xFF4B2A18),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: provider.isLoading && pago == null
              ? const Center(child: CircularProgressIndicator())
              : pago == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          provider.errorMessage ?? 'No se pudo cargar el pago.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFFF0DDCC)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1E5),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: PaymentMethodIcon(
                                          method: pago.paymentMethod,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pago #${pago.id}',
                                            style: const TextStyle(
                                              color: Color(0xFF4B2A18),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            pago.paymentMethod.etiqueta,
                                            style: const TextStyle(
                                              color: Color(0xFF8C5A3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PaymentStatusBadge(status: pago.status),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _DatoPago(label: 'Pedido', value: '#${pago.order}'),
                                _DatoPago(
                                  label: 'Monto',
                                  value: '\$${pago.amount.toStringAsFixed(2)}',
                                ),
                                if (pago.transactionReference != null &&
                                    pago.transactionReference!.isNotEmpty)
                                  _DatoPago(
                                    label: 'Referencia',
                                    value: pago.transactionReference!,
                                  ),
                                if (pago.transferReceipt != null &&
                                    pago.transferReceipt!.isNotEmpty)
                                  const _DatoPago(
                                    label: 'Comprobante',
                                    value: 'Archivo adjunto',
                                  ),
                                if (pago.changeGiven != null)
                                  _DatoPago(
                                    label: 'Cambio',
                                    value: '\$${pago.changeGiven!.toStringAsFixed(2)}',
                                  ),
                                if (pago.transferDate != null)
                                  _DatoPago(
                                    label: 'Fecha transferencia',
                                    value: formatoFecha.format(pago.transferDate!),
                                  ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          LoadingButton(
                            texto: pago.status == EstadoPago.completado
                                ? 'Pago ya confirmado'
                                : 'Confirmar Pago',
                            icono: Icons.verified_rounded,
                            isLoading: provider.isLoading,
                            onPressed: pago.status == EstadoPago.completado
                                ? null
                                : _confirmarPago,
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

class _DatoPago extends StatelessWidget {
  const _DatoPago({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8C5A3C),
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF4B2A18),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
