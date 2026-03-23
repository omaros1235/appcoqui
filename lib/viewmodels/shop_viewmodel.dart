import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ShopViewModel extends ChangeNotifier {
  ShopViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  bool isLoadingProducts = false;
  bool isLoadingCart = false;
  bool isProcessingCheckout = false;
  String? errorMessage;
  String? productsErrorMessage;
  String? cartErrorMessage;
  String? successMessage;
  List<ProductModel> products = <ProductModel>[];
  CartModel cart = const CartModel.empty();
  OrderModel? currentOrder;

  int get totalItems => cart.items.fold(0, (sum, item) => sum + item.cantidad);

  double get subtotal => cart.total;

  Future<void> loadProducts() async {
    isLoadingProducts = true;
    productsErrorMessage = null;
    errorMessage = null;
    notifyListeners();

    try {
      products = await _apiService.getProductos();
    } catch (error) {
      productsErrorMessage = error.toString();
      errorMessage = productsErrorMessage;
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    isLoadingCart = true;
    cartErrorMessage = null;
    notifyListeners();

    try {
      cart = await _apiService.getCarrito();
    } catch (error) {
      cartErrorMessage = error.toString();
      if (errorMessage == null || errorMessage!.isEmpty) {
        errorMessage = cartErrorMessage;
      }
    } finally {
      isLoadingCart = false;
      notifyListeners();
    }
  }

  Future<void> bootstrap() async {
    await loadProducts();
    await loadCart();
  }

  Future<bool> addToCart(ProductModel product, {int cantidad = 1}) async {
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      cart = await _apiService.agregarAlCarrito(
        productoId: product.id,
        cantidad: cantidad,
      );
      successMessage = '${product.nombre} agregado al carrito.';
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCartItem(CartItemModel item, int cantidad) async {
    if (cantidad <= 0) {
      return addToCart(item.producto, cantidad: -item.cantidad);
    }
    return addToCart(item.producto, cantidad: cantidad - item.cantidad);
  }

  Future<bool> createOrder() async {
    isProcessingCheckout = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      currentOrder = await _apiService.crearPedido();
      successMessage = 'Pedido creado correctamente.';
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isProcessingCheckout = false;
      notifyListeners();
    }
  }

  Future<bool> payOrder() async {
    if (currentOrder == null) {
      errorMessage = 'No hay un pedido listo para pagar.';
      notifyListeners();
      return false;
    }

    isProcessingCheckout = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _apiService.pagarPedido(currentOrder!.id);
      successMessage = 'Pago enviado correctamente.';
      cart = const CartModel.empty();
      currentOrder = null;
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isProcessingCheckout = false;
      notifyListeners();
    }
  }

  List<String> get categories {
    final values = products.map((product) => product.categoria).toSet().toList();
    values.sort();
    return values;
  }
}
