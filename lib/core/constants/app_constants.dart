class AppConstants {
  AppConstants._();

  static const String appName        = 'Retail Hub';
  static const String appTagline     = 'Where design meets comfort.';
  static const String currencySymbol = '₱';
  static const String currencyCode   = 'PHP';

  static const String colUsers    = 'users';
  static const String colProducts = 'products';
  static const String colOrders   = 'orders';

  static const int lowStockThreshold = 5;

  static const int catalogPageSize = 20;

  static const Duration heroAnimDuration      = Duration(milliseconds: 350);
  static const Duration pageTransDuration     = Duration(milliseconds: 280);
  static const Duration skeletonFadeDuration  = Duration(milliseconds: 200);
}