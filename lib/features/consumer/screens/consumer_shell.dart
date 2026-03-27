import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/router/app_router.dart';
import '../widgets/cart_bottom_sheet.dart';

class ConsumerShell extends StatelessWidget {
  final Widget child;
  const ConsumerShell({super.key, required this.child});

  int _currentIndex(String location) {
    if (location.startsWith(AppRoutes.productDetail)) return 0;
    if (location.startsWith(AppRoutes.catalog))        return 0;
    if (location.startsWith(AppRoutes.consumerOrders) ||
        location.startsWith(AppRoutes.orderDetail))    return 1;
    if (location.startsWith(AppRoutes.wishlist))       return 2;
    if (location.startsWith(AppRoutes.profile))        return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location   = GoRouterState.of(context).uri.toString();
    final cartCount  = context.watch<CartProvider>().itemCount;
    final idx        = _currentIndex(location);
    final isDetail   = location.startsWith(AppRoutes.productDetail) ||
        location.startsWith(AppRoutes.checkout) ||
        location.startsWith(AppRoutes.orderDetail);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      floatingActionButton: (!isDetail && idx == 0)
          ? _CartFab(itemCount: cartCount)
          : null,
      bottomNavigationBar: isDetail
          ? null
          : Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) {
            switch (i) {
              case 0: context.go(AppRoutes.catalog); break;
              case 1: context.go(AppRoutes.consumerOrders); break;
              case 2: context.go(AppRoutes.wishlist); break;
              case 3: context.go(AppRoutes.profile); break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'SHOP',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'ORDERS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'WISHLIST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

class _CartFab extends StatelessWidget {
  final int itemCount;
  const _CartFab({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed:       () => showCartBottomSheet(context),
      backgroundColor: AppColors.primaryText,
      elevation:       2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 22),
          if (itemCount > 0)
            Positioned(
              right: -6, top: -6,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.saleRed, shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    itemCount > 9 ? '9+' : itemCount.toString(),
                    style: const TextStyle(
                      color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}