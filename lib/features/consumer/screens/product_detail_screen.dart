import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/product_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/cart_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/cart_bottom_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  final _fmt = NumberFormat('#,##0.00');

  void _addToCart(BuildContext context, Product live) {
    if (!live.inStock) return;
    HapticFeedback.mediumImpact();
    final cart = context.read<CartProvider>();
    for (var i = 0; i < _qty; i++) cart.addItem(live);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_qty × ${live.name} added to cart.'),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: AppColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showCartBottomSheet(context);
          },
        ),
      ),
    );
  }

  Future<void> _toggleWishlist(BuildContext context, Product live) async {
    HapticFeedback.lightImpact();
    final auth  = context.read<AuthProvider>();
    final added = await auth.toggleWishlist(live.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(added
            ? '${live.name} added to wishlist.'
            : '${live.name} removed from wishlist.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    final auth    = context.watch<AuthProvider>();

    return StreamBuilder<List<Product>>(
      stream: service.productsStream(),
      builder: (context, snap) {
        final live = snap.data?.firstWhere(
              (p) => p.id == widget.product.id,
          orElse: () => widget.product,
        ) ?? widget.product;

        final isWishlisted = auth.isWishlisted(live.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:   340,
                pinned:           true,
                backgroundColor:  AppColors.background,
                surfaceTintColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () {
                    if (context.canPop()) context.pop();
                    else context.go(AppRoutes.catalog);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppColors.primaryText),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _toggleWishlist(context, live),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isWishlisted ? AppColors.saleRed : AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-image-${live.id}',
                    child: live.imageUrl.isNotEmpty
                        ? Image.network(live.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(live.category.toUpperCase(), style: AppTextStyles.label()),
                      const SizedBox(height: 6),
                      Text(live.name, style: AppTextStyles.heading1()),
                      const SizedBox(height: 4),
                      Text('SKU: ${live.sku}', style: AppTextStyles.bodySmall()),
                      const SizedBox(height: 16),

                      Row(children: [
                        Text(
                          '₱${_fmt.format(live.effectivePrice)}',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: live.isOnSale ? AppColors.saleRed : AppColors.primaryText,
                          ),
                        ),
                        if (live.isOnSale) ...[
                          const SizedBox(width: 10),
                          Text('₱${_fmt.format(live.basePrice)}',
                              style: AppTextStyles.priceStrike()),
                        ],
                      ]),

                      const SizedBox(height: 4),
                      _StockStatus(product: live),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 20),

                      Text('DESCRIPTION', style: AppTextStyles.label()),
                      const SizedBox(height: 8),
                      Text(
                        live.description.isEmpty
                            ? 'No description available.'
                            : live.description,
                        style: AppTextStyles.body(),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 20),

                      _InfoRow('SUPPLIER', live.supplier),

                      const SizedBox(height: 24),

                      if (live.inStock) ...[
                        Text('QUANTITY', style: AppTextStyles.label()),
                        const SizedBox(height: 10),
                        _QtySelector(
                          qty: _qty, max: live.stockQuantity,
                          onDec: () => setState(() =>
                          _qty = (_qty - 1).clamp(1, live.stockQuantity)),
                          onInc: () => setState(() =>
                          _qty = (_qty + 1).clamp(1, live.stockQuantity)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => _toggleWishlist(context, live),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isWishlisted ? AppColors.saleRed : AppColors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isWishlisted ? AppColors.saleRed : AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: live.inStock ? () => _addToCart(context, live) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      live.inStock ? AppColors.primaryText : AppColors.border,
                    ),
                    child: Text(
                      live.inStock ? 'ADD TO CART' : 'OUT OF STOCK',
                      style: TextStyle(
                        color: live.inStock ? AppColors.white : AppColors.mutedText,
                        fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.cardBg,
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.mutedText, size: 64),
    ),
  );
}

class _StockStatus extends StatelessWidget {
  final Product product;
  const _StockStatus({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return Row(children: [
        const Icon(Icons.remove_circle_outline, size: 14, color: AppColors.saleRed),
        const SizedBox(width: 6),
        Text('Out of stock',
            style: AppTextStyles.bodySmall().copyWith(color: AppColors.saleRed)),
      ]);
    }
    final low   = product.stockQuantity < 5;
    final color = low ? Colors.orange.shade700 : AppColors.stockGreen;
    return Row(children: [
      Icon(Icons.check_circle_outline, size: 14, color: color),
      const SizedBox(width: 6),
      Text(
        low ? 'Only ${product.stockQuantity} left'
            : 'In stock (${product.stockQuantity} available)',
        style: AppTextStyles.bodySmall().copyWith(color: color),
      ),
    ]);
  }
}

class _QtySelector extends StatelessWidget {
  final int qty, max;
  final VoidCallback onDec, onInc;
  const _QtySelector({required this.qty, required this.max,
    required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) => Row(children: [
    _QtyBtn(icon: Icons.remove, onTap: qty > 1 ? onDec : null),
    const SizedBox(width: 16),
    Text('$qty', style: AppTextStyles.heading3()),
    const SizedBox(width: 16),
    _QtyBtn(icon: Icons.add, onTap: qty < max ? onInc : null),
  ]);
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        border: Border.all(
            color: onTap == null ? AppColors.border : AppColors.primaryText),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16,
          color: onTap == null ? AppColors.border : AppColors.primaryText),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: AppTextStyles.label())),
      Expanded(child: Text(value, style: AppTextStyles.bodySmall())),
    ]),
  );
}