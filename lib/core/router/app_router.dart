import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

// Admin
import '../../features/admin/screens/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_products_screen.dart';
import '../../features/admin/screens/admin_product_form_screen.dart';
import '../../features/admin/screens/admin_orders_screen.dart';
import '../../features/admin/screens/admin_product_detail_screen.dart';
import '../../features/admin/screens/admin_members_screen.dart';

// Consumer
import '../../features/consumer/screens/consumer_shell.dart';
import '../../features/consumer/screens/catalog_screen.dart';
import '../../features/consumer/screens/product_detail_screen.dart';
import '../../features/consumer/screens/orders_screen.dart';
import '../../features/consumer/screens/order_detail_screen.dart';
import '../../features/consumer/screens/wishlist_screen.dart';
import '../../features/consumer/screens/profile_screen.dart';
import '../../features/consumer/screens/checkout_screen.dart';

class AppRoutes {
  static const splash   = '/';
  static const login    = '/login';
  static const register = '/register';

  // Admin
  static const adminShell      = '/admin';
  static const adminDashboard  = '/admin/dashboard';
  static const adminProducts   = '/admin/products';
  static const adminAddProd    = '/admin/products/add';
  static const adminEditProd   = '/admin/products/edit';
  static const adminOrders     = '/admin/orders';
  static const adminProdDetail = '/admin/products/detail';
  static const adminMembers    = '/admin/members';

  // Consumer
  static const consumerShell  = '/shop';
  static const catalog        = '/shop/catalog';
  static const productDetail  = '/shop/product';
  static const consumerOrders = '/shop/orders';
  static const orderDetail    = '/shop/orders/detail';
  static const wishlist       = '/shop/wishlist';
  static const profile        = '/shop/profile';
  static const checkout       = '/shop/checkout';

  static const _extraRoutes = {
    productDetail,
    adminProdDetail,
    adminEditProd,
    orderDetail,
  };

  static bool _isExtraRoute(String loc) =>
      _extraRoutes.any((r) => loc.startsWith(r));
}

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final loc    = state.uri.toString();

      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn    = authProvider.isLoggedIn;
      final isAdmin     = authProvider.isAdmin;
      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.register;
      final isSplash    = loc == AppRoutes.splash;

      if (AppRoutes._isExtraRoute(loc)) return null;

      if (!loggedIn && !isAuthRoute) return AppRoutes.login;
      if (loggedIn && (isAuthRoute || isSplash)) {
        return isAdmin ? AppRoutes.adminDashboard : AppRoutes.catalog;
      }
      if (loggedIn &&  isAdmin && loc.startsWith('/shop'))  return AppRoutes.adminDashboard;
      if (loggedIn && !isAdmin && loc.startsWith('/admin')) return AppRoutes.catalog;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash,   builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),

      GoRoute(path: AppRoutes.adminShell, redirect: (_, __) => AppRoutes.adminDashboard),
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.adminDashboard, builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: AppRoutes.adminProducts,  builder: (_, __) => const AdminProductsScreen()),
          GoRoute(path: AppRoutes.adminAddProd,   builder: (_, __) => const AdminProductFormScreen()),
          GoRoute(
            path: AppRoutes.adminEditProd,
            builder: (_, s) {
              final product = s.extra;
              if (product is! Product) return const AdminProductFormScreen();
              return AdminProductFormScreen(product: product);
            },
          ),
          GoRoute(
            path: AppRoutes.adminProdDetail,
            builder: (_, s) {
              final product = s.extra;
              if (product is! Product) return const AdminProductsScreen();
              return AdminProductDetailScreen(product: product);
            },
          ),
          GoRoute(path: AppRoutes.adminOrders,  builder: (_, __) => const AdminOrdersScreen()),
          GoRoute(path: AppRoutes.adminMembers, builder: (_, __) => const AdminMembersScreen()),
        ],
      ),

      GoRoute(path: AppRoutes.consumerShell, redirect: (_, __) => AppRoutes.catalog),
      ShellRoute(
        builder: (_, __, child) => ConsumerShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.catalog,        builder: (_, __) => const CatalogScreen()),
          GoRoute(
            path: AppRoutes.productDetail,
            builder: (_, s) {
              final product = s.extra;
              if (product is! Product) return const CatalogScreen();
              return ProductDetailScreen(product: product);
            },
          ),
          GoRoute(path: AppRoutes.consumerOrders, builder: (_, __) => const ConsumerOrdersScreen()),
          GoRoute(
            path: AppRoutes.orderDetail,
            builder: (_, s) {
              final order = s.extra;
              if (order is! AppOrder) return const ConsumerOrdersScreen();
              return OrderDetailScreen(order: order);
            },
          ),
          GoRoute(path: AppRoutes.wishlist,  builder: (_, __) => const WishlistScreen()),
          GoRoute(path: AppRoutes.profile,   builder: (_, __) => const ProfileScreen()),
          GoRoute(path: AppRoutes.checkout,  builder: (_, __) => const CheckoutScreen()),
        ],
      ),
    ],
  );
}