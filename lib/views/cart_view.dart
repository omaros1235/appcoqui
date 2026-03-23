import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item_model.dart';
import '../viewmodels/shop_viewmodel.dart';
import 'checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

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
              'Carrito',
              style: TextStyle(
                color: Color(0xFF4B2A18),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: shopViewModel.isLoadingCart
              ? const Center(child: CircularProgressIndicator())
              : shopViewModel.cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes productos agregados todavia.',
                        style: TextStyle(color: Color(0xFF8C5A3C)),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: shopViewModel.cart.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = shopViewModel.cart.items[index];
                              return _CartItemCard(item: item);
                            },
                          ),
                        ),
                        _CartSummary(
                          subtotal: shopViewModel.cart.total,
                          totalItems: shopViewModel.totalItems,
                          onCheckout: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const CheckoutView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0DDCC)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.producto.imagen.isEmpty
                  ? Container(
                      color: const Color(0xFFFFF1E5),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFFC63D2F),
                      ),
                    )
                  : Image.network(
                      item.producto.imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFF1E5),
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFFC63D2F),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.producto.nombre,
                  style: const TextStyle(
                    color: Color(0xFF4B2A18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${item.cantidad}',
                  style: const TextStyle(color: Color(0xFF8C5A3C)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFC63D2F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.totalItems,
    required this.onCheckout,
  });

  final double subtotal;
  final int totalItems;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4B2A18), Color(0xFF6A341A)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Productos',
                  style: TextStyle(color: Color(0xFFEED9CB)),
                ),
                Text(
                  '$totalItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total general',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC63D2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ir al checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
