import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/cart_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

void showCartBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    AppColors.background,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => const CartBottomSheet(),
  );
}

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final mq   = MediaQuery.of(context);
    final fmt  = NumberFormat('#,##0.00');

    return DraggableScrollableSheet(
      expand:           false,
      initialChildSize: 0.75,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [
              Text('YOUR BAG', style: AppTextStyles.label()),
              const Spacer(),
              if (!cart.isEmpty)
                TextButton(
                  onPressed: cart.clear,
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.saleRed, padding: EdgeInsets.zero),
                  child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                ),
            ]),
          ),

          const Divider(color: AppColors.border, height: 1),

          Expanded(
            child: cart.isEmpty
                ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 48, color: AppColors.mutedText),
                  const SizedBox(height: 12),
                  Text('Your bag is empty', style: AppTextStyles.heading3()),
                  Text('Add products from the catalog.',
                      style: AppTextStyles.bodySmall()),
                ]))
                : ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (_, i) {
                final item = cart.items[i];
                return Dismissible(
                  key: Key(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.saleRed.withOpacity(0.1),
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.saleRed),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.lightImpact();
                    cart.removeItem(item.product.id);
                  },
                  child: _CartItemRow(item: item, fmt: fmt),
                );
              },
            ),
          ),

          if (!cart.isEmpty)
            Container(
              padding:
              EdgeInsets.fromLTRB(20, 16, 20, 16 + mq.padding.bottom),
              decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border))),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL', style: AppTextStyles.label()),
                    Text('₱${fmt.format(cart.total)}',
                        style: AppTextStyles.heading3()
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      context.go(AppRoutes.checkout);
                    },
                    child: const Text('PROCEED TO CHECKOUT'),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final NumberFormat fmt;
  const _CartItemRow({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: item.product.imageUrl.isNotEmpty
              ? Image.network(item.product.imageUrl, width: 60, height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumb())
              : _thumb(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name,
                style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('₱${fmt.format(item.product.effectivePrice)}',
                style: AppTextStyles.bodySmall()),
          ]),
        ),
        const SizedBox(width: 12),
        Row(children: [
          _QtyBtn(
            icon: Icons.remove,
            onTap: () => cart.updateQuantity(item.product.id, item.quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${item.quantity}', style: AppTextStyles.body()),
          ),
          _QtyBtn(
            icon: Icons.add,
            onTap: item.quantity < item.product.stockQuantity
                ? () => cart.updateQuantity(item.product.id, item.quantity + 1)
                : null,
          ),
        ]),
      ]),
    );
  }

  Widget _thumb() => Container(
    width: 60, height: 60, color: AppColors.border,
    child: const Icon(Icons.image_outlined, color: AppColors.mutedText, size: 20),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border.all(
              color: onTap == null ? AppColors.border : AppColors.primaryText),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14,
            color: onTap == null ? AppColors.border : AppColors.primaryText),
      ),
    );
  }
}