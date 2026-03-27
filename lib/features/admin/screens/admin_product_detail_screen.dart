import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class AdminProductDetailScreen extends StatelessWidget {
  final Product product;
  const AdminProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.go(AppRoutes.adminProducts),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Product Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.adminProducts),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => context.go(AppRoutes.adminEditProd, extra: product),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.saleRed),
              onPressed: () => _confirmDelete(context, service),
            ),
          ],
        ),
        body: StreamBuilder<List<Product>>(
          stream: service.productsStream(),
          builder: (context, snap) {
            final live = snap.data?.firstWhere(
                  (p) => p.id == product.id,
              orElse: () => product,
            ) ?? product;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (live.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        live.imageUrl,
                        height: 220, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      ),
                    )
                  else
                    _imagePlaceholder(),

                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(live.name, style: AppTextStyles.heading2())),
                      _StockBadge(qty: live.stockQuantity),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('SKU: ${live.sku}', style: AppTextStyles.bodySmall()),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  _DetailRow(label: 'BASE PRICE',       value: '₱${live.basePrice.toStringAsFixed(2)}'),
                  _DetailRow(
                    label: 'DISCOUNTED PRICE',
                    value: '₱${live.discountedPrice.toStringAsFixed(2)}',
                    valueStyle: live.isOnSale
                        ? AppTextStyles.body().copyWith(color: AppColors.saleRed, fontWeight: FontWeight.w600)
                        : null,
                  ),
                  _DetailRow(
                    label: 'STOCK QUANTITY',
                    value: '${live.stockQuantity} units',
                    valueStyle: AppTextStyles.body().copyWith(
                      color: live.stockQuantity == 0 ? AppColors.saleRed
                          : live.stockQuantity < 5  ? Colors.orange
                          : AppColors.stockGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _DetailRow(label: 'CATEGORY',   value: live.category),
                  _DetailRow(label: 'SUPPLIER',   value: live.supplier),
                  _DetailRow(
                    label: 'DATE ADDED',
                    value: DateFormat('MMM d, yyyy').format(live.dateAdded),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  Text('DESCRIPTION', style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  Text(
                    live.description.isEmpty ? 'No description provided.' : live.description,
                    style: AppTextStyles.body(),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.adminEditProd, extra: live),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('EDIT PRODUCT'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    height: 220,
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.border),
    ),
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.mutedText, size: 48),
    ),
  );

  void _confirmDelete(BuildContext context, FirestoreService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title:   Text('Delete product?', style: AppTextStyles.heading3()),
        content: Text('"${product.name}" will be permanently removed.',
            style: AppTextStyles.bodySmall()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.deleteProduct(product.id);
              if (context.mounted) {
                context.go(AppRoutes.adminProducts);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted.')),
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

class _DetailRow extends StatelessWidget {
  final String label, value;
  final TextStyle? valueStyle;
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 140, child: Text(label, style: AppTextStyles.label())),
        Expanded(child: Text(value, style: valueStyle ?? AppTextStyles.body())),
      ]),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int qty;
  const _StockBadge({required this.qty});

  @override
  Widget build(BuildContext context) {
    final Color bg, fg;
    final String text;

    if (qty == 0) {
      bg = AppColors.saleRed.withOpacity(0.1); fg = AppColors.saleRed; text = 'OUT OF STOCK';
    } else if (qty < 5) {
      bg = Colors.orange.withOpacity(0.1); fg = Colors.orange.shade800; text = 'LOW STOCK';
    } else {
      bg = AppColors.stockGreen.withOpacity(0.1); fg = AppColors.stockGreen; text = 'IN STOCK';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(text, style: AppTextStyles.label().copyWith(color: fg, fontSize: 9)),
    );
  }
}