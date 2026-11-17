import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../core/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<CartProvider>().clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${_firstName(auth.user?.name)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppTheme.ink),
            ),
            const Text(
              '¿Qué vas a buscar hoy?',
              style: TextStyle(fontSize: 13, color: AppTheme.muted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            icon: Badge(
              label: Text('${cartProvider.itemCount}'),
              isLabelVisible: cartProvider.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              tooltip: 'Cuenta',
              color: AppTheme.card,
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
              ],
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF2A3348),
                child: Icon(Icons.person_outline, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadCategories();
          await productProvider.loadProducts(
            categoryId: productProvider.selectedCategoryId,
          );
          await cartProvider.loadCart();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productProvider.categories.isNotEmpty)
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    StoreFilterChip(
                      label: 'Todas',
                      isSelected: productProvider.selectedCategoryId == null,
                      onTap: () => productProvider.loadProducts(),
                    ),
                    ...productProvider.categories.map(
                      (category) => CategoryChip(
                        category: category,
                        isSelected: productProvider.selectedCategoryId == category.id,
                        onTap: () {
                          productProvider.loadProducts(categoryId: category.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _buildProductList(productProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadProducts(
                categoryId: provider.selectedCategoryId,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1100 ? 4 : width > 720 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: columns >= 3 ? 0.74 : 0.68,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                );
              },
              onAdd: () async {
                final cart = context.read<CartProvider>();
                final success = await cart.addToCart(product.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${product.name} se agregó al carrito'
                          : (cart.error ?? 'No se pudo agregar'),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _firstName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return 'bienvenido';
    return value.split(' ').first;
  }
}
