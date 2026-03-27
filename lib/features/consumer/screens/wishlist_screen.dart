import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/product_grid_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>().products;
    final wishIds  = auth.appUser?.wishlist ?? [];
    final wishlisted = products.where((p) => wishIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Wishlist')),
      body: wishlisted.isEmpty
          ? Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_border, size: 48, color: AppColors.mutedText),
          const SizedBox(height: 16),
          Text('Your wishlist is empty', style: AppTextStyles.heading3()),
          const SizedBox(height: 8),
          Text('Save products you love to find them later.',
              style: AppTextStyles.bodySmall()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('BROWSE PRODUCTS'),
          ),
        ]),
      )
          : GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: wishlisted.length,
        itemBuilder: (_, i) => ProductGridCard(
          product: wishlisted[i],
          onTap:   () => context.go(AppRoutes.productDetail, extra: wishlisted[i]),
        ),
      ),
    );
  }
}