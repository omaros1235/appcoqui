import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  final int orderId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Seleccionar metodo de pago',
          style: TextStyle(
            color: Color(0xFF4B2A18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFF0DDCC)),
              ),
              child: Text(
                'Pedido #$orderId\nTotal a pagar: \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF4B2A18),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _MetodoCard(
              icono: Icons.account_balance_rounded,
              titulo: 'Transferencia Bancaria',
              descripcion: 'Registra banco, cuenta, referencia y fecha de deposito.',
              color: const Color(0xFFE6F3F8),
              onTap: () {
                context.push('/payments/transfer', extra: {
                  'orderId': orderId,
                  'amount': amount,
                });
              },
            ),
            const SizedBox(height: 16),
            _MetodoCard(
              icono: Icons.payments_rounded,
              titulo: 'Efectivo',
              descripcion: 'Ingresa el monto recibido y calcula el cambio al instante.',
              color: const Color(0xFFE9F5E8),
              onTap: () {
                context.push('/payments/cash', extra: {
                  'orderId': orderId,
                  'amount': amount,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetodoCard extends StatelessWidget {
  const _MetodoCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF0DDCC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icono, size: 34, color: const Color(0xFF4B2A18)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Color(0xFF4B2A18),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Color(0xFF8C5A3C),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF8C5A3C)),
          ],
        ),
      ),
    );
  }
}
