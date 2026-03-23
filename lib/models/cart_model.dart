import 'cart_item_model.dart';

class CartModel {
  const CartModel({
    required this.items,
    required this.total,
  });

  final List<CartItemModel> items;
  final double total;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['productos'] ?? json['carrito'] ?? <dynamic>[];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList(growable: false)
        : <CartItemModel>[];

    return CartModel(
      items: items,
      total: _asDouble(json['total']) == 0
          ? items.fold(0, (sum, item) => sum + item.subtotal)
          : _asDouble(json['total']),
    );
  }

  const CartModel.empty()
      : items = const <CartItemModel>[],
        total = 0;

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
