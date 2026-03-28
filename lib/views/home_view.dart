import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/shop_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewModel = context.read<AuthViewModel>();
      if (authViewModel.user == null && !authViewModel.isLoading) {
        await authViewModel.getHome();
      }

      if (!mounted) {
        return;
      }

      final shopViewModel = context.read<ShopViewModel>();
      if (shopViewModel.products.isEmpty && !shopViewModel.isLoadingProducts) {
        await shopViewModel.bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, ShopViewModel>(
      builder: (context, authViewModel, shopViewModel, _) {
        final user = authViewModel.user;
        final categories = shopViewModel.categories;
        final selectedCategory = _selectedCategory;
        final products = selectedCategory == null
            ? shopViewModel.products
            : shopViewModel.products
                .where((product) => product.categoria == selectedCategory)
                .toList(growable: false);

        return Scaffold(
          backgroundColor: const Color(0xFFFFF7EF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null ? 'Cargando...' : 'Hola, ${user.nombre}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFC63D2F),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Text(
                  'Lista de productos',
                  style: TextStyle(
                    color: Color(0xFF4B2A18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.push('/payments');
                },
                icon: const Icon(Icons.receipt_long_outlined),
                tooltip: 'Ver pagos',
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/cart');
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'Ver carrito',
                  ),
                  if (shopViewModel.totalItems > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC63D2F),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${shopViewModel.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () async {
                  await authViewModel.logout();
                  if (!mounted) {
                    return;
                  }
                  this.context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Cerrar sesion',
              ),
            ],
          ),
          body: SafeArea(
            child: shopViewModel.isLoadingProducts && shopViewModel.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: _HeroBanner(totalItems: shopViewModel.totalItems),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'Todos',
                              isSelected: selectedCategory == null,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            ),
                            ...categories.map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: _CategoryChip(
                                  label: category,
                                  isSelected: selectedCategory == category,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: shopViewModel.bootstrap,
                          child: products.isEmpty
                              ? ListView(
                                  padding: const EdgeInsets.all(24),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        border:
                                            Border.all(color: const Color(0xFFF0DDCC)),
                                      ),
                                      child: Text(
                                        shopViewModel.productsErrorMessage ??
                                            'No hay productos disponibles.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF8C5A3C),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 120),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return _ProductCard(
                                      product: product,
                                      onAdd: () async {
                                        final ok =
                                            await shopViewModel.addToCart(product);
                                        if (!context.mounted) {
                                          return;
                                        }
                                        final message = ok
                                            ? shopViewModel.successMessage ??
                                                'Producto agregado.'
                                            : shopViewModel.errorMessage ??
                                                'No se pudo agregar al carrito.';
                                        if (!this.context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(content: Text(message)),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      if (shopViewModel.cartErrorMessage != null &&
                          shopViewModel.cartErrorMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1E5),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFF0DDCC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFFC63D2F),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Los productos cargaron, pero hubo un problema al consultar el carrito.',
                                    style: const TextStyle(
                                      color: Color(0xFF8C5A3C),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _BottomCartBar(
              totalItems: shopViewModel.totalItems,
              total: shopViewModel.subtotal,
              onTap: () {
                context.push('/cart');
              },
            ),
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E1F17), Color(0xFFF2A007)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262A1608),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Pide desde tu app',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Agrega productos al carrito y sigue con tu checkout.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$totalItems productos agregados',
                  style: const TextStyle(color: Color(0xFFFFF0E2)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFC63D2F),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF6E4024),
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: Color(0xFFF0DDCC)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAdd,
  });

  final ProductModel product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0DDCC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              child: SizedBox(
                width: double.infinity,
                child: product.imagen.isEmpty
                    ? Container(
                        color: const Color(0xFFFFF1E5),
                        child: const Icon(
                          Icons.fastfood_rounded,
                          size: 44,
                          color: Color(0xFFC63D2F),
                        ),
                      )
                    : Image.network(
                        product.imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (contexto, error, stackTrace) => Container(
                          color: const Color(0xFFFFF1E5),
                          child: const Icon(
                            Icons.fastfood_rounded,
                            size: 44,
                            color: Color(0xFFC63D2F),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF4B2A18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFC63D2F),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC63D2F),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Agregar al carrito'),
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

class _BottomCartBar extends StatelessWidget {
  const _BottomCartBar({
    required this.totalItems,
    required this.total,
    required this.onTap,
  });

  final int totalItems;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4B2A18), Color(0xFF6A341A)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalItems == 0 ? 'Tu carrito esta vacio' : '$totalItems productos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  totalItems == 0
                      ? 'Agrega algo para continuar'
                      : 'Total \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFEFDACC)),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC63D2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ver carrito'),
          ),
        ],
      ),
    );
  }
}




