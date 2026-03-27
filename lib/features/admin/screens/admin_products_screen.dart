import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/product_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/admin_product_tile.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'admin_shell.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final service  = context.read<FirestoreService>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Products'),
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () => adminScaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, size: 22),
              tooltip: 'Add Product',
              onPressed: () => context.go(AppRoutes.adminAddProd),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  hintText: 'Search a product…',
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.mutedText),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                ),
              ),
            ),
            Expanded(child: _buildBody(context, provider, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductProvider provider, FirestoreService service) {
    if (provider.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const SkeletonBox(height: 80, radius: 6),
      );
    }

    if (provider.state == ProductLoadState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppColors.saleRed, size: 40),
            const SizedBox(height: 12),
            Text('Failed to load products', style: AppTextStyles.heading3()),
            const SizedBox(height: 6),
            Text(provider.error ?? '', style: AppTextStyles.bodySmall(), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final products = _search.isEmpty ? provider.products : provider.filtered(query: _search);

    if (products.isEmpty && _search.isEmpty) {
      return _EmptyState(onAdd: () => context.go(AppRoutes.adminAddProd));
    }

    if (products.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off, size: 40, color: AppColors.mutedText),
        const SizedBox(height: 12),
        Text('No results for "$_search"', style: AppTextStyles.bodySmall()),
      ]));
    }

    return RefreshIndicator(
      color: AppColors.adminAccent,
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => AdminProductTile(
          product:  products[i],
          onTap:    () => context.go(AppRoutes.adminProdDetail, extra: products[i]),
          onEdit:   () => context.go(AppRoutes.adminEditProd,   extra: products[i]),
          onDelete: () => _confirmDelete(context, service, products[i]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FirestoreService service, Product product) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title:   Text('Delete product?', style: AppTextStyles.heading3()),
        content: Text('"${product.name}" will be permanently removed.',
            style: AppTextStyles.bodySmall()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              try {
                await service.deleteProduct(product.id);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Product deleted.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.saleRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedText),
        const SizedBox(height: 16),
        Text('No products yet', style: AppTextStyles.heading3()),
        const SizedBox(height: 8),
        Text('Add your first product to get started.', style: AppTextStyles.bodySmall()),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('ADD PRODUCT'),
        ),
      ]),
    );
  }
}