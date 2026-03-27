import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/cart_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placing = false;
  final _fmt = NumberFormat('#,##0.00');

  Future<void> _placeOrder() async {
    HapticFeedback.mediumImpact();
    final cart    = context.read<CartProvider>();
    final auth    = context.read<AuthProvider>();
    final service = context.read<FirestoreService>();

    if (cart.isEmpty || auth.appUser == null) return;
    setState(() => _placing = true);

    try {
      final user  = auth.appUser!;
      final items = cart.toOrderItems();
      final order = AppOrder(
        id:        const Uuid().v4(),
        userId:    user.uid,
        userEmail: user.email,
        items:     items,
        total:     cart.total,
        status:    OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final deductions = {
        for (final item in cart.items) item.product.id: item.quantity,
      };

      await service.placeOrder(order);
      await service.deductStock(deductions);

      cart.clear();

      if (mounted) {
        context.go(AppRoutes.consumerOrders);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.catalog);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.catalog),
          ),
        ),
        body: cart.isEmpty
            ? Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 48, color: AppColors.mutedText),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: AppTextStyles.heading3()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.catalog),
              child: const Text('CONTINUE SHOPPING'),
            ),
          ]),
        )
            : Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('ORDER SUMMARY', style: AppTextStyles.label()),
                  const SizedBox(height: 16),

                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: item.product.imageUrl.isNotEmpty
                            ? Image.network(item.product.imageUrl,
                            width: 64, height: 64, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _thumb())
                            : _thumb(),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                style: AppTextStyles.body()
                                    .copyWith(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              '₱${_fmt.format(item.product.effectivePrice)} × ${item.quantity}',
                              style: AppTextStyles.bodySmall(),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${_fmt.format(item.subtotal)}',
                        style: AppTextStyles.body()
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ]),
                  )),

                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodySmall()),
                      Text('₱${_fmt.format(cart.total)}',
                          style: AppTextStyles.bodySmall()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping', style: AppTextStyles.bodySmall()),
                      Text('Free',
                          style: AppTextStyles.bodySmall()
                              .copyWith(color: AppColors.stockGreen)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: AppTextStyles.label()),
                      Text(
                        '₱${_fmt.format(cart.total)}',
                        style: AppTextStyles.heading3()
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Stock will be deducted upon order placement. '
                              'Orders are marked as pending until confirmed.',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  child: _placing
                      ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: AppColors.white))
                      : Text('PLACE ORDER  ·  ₱${_fmt.format(cart.total)}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb() => Container(
    width: 64, height: 64, color: AppColors.border,
    child: const Icon(Icons.image_outlined, color: AppColors.mutedText, size: 20),
  );
}