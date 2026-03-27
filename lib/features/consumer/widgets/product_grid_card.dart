import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_theme.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductGridCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-image-${product.id}',
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, prog) =>
                        prog == null ? child : _shimmer(),
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                          : _placeholder(),
                    ),
                    if (!product.inStock)
                      Container(
                        color: Colors.black.withOpacity(0.45),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('OUT OF STOCK',
                                style: AppTextStyles.label()
                                    .copyWith(color: AppColors.saleRed)),
                          ),
                        ),
                      ),
                    if (product.isOnSale && product.inStock)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.saleRed,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text('SALE',
                              style: AppTextStyles.label()
                                  .copyWith(color: AppColors.white, fontSize: 8)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: AppTextStyles.label().copyWith(fontSize: 8),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    style: AppTextStyles.body()
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(
                      '₱${fmt.format(product.effectivePrice)}',
                      style: AppTextStyles.body().copyWith(
                        color: product.isOnSale ? AppColors.saleRed : AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (product.isOnSale) ...[
                      const SizedBox(width: 6),
                      Text(
                        '₱${fmt.format(product.basePrice)}',
                        style: AppTextStyles.bodySmall().copyWith(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.border,
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.mutedText, size: 32),
    ),
  );

  Widget _shimmer() => Container(color: AppColors.border);
}