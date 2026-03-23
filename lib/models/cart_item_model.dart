import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.producto,
    required this.cantidad,
    required this.subtotal,
  });

  final ProductModel producto;
  final int cantidad;
  final double subtotal;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productoJson = json['producto'];
    final producto = productoJson is Map<String, dynamic>
        ? ProductModel.fromJson(productoJson)
        : ProductModel(
            id: _asInt(json['producto_id'] ?? json['id']),
            nombre: json['nombre']?.toString() ?? 'Producto',
            precio: _asDouble(json['precio']),
            imagen: json['imagen']?.toString() ?? '',
            descripcion: json['descripcion']?.toString() ?? '',
            categoria: json['categoria']?.toString() ?? 'General',
          );

    final cantidad = _asInt(json['cantidad']);
    return CartItemModel(
      producto: producto,
      cantidad: cantidad,
      subtotal: _asDouble(json['subtotal']) == 0
          ? producto.precio * cantidad
          : _asDouble(json['subtotal']),
    );
  }

  CartItemModel copyWith({
    ProductModel? producto,
    int? cantidad,
    double? subtotal,
  }) {
    return CartItemModel(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      subtotal: subtotal ?? this.subtotal,
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
