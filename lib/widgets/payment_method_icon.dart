import 'package:flutter/material.dart';

import '../models/payment_model.dart';

class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({
    super.key,
    required this.method,
    this.size = 24,
  });

  final MetodoPago method;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case MetodoPago.transferencia:
        return Icon(
          Icons.account_balance_rounded,
          size: size,
          color: const Color(0xFF0C5A7A),
        );
      case MetodoPago.efectivo:
        return Icon(
          Icons.payments_rounded,
          size: size,
          color: const Color(0xFF2E7D32),
        );
    }
  }
}
