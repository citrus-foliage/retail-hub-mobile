import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/product_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import 'admin_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final service         = context.read<FirestoreService>();

    final products = productProvider.products;
    final loading  = productProvider.isLoading;
    final total    = products.length;
    final inStock  = products.where((p) => p.inStock).length;
    final lowStock = productProvider.lowStock.length;
    final outStock = productProvider.outOfStock.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () => adminScaffoldKey.currentState?.openDrawer(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: AppTextStyles.heading1()),
              const SizedBox(height: 4),
              Text('Real-time snapshot of your store.',
                  style: AppTextStyles.bodySmall()),
              const SizedBox(height: 28),

              Text('PRODUCTS', style: AppTextStyles.label()),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'TOTAL', value: loading ? '–' : '$total',
                  icon: Icons.inventory_2_outlined, loading: loading,
                  onTap: () => context.go(AppRoutes.adminProducts),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'IN STOCK', value: loading ? '–' : '$inStock',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.stockGreen, loading: loading,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _StatCard(
                  label: 'LOW STOCK', value: loading ? '–' : '$lowStock',
                  icon: Icons.warning_amber_outlined,
                  iconColor: Colors.orange.shade700, loading: loading,
                  onTap: () => context.go(AppRoutes.adminProducts),
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'OUT OF STOCK', value: loading ? '–' : '$outStock',
                  icon: Icons.remove_circle_outline,
                  iconColor: AppColors.saleRed, loading: loading,
                  onTap: () => context.go(AppRoutes.adminProducts),
                )),
              ]),

              if (!loading && lowStock > 0) ...[
                const SizedBox(height: 12),
                _AlertBanner(
                  message: '$lowStock product${lowStock == 1 ? '' : 's'} running low on stock.',
                  onTap: () => context.go(AppRoutes.adminProducts),
                ),
              ],

              const SizedBox(height: 28),

              Text('ORDERS', style: AppTextStyles.label()),
              const SizedBox(height: 12),
              StreamBuilder<List<AppOrder>>(
                stream: service.allOrdersStream(),
                builder: (context, snap) {
                  final orders    = snap.data ?? [];
                  final oTotal    = orders.length;
                  final revenue   = orders.fold<double>(0, (s, o) => s + o.total);
                  final pending   = orders
                      .where((o) => o.status == OrderStatus.pending).length;
                  final completed = orders
                      .where((o) =>
                  o.status == OrderStatus.delivered ||
                      o.status == OrderStatus.confirmed)
                      .length;
                  final oLoading  =
                      snap.connectionState == ConnectionState.waiting;

                  return Column(children: [
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'TOTAL ORDERS', value: oLoading ? '–' : '$oTotal',
                        icon: Icons.receipt_long_outlined, loading: oLoading,
                        onTap: () => context.go(AppRoutes.adminOrders),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'PENDING', value: oLoading ? '–' : '$pending',
                        icon: Icons.hourglass_empty_outlined,
                        iconColor: Colors.orange.shade700, loading: oLoading,
                        onTap: () => context.go(AppRoutes.adminOrders),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'COMPLETED', value: oLoading ? '–' : '$completed',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.stockGreen, loading: oLoading,
                        onTap: () => context.go(AppRoutes.adminOrders),
                      )),
                    ]),
                    const SizedBox(height: 12),
                    _RevenueCard(
                      revenue: revenue, loading: oLoading,
                      onTap: () => context.go(AppRoutes.adminOrders),
                    ),
                  ]);
                },
              ),

              const SizedBox(height: 28),

              Text('QUICK ACTIONS', style: AppTextStyles.label()),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _QuickAction(
                  icon: Icons.add_circle_outline, label: 'Add Product',
                  onTap: () => context.go(AppRoutes.adminAddProd),
                )),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(
                  icon: Icons.list_alt_outlined, label: 'View Orders',
                  onTap: () => context.go(AppRoutes.adminOrders),
                )),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(
                  icon: Icons.people_outline, label: 'Members',
                  onTap: () => context.go(AppRoutes.adminMembers),
                )),
              ]),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? iconColor;
  final bool loading;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label, required this.value, required this.icon,
    this.iconColor, this.loading = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 18, color: iconColor ?? AppColors.mutedText),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 14, color: AppColors.mutedText),
          ],
        ),
        const SizedBox(height: 12),
        loading
            ? Container(height: 28, width: 48,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4)))
            : Text(value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28, fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            )),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.label()),
      ]),
    ),
  );
}

class _RevenueCard extends StatelessWidget {
  final double revenue;
  final bool loading;
  final VoidCallback onTap;
  const _RevenueCard({required this.revenue, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TOTAL REVENUE',
                style: AppTextStyles.label()
                    .copyWith(color: AppColors.white.withOpacity(0.7))),
            const SizedBox(height: 8),
            loading
                ? Container(height: 32, width: 120,
                decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4)))
                : Text('₱${NumberFormat('#,##0.00').format(revenue)}',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28, fontWeight: FontWeight.w600,
                  color: AppColors.white,
                )),
          ]),
        ),
        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.white),
      ]),
    ),
  );
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const _AlertBanner({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade700.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade700),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: AppTextStyles.bodySmall().copyWith(color: Colors.orange.shade800))),
        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.orange.shade700),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22, color: AppColors.adminAccent),
        const SizedBox(height: 8),
        Text(label,
            style: AppTextStyles.label().copyWith(color: AppColors.adminAccent),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}