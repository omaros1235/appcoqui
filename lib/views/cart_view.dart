import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/cart_item_model.dart';
import '../viewmodels/shop_viewmodel.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  Future<void> _cambiarCantidad(
    BuildContext context,
    CartItemModel item,
    int nuevaCantidad,
  ) async {
    final shopViewModel = context.read<ShopViewModel>();
    final ok = await shopViewModel.updateCartItem(item, nuevaCantidad);

    if (!context.mounted) {
      return;
    }

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shopViewModel.errorMessage ?? 'No se pudo actualizar el carrito.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, shopViewModel, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Tu carrito',
              style: TextStyle(
                color: Color(0xFF140B2C),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: shopViewModel.isLoadingCart
              ? const Center(child: CircularProgressIndicator())
              : shopViewModel.cart.items.isEmpty
                  ? const _EstadoCarritoVacio()
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            itemCount: shopViewModel.cart.items.length,
                            separatorBuilder: (contexto, indice) =>
                                const SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final item = shopViewModel.cart.items[index];
                              return _CartItemCard(
                                item: item,
                                onIncrementar: () =>
                                    _cambiarCantidad(context, item, item.cantidad + 1),
                                onDecrementar: () =>
                                    _cambiarCantidad(context, item, item.cantidad - 1),
                                onEliminar: () => _cambiarCantidad(context, item, 0),
                              );
                            },
                          ),
                        ),
                        _CartSummary(
                          subtotal: shopViewModel.cart.total,
                          onCheckout: () {
                            context.push('/checkout');
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
  const _CartItemCard({
    required this.item,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onEliminar,
  });

  final CartItemModel item;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final precioActual = item.subtotal;
    final precioAnterior = precioActual / 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            foregroundColor: const Color(0xFF140B2C),
          ),
          child: const Text(
            'Editar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 96,
                height: 96,
                color: const Color(0xFFF4F4F6),
                child: item.producto.imagen.isEmpty
                    ? const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFFE7005E),
                        size: 40,
                      )
                    : Image.network(
                        item.producto.imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (contexto, error, stackTrace) => const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFFE7005E),
                          size: 40,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF140B2C),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${precioActual.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF140B2C),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${precioAnterior.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF8F8A99),
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEA3A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '10% OFF',
                      style: TextStyle(
                        color: Color(0xFF140B2C),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CantidadControl(
              cantidad: item.cantidad,
              onIncrementar: onIncrementar,
              onDecrementar: item.cantidad > 1 ? onDecrementar : onEliminar,
              mostrarEliminar: item.cantidad == 1,
            ),
          ],
        ),
      ],
    );
  }
}

class _CantidadControl extends StatelessWidget {
  const _CantidadControl({
    required this.cantidad,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.mostrarEliminar,
  });

  final int cantidad;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final bool mostrarEliminar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrementar,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                mostrarEliminar ? Icons.delete_outline_rounded : Icons.remove_rounded,
                color: const Color(0xFF140B2C),
                size: 24,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF140B2C),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: onIncrementar,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.add_rounded,
                color: Color(0xFF140B2C),
                size: 24,
              ),
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
    required this.onCheckout,
  });

  final double subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final totalAnterior = subtotal / 0.9;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'Subtotal',
                    style: TextStyle(
                      color: Color(0xFF140B2C),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${totalAnterior.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF8F8A99),
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF140B2C),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE7005E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Ir a pagar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoCarritoVacio extends StatelessWidget {
  const _EstadoCarritoVacio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No tienes productos agregados todavia.',
          style: TextStyle(
            color: Color(0xFF6B6578),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
