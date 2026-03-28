import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/payment_provider.dart';
import '../widgets/payment_method_icon.dart';
import '../widgets/payment_status_badge.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  String? _metodoSeleccionado;
  String? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().listPayments();
    });
  }

  Future<void> _aplicarFiltros() {
    return context.read<PaymentProvider>().listPayments(
          method: _metodoSeleccionado,
          status: _estadoSeleccionado,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy HH:mm');

    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Pagos registrados',
              style: TextStyle(
                color: Color(0xFF4B2A18),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _metodoSeleccionado,
                        decoration: const InputDecoration(labelText: 'Metodo'),
                        items: const [
                          DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                          DropdownMenuItem<String?>(
                            value: 'transferencia',
                            child: Text('Transferencia'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'efectivo',
                            child: Text('Efectivo'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _metodoSeleccionado = value);
                          _aplicarFiltros();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _estadoSeleccionado,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: const [
                          DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                          DropdownMenuItem<String?>(
                            value: 'pendiente',
                            child: Text('Pendiente'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'completado',
                            child: Text('Completado'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'cancelado',
                            child: Text('Cancelado'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _estadoSeleccionado = value);
                          _aplicarFiltros();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading && provider.paymentList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _aplicarFiltros,
                        child: provider.paymentList.isEmpty
                            ? ListView(
                                padding: const EdgeInsets.all(24),
                                children: const [
                                  _EstadoVacio(),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                itemCount: provider.paymentList.length,
                                separatorBuilder: (contexto, indice) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final pago = provider.paymentList[index];
                                  final fecha = pago.createdAt ??
                                      pago.transferDate ??
                                      pago.updatedAt;

                                  return InkWell(
                                    onTap: () {
                                      context.push('/payments/confirm/${pago.id}');
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Ink(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: const Color(0xFFF0DDCC)),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1E5),
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: Center(
                                              child: PaymentMethodIcon(
                                                method: pago.paymentMethod,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pago.paymentMethod.etiqueta,
                                                  style: const TextStyle(
                                                    color: Color(0xFF4B2A18),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Monto: \$${pago.amount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF8C5A3C),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  fecha == null
                                                      ? 'Sin fecha disponible'
                                                      : formato.format(fecha),
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
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0DDCC)),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 46, color: Color(0xFFC63D2F)),
          SizedBox(height: 12),
          Text(
            'No hay pagos para los filtros seleccionados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C5A3C),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

