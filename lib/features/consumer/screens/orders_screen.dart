import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../shared/widgets/skeleton_loader.dart';

class ConsumerOrdersScreen extends StatelessWidget {
  const ConsumerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final uid     = context.read<AuthProvider>().appUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<AppOrder>>(
        stream: service.userOrdersStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const SkeletonBox(height: 120, radius: 6),
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.mutedText),
                const SizedBox(height: 16),
                Text('No orders yet', style: AppTextStyles.heading3()),
                Text('Your purchase history will appear here.',
                    style: AppTextStyles.bodySmall()),
              ]),
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryText,
            onRefresh: () async {},
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onTap: () => context.go(AppRoutes.orderDetail, extra: orders[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor => switch (order.status) {
    OrderStatus.confirmed => AppColors.stockGreen,
    OrderStatus.shipped   => Colors.blue.shade700,
    OrderStatus.delivered => AppColors.stockGreen,
    OrderStatus.cancelled => AppColors.saleRed,
    _                     => Colors.orange.shade700,
  };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(DateFormat('MMM d, yyyy').format(order.createdAt),
                  style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(order.status.label.toUpperCase(),
                    style: AppTextStyles.label()
                        .copyWith(color: _statusColor, fontSize: 9)),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, width: 40, height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumb())
                      : _thumb(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.productName,
                        style: AppTextStyles.bodySmall()
                            .copyWith(color: AppColors.primaryText)),
                    Text('${item.quantity} × ₱${fmt.format(item.unitPrice)}',
                        style: AppTextStyles.bodySmall()),
                  ]),
                ),
                Text('₱${fmt.format(item.subtotal)}',
                    style: AppTextStyles.bodySmall().copyWith(
                        color: AppColors.primaryText, fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(height: 6),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: AppTextStyles.label()),
                Text('₱${fmt.format(order.total)}',
                    style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _thumb() => Container(
    width: 40, height: 40, color: AppColors.border,
    child: const Icon(Icons.image_outlined, color: AppColors.mutedText, size: 14),
  );
}