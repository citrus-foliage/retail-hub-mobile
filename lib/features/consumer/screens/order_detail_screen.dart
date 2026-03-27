import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class OrderDetailScreen extends StatelessWidget {
  final AppOrder order;
  const OrderDetailScreen({super.key, required this.order});

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.consumerOrders);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Order Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.consumerOrders),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    order.status.label.toUpperCase(),
                    style: AppTextStyles.label()
                        .copyWith(color: _statusColor, fontSize: 10),
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              _MetaRow('Order placed', DateFormat('MMMM d, yyyy · h:mm a').format(order.createdAt)),
              _MetaRow('Email',        order.userEmail),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 20),

              Text('ITEMS', style: AppTextStyles.label()),
              const SizedBox(height: 14),

              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(item.imageUrl, width: 64, height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _thumb())
                        : _thumb(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName,
                            style: AppTextStyles.body()
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          '₱${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  Text('₱${fmt.format(item.subtotal)}',
                      style: AppTextStyles.body()
                          .copyWith(fontWeight: FontWeight.w600)),
                ]),
              )),

              const Divider(color: AppColors.border),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL', style: AppTextStyles.label()),
                  Text('₱${fmt.format(order.total)}',
                      style: AppTextStyles.heading3()
                          .copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb() => Container(
    width: 64, height: 64, color: AppColors.border,
    child: const Icon(Icons.image_outlined, color: AppColors.mutedText, size: 20),
  );
}

class _MetaRow extends StatelessWidget {
  final String label, value;
  const _MetaRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: AppTextStyles.label())),
      Expanded(child: Text(value, style: AppTextStyles.bodySmall()
          .copyWith(color: AppColors.primaryText))),
    ]),
  );
}