import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'admin_shell.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Orders'),
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () => adminScaffoldKey.currentState?.openDrawer(),
          ),
        ),
        body: StreamBuilder<List<AppOrder>>(
          stream: service.allOrdersStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => const SkeletonBox(height: 100, radius: 6),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text('Error loading orders', style: AppTextStyles.bodySmall()),
              );
            }
            final orders = snap.data ?? [];
            if (orders.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.mutedText),
                  const SizedBox(height: 16),
                  Text('No orders yet', style: AppTextStyles.heading3()),
                  Text('Consumer orders will appear here in real time.',
                      style: AppTextStyles.bodySmall()),
                ]),
              );
            }

            final totalRevenue = orders.fold<double>(0, (s, o) => s + o.total);

            return Column(children: [
              _SummaryBar(orderCount: orders.length, totalRevenue: totalRevenue),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.adminAccent,
                  onRefresh: () async {},
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final int orderCount;
  final double totalRevenue;
  const _SummaryBar({required this.orderCount, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        _Stat(label: 'TOTAL ORDERS', value: orderCount.toString()),
        Container(width: 1, height: 32, color: AppColors.border),
        _Stat(label: 'REVENUE',
            value: '₱${NumberFormat('#,##0.00').format(totalRevenue)}'),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value,
          style: AppTextStyles.heading3().copyWith(color: AppColors.adminAccent)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.label()),
    ]),
  );
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  const _OrderCard({required this.order});

  Color _colorFor(OrderStatus s) => switch (s) {
    OrderStatus.confirmed => AppColors.stockGreen,
    OrderStatus.shipped   => Colors.blue.shade700,
    OrderStatus.delivered => AppColors.stockGreen,
    OrderStatus.cancelled => AppColors.saleRed,
    _                     => Colors.orange.shade700,
  };

  void _showStatusSheet(BuildContext context) {
    final service = context.read<FirestoreService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Update Order Status', style: AppTextStyles.heading3()),
          ),
          const Divider(color: AppColors.border),
          ...OrderStatus.values.map((s) {
            final isCurrent = s == order.status;
            final color = _colorFor(s);
            return ListTile(
              onTap: isCurrent ? null : () async {
                Navigator.pop(sheetCtx);
                try {
                  await service.updateOrderStatus(order.id, s);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Status updated to ${s.label}.'),
                    ));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to update status: $e'),
                    ));
                  }
                }
              },
              leading: Icon(
                isCurrent ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isCurrent ? color : AppColors.mutedText,
              ),
              title: Text(s.label,
                  style: AppTextStyles.body().copyWith(
                    color: isCurrent ? color : AppColors.primaryText,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  )),
            );
          }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final statusColor = _colorFor(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.userEmail,
                    style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(DateFormat('MMM d, yyyy · h:mm a').format(order.createdAt),
                    style: AppTextStyles.bodySmall()),
              ]),
            ),
            GestureDetector(
              onTap: () => _showStatusSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(order.status.label.toUpperCase(),
                      style: AppTextStyles.label()
                          .copyWith(color: statusColor, fontSize: 9)),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 12, color: statusColor),
                ]),
              ),
            ),
          ]),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Expanded(child: Text('${item.quantity}× ${item.productName}',
                  style: AppTextStyles.bodySmall())),
              Text('₱${fmt.format(item.subtotal)}',
                  style: AppTextStyles.bodySmall()
                      .copyWith(color: AppColors.primaryText)),
            ]),
          )),

          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ORDER TOTAL', style: AppTextStyles.label()),
              Text('₱${fmt.format(order.total)}',
                  style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ]),
      ),
    );
  }
}