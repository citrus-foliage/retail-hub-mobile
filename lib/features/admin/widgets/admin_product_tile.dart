import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_theme.dart';

class AdminProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(product.imageUrl,
                  width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.sku, style: AppTextStyles.bodySmall()),
                const SizedBox(height: 6),
                Row(children: [
                  Text(
                    '₱${fmt.format(product.effectivePrice)}',
                    style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  _StockChip(qty: product.stockQuantity),
                ]),
              ]),
            ),

            Column(mainAxisSize: MainAxisSize.min, children: [
              _ActionIcon(icon: Icons.edit_outlined,
                  color: AppColors.adminAccent, onTap: onEdit),
              const SizedBox(height: 4),
              _ActionIcon(icon: Icons.delete_outline,
                  color: AppColors.saleRed, onTap: onDelete),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 56, height: 56, color: AppColors.border,
    child: const Icon(Icons.image_outlined, color: AppColors.mutedText, size: 20),
  );
}

class _StockChip extends StatelessWidget {
  final int qty;
  const _StockChip({required this.qty});

  @override
  Widget build(BuildContext context) {
    final color = qty == 0 ? AppColors.saleRed
        : qty < 5 ? Colors.orange.shade700
        : AppColors.stockGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        qty == 0 ? 'OUT OF STOCK' : '$qty in stock',
        style: AppTextStyles.label().copyWith(color: color, fontSize: 8),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}