import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';

class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:     AppColors.border,
      highlightColor: AppColors.cardBg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              color: AppColors.cardBg,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: List.generate(
                  4,
                      (_) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 72,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (_, __) => _SkeletonCard(),
                childCount: 6,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(5)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 8, width: 60, color: AppColors.border),
                const SizedBox(height: 6),
                Container(
                    height: 12, width: double.infinity, color: AppColors.border),
                const SizedBox(height: 4),
                Container(
                    height: 12, width: 80, color: AppColors.border),
                const SizedBox(height: 8),
                Container(
                    height: 14, width: 56, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}