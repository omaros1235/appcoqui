import 'package:flutter/foundation.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.descripcion,
    required this.categoria,
  });

  final int id;
  final String nombre;
  final double precio;
  final String imagen;
  final String descripcion;
  final String categoria;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _asInt(json['id']),
      nombre: json['nombre']?.toString() ?? json['name']?.toString() ?? 'Producto',
      precio: _asDouble(json['precio'] ?? json['price']),
      imagen: _normalizeImageUrl(
        json['imagen']?.toString() ?? json['image']?.toString() ?? '',
      ),
      descripcion:
          json['descripcion']?.toString() ?? json['description']?.toString() ?? '',
      categoria:
          json['categoria']?.toString() ?? json['category']?.toString() ?? 'General',
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

  static String _normalizeImageUrl(String url) {
    if (url.isEmpty) {
      return '';
    }

    if (kIsWeb) {
      return url;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return url
            .replaceFirst('http://127.0.0.1:', 'http://10.0.2.2:')
            .replaceFirst('http://localhost:', 'http://10.0.2.2:');
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return url;
    }
  }
}
