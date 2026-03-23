class OrderModel {
  const OrderModel({
    required this.id,
    required this.total,
    required this.estado,
  });

  final int id;
  final double total;
  final String estado;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final source = json['pedido'] is Map<String, dynamic>
        ? json['pedido'] as Map<String, dynamic>
        : json;

    return OrderModel(
      id: _asInt(source['id']),
      total: _asDouble(source['total']),
      estado: source['estado']?.toString() ?? source['status']?.toString() ?? '',
    );
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
}
