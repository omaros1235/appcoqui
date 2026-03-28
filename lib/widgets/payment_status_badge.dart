import 'package:flutter/material.dart';

import '../models/payment_model.dart';

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  final EstadoPago status;

  @override
  Widget build(BuildContext context) {
    final colores = _resolverColores(status);

    return Chip(
      label: Text(
        status.etiqueta,
        style: TextStyle(
          color: colores.texto,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: colores.fondo,
      side: BorderSide(color: colores.borde),
      visualDensity: VisualDensity.compact,
    );
  }

  _ColoresEstado _resolverColores(EstadoPago status) {
    switch (status) {
      case EstadoPago.pendiente:
        return const _ColoresEstado(
          fondo: Color(0xFFFFF3CD),
          texto: Color(0xFF946200),
          borde: Color(0xFFFFE08A),
        );
      case EstadoPago.completado:
        return const _ColoresEstado(
          fondo: Color(0xFFDDF5E4),
          texto: Color(0xFF1E6A36),
          borde: Color(0xFFB6E2C2),
        );
      case EstadoPago.cancelado:
        return const _ColoresEstado(
          fondo: Color(0xFFFCE1E1),
          texto: Color(0xFFA12626),
          borde: Color(0xFFF4B6B6),
        );
    }
  }
}

class _ColoresEstado {
  const _ColoresEstado({
    required this.fondo,
    required this.texto,
    required this.borde,
  });

  final Color fondo;
  final Color texto;
  final Color borde;
}
