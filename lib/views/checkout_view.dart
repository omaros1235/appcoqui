import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/shop_viewmodel.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  Future<void> _handlePay(BuildContext context) async {
    final shopViewModel = context.read<ShopViewModel>();
    final created = await shopViewModel.createOrder();
    if (!context.mounted || !created) {
      if (context.mounted && shopViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(shopViewModel.errorMessage!)),
        );
      }
      return;
    }

    final order = shopViewModel.currentOrder;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo preparar el pedido para pago.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shopViewModel.successMessage ?? 'Pedido creado. Selecciona el metodo de pago.',
        ),
      ),
    );

    context.push(
      '/payments/method',
      extra: {
        'orderId': order.id,
        'amount': order.total,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, shopViewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Checkout',
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
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFF0DDCC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de compra',
                        style: TextStyle(
                          color: Color(0xFF4B2A18),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CheckoutRow(
                        label: 'Productos',
                        value: '${shopViewModel.totalItems}',
                      ),
                      const SizedBox(height: 10),
                      _CheckoutRow(
                        label: 'Subtotal',
                        value: '\$${shopViewModel.subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      _CheckoutRow(
                        label: 'Total general',
                        value: '\$${shopViewModel.subtotal.toStringAsFixed(2)}',
                        strong: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E5),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0DDCC)),
                  ),
                  child: const Text(
                    'Cuando toques continuar se creara el pedido y podras elegir transferencia o efectivo.',
                    style: TextStyle(
                      color: Color(0xFF8C5A3C),
                      height: 1.4,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: shopViewModel.isProcessingCheckout
                        ? null
                        : () => _handlePay(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC63D2F),
                      foregroundColor: Colors.white,
                    ),
                    child: shopViewModel.isProcessingCheckout
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continuar al pago',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: const Color(0xFF4B2A18),
      fontSize: strong ? 18 : 15,
      fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
