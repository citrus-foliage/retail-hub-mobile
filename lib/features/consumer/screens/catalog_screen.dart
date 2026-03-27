import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/product_provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/catalog_skeleton.dart';

enum _SortOption { newest, priceLow, priceHigh, nameAz }

extension _SortLabel on _SortOption {
  String get label => switch (this) {
    _SortOption.newest    => 'Newest',
    _SortOption.priceLow  => 'Price: Low to High',
    _SortOption.priceHigh => 'Price: High to Low',
    _SortOption.nameAz    => 'Name: A–Z',
  };
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String      _search = '';
  String      _filter = kFilterAll;
  _SortOption _sort   = _SortOption.newest;

  List<Product> _sorted(List<Product> products) {
    final list = List<Product>.from(products);
    switch (_sort) {
      case _SortOption.newest:    list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case _SortOption.priceLow:  list.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
      case _SortOption.priceHigh: list.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
      case _SortOption.nameAz:    list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (provider.isLoading) return const CatalogSkeleton();
    if (provider.state == ProductLoadState.error) {
      return _ErrorState(message: provider.error ?? 'Unknown error');
    }

    final filtered = _sorted(provider.filtered(query: _search, filter: _filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primaryText,
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            _CatalogAppBar(
              search:   _search,
              sort:     _sort,
              onSearch: (v) => setState(() => _search = v),
              onSort:   (s) => setState(() => _sort = s),
            ),

            const SliverToBoxAdapter(child: _HeroBanner()),

            SliverToBoxAdapter(
              child: _FilterChips(
                selected:   _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'product' : 'products'}',
                  style: AppTextStyles.bodySmall(),
                ),
              ),
            ),

            if (filtered.isEmpty)
              const SliverFillRemaining(child: _EmptySearch())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductGridCard(
                      product: filtered[i],
                      onTap:   () => context.go(AppRoutes.productDetail, extra: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing:  12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.adminAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 20, bottom: -40,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('MUDDYCAP',
                    style: AppTextStyles.label().copyWith(
                      color: AppColors.white.withOpacity(0.7),
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 6),
                Text('Sit differently.',
                    style: AppTextStyles.heading1().copyWith(
                      color: AppColors.white, fontSize: 26,
                    )),
                const SizedBox(height: 8),
                Text('Designer chairs for considered spaces.',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.white.withOpacity(0.75),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kCatalogFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = kCatalogFilters[i];
          final active = filter == selected;
          return FilterChip(
            label: Text(filter,
                style: AppTextStyles.label().copyWith(
                  color: active ? AppColors.white : AppColors.mutedText,
                  fontSize: 10,
                )),
            selected:        active,
            onSelected:      (_) => onSelected(filter),
            backgroundColor: AppColors.cardBg,
            selectedColor:   AppColors.primaryText,
            checkmarkColor:  AppColors.white,
            side: BorderSide(
                color: active ? AppColors.primaryText : AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }
}


class _CatalogAppBar extends StatelessWidget {
  final String search;
  final _SortOption sort;
  final ValueChanged<String> onSearch;
  final ValueChanged<_SortOption> onSort;

  const _CatalogAppBar({
    required this.search, required this.sort,
    required this.onSearch, required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true, snap: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Text('RETAIL HUB',
          style: AppTextStyles.label().copyWith(
              color: AppColors.primaryText, fontSize: 12, letterSpacing: 2)),
      centerTitle: true,
      actions: [
        PopupMenuButton<_SortOption>(
          icon: const Icon(Icons.sort, size: 20),
          color: AppColors.cardBg,
          onSelected: onSort,
          itemBuilder: (_) => _SortOption.values.map((s) => PopupMenuItem(
            value: s,
            child: Row(children: [
              Icon(sort == s ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 16,
                  color: sort == s ? AppColors.adminAccent : AppColors.mutedText),
              const SizedBox(width: 10),
              Text(s.label, style: AppTextStyles.bodySmall()
                  .copyWith(color: AppColors.primaryText)),
            ]),
          )).toList(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            onChanged: onSearch,
            style: AppTextStyles.body(),
            decoration: InputDecoration(
              hintText:   'Search products…',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.mutedText),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.primaryText)),
              filled: true, fillColor: AppColors.cardBg,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.search_off, size: 48, color: AppColors.mutedText),
      const SizedBox(height: 12),
      Text('No products found', style: AppTextStyles.heading3()),
      const SizedBox(height: 4),
      Text('Try a different search or filter.', style: AppTextStyles.bodySmall()),
    ]),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.mutedText),
        const SizedBox(height: 12),
        Text('Could not load products', style: AppTextStyles.heading3()),
        const SizedBox(height: 4),
        Text(message, style: AppTextStyles.bodySmall(), textAlign: TextAlign.center),
      ]),
    ),
  );
}