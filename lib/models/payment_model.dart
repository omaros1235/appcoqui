import 'dart:typed_data';

enum MetodoPago {
  transferencia,
  efectivo;

  String get valorApi {
    switch (this) {
      case MetodoPago.transferencia:
        return 'transferencia';
      case MetodoPago.efectivo:
        return 'efectivo';
    }
  }

  String get etiqueta {
    switch (this) {
      case MetodoPago.transferencia:
        return 'Transferencia';
      case MetodoPago.efectivo:
        return 'Efectivo';
    }
  }

  static MetodoPago fromJson(dynamic value) {
    final normalizado = value?.toString().toLowerCase().trim() ?? '';
    if (normalizado.contains('transfer')) {
      return MetodoPago.transferencia;
    }
    return MetodoPago.efectivo;
  }
}

enum EstadoPago {
  pendiente,
  completado,
  cancelado;

  String get valorApi {
    switch (this) {
      case EstadoPago.pendiente:
        return 'pendiente';
      case EstadoPago.completado:
        return 'completado';
      case EstadoPago.cancelado:
        return 'cancelado';
    }
  }

  String get etiqueta {
    switch (this) {
      case EstadoPago.pendiente:
        return 'Pendiente';
      case EstadoPago.completado:
        return 'Completado';
      case EstadoPago.cancelado:
        return 'Cancelado';
    }
  }

  static EstadoPago fromJson(dynamic value) {
    final normalizado = value?.toString().toLowerCase().trim() ?? '';
    if (normalizado.contains('complet')) {
      return EstadoPago.completado;
    }
    if (normalizado.contains('cancel')) {
      return EstadoPago.cancelado;
    }
    return EstadoPago.pendiente;
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.order,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.transactionReference,
    this.transferDate,
    this.cashReceived,
    this.changeGiven,
    this.confirmedBy,
    this.transferReceipt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int order;
  final double amount;
  final MetodoPago paymentMethod;
  final EstadoPago status;
  final String? bankName;
  final String? accountNumber;
  final String? transactionReference;
  final DateTime? transferDate;
  final double? cashReceived;
  final double? changeGiven;
  final String? confirmedBy;
  final String? transferReceipt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Payment.fromJson(Map<String, dynamic> json) {
    final fuente = json['payment'] is Map<String, dynamic>
        ? json['payment'] as Map<String, dynamic>
        : json;

    return Payment(
      id: _asInt(fuente['id']),
      order: _asInt(fuente['order'] ?? fuente['pedido']),
      amount: _asDouble(fuente['amount'] ?? fuente['monto']),
      paymentMethod: MetodoPago.fromJson(
        fuente['payment_method'] ?? fuente['method'],
      ),
      status: EstadoPago.fromJson(fuente['status']),
      bankName: fuente['bank_name']?.toString(),
      accountNumber: fuente['account_number']?.toString(),
      transactionReference: fuente['transaction_reference']?.toString(),
      transferDate: _asDateTime(fuente['transfer_date']),
      cashReceived: _asNullableDouble(fuente['cash_received']),
      changeGiven: _asNullableDouble(fuente['change_given']),
      confirmedBy: fuente['confirmed_by']?.toString(),
      transferReceipt: fuente['transfer_receipt']?.toString(),
      createdAt: _asDateTime(fuente['created_at'] ?? fuente['fecha_creacion']),
      updatedAt: _asDateTime(fuente['updated_at'] ?? fuente['fecha_actualizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'order': order,
      'amount': amount,
      'payment_method': paymentMethod.valorApi,
      'status': status.valorApi,
      'bank_name': bankName,
      'account_number': accountNumber,
      'transaction_reference': transactionReference,
      'transfer_date': transferDate?.toIso8601String().split('T').first,
      'cash_received': cashReceived,
      'change_given': changeGiven,
      'confirmed_by': confirmedBy,
      'transfer_receipt': transferReceipt,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return _asDouble(value);
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

class TransferPaymentRequest {
  const TransferPaymentRequest({
    required this.order,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.transactionReference,
    required this.transferDate,
    this.transferReceipt,
  });

  final int order;
  final double amount;
  final String bankName;
  final String accountNumber;
  final String transactionReference;
  final DateTime transferDate;
  final TransferReceiptFile? transferReceipt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'order': order,
      'amount': amount,
      'bank_name': bankName,
      'account_number': accountNumber,
      'transaction_reference': transactionReference,
      'transfer_date': transferDate.toIso8601String().split('T').first,
    };
  }
}

class TransferReceiptFile {
  const TransferReceiptFile({
    required this.name,
    this.bytes,
    this.path,
  });

  final String name;
  final Uint8List? bytes;
  final String? path;
}

class CashPaymentRequest {
  const CashPaymentRequest({
    required this.order,
    required this.amount,
    required this.cashReceived,
    required this.confirmedBy,
  });

  final int order;
  final double amount;
  final double cashReceived;
  final String confirmedBy;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'order': order,
      'amount': amount,
      'cash_received': cashReceived,
      'confirmed_by': confirmedBy,
    };
  }
}
