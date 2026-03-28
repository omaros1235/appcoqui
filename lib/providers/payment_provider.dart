import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  final PaymentService _paymentService;

  bool isLoading = false;
  String? errorMessage;
  Payment? currentPayment;
  List<Payment> paymentList = <Payment>[];

  Future<Payment?> createTransferPayment(TransferPaymentRequest request) async {
    _iniciarCarga();
    try {
      final pago = await _paymentService.createTransferPayment(request);
      currentPayment = pago;
      _insertarOActualizarPago(pago);
      return pago;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      _finalizarCarga();
    }
  }

  Future<Payment?> createCashPayment(CashPaymentRequest request) async {
    _iniciarCarga();
    try {
      final pago = await _paymentService.createCashPayment(request);
      currentPayment = pago;
      _insertarOActualizarPago(pago);
      return pago;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      _finalizarCarga();
    }
  }

  Future<Payment?> getPayment(int id) async {
    _iniciarCarga();
    try {
      final pago = await _paymentService.getPayment(id);
      currentPayment = pago;
      _insertarOActualizarPago(pago);
      return pago;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      _finalizarCarga();
    }
  }

  Future<Payment?> confirmPayment(int id) async {
    _iniciarCarga();
    try {
      final pago = await _paymentService.confirmPayment(id);
      currentPayment = pago;
      _insertarOActualizarPago(pago);
      return pago;
    } catch (error) {
      errorMessage = error.toString();
      return null;
    } finally {
      _finalizarCarga();
    }
  }

  Future<void> listPayments({
    String? method,
    String? status,
  }) async {
    _iniciarCarga();
    try {
      paymentList = await _paymentService.listPayments(
        method: method,
        status: status,
      );
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      _finalizarCarga();
    }
  }

  void _insertarOActualizarPago(Payment pago) {
    final index = paymentList.indexWhere((item) => item.id == pago.id);
    if (index >= 0) {
      paymentList[index] = pago;
    } else {
      paymentList = <Payment>[pago, ...paymentList];
    }
  }

  void _iniciarCarga() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _finalizarCarga() {
    isLoading = false;
    notifyListeners();
  }
}
