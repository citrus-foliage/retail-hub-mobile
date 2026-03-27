import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/admin_form_field.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading  = false;

  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _category;
  late final TextEditingController _basePrice;
  late final TextEditingController _discountedPrice;
  late final TextEditingController _stock;
  late final TextEditingController _description;
  late final TextEditingController _supplier;
  late final TextEditingController _imageUrl;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name            = TextEditingController(text: p?.name ?? '');
    _sku             = TextEditingController(text: p?.sku ?? '');
    _category        = TextEditingController(text: p?.category ?? '');
    _basePrice       = TextEditingController(text: p != null ? p.basePrice.toStringAsFixed(2) : '');
    _discountedPrice = TextEditingController(text: p != null ? p.discountedPrice.toStringAsFixed(2) : '');
    _stock           = TextEditingController(text: p?.stockQuantity.toString() ?? '');
    _description     = TextEditingController(text: p?.description ?? '');
    _supplier        = TextEditingController(text: p?.supplier ?? '');
    _imageUrl        = TextEditingController(text: p?.imageUrl ?? '');
    _imageUrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose(); _sku.dispose(); _category.dispose();
    _basePrice.dispose(); _discountedPrice.dispose(); _stock.dispose();
    _description.dispose(); _supplier.dispose(); _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final service   = context.read<FirestoreService>();
    final router    = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final product = Product(
        id:              _isEditing ? widget.product!.id : '',
        name:            _name.text.trim(),
        sku:             _sku.text.trim(),
        category:        _category.text.trim(),
        basePrice:       double.parse(_basePrice.text),
        discountedPrice: double.parse(_discountedPrice.text),
        stockQuantity:   int.parse(_stock.text),
        description:     _description.text.trim(),
        supplier:        _supplier.text.trim(),
        dateAdded:       _isEditing ? widget.product!.dateAdded : DateTime.now(),
        imageUrl:        _imageUrl.text.trim(),
      );

      if (_isEditing) {
        await service.updateProduct(product);
      } else {
        await service.addProduct(product);
      }

      if (mounted) {
        router.go(AppRoutes.adminProducts);
        messenger.showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Product updated.' : 'Product added.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.go(AppRoutes.adminProducts),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.adminProducts),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader('BASIC INFO'),
              AdminFormField(ctrl: _name,     label: 'PRODUCT NAME', required: true),
              AdminFormField(ctrl: _sku,      label: 'SKU',          required: true),
              AdminFormField(ctrl: _category, label: 'CATEGORY',     required: true),
              AdminFormField(ctrl: _supplier, label: 'SUPPLIER'),

              const SizedBox(height: 8),
              _SectionHeader('PRICING'),
              Row(children: [
                Expanded(child: AdminFormField(
                  ctrl: _basePrice, label: 'BASE PRICE',
                  inputType: TextInputType.number, required: true,
                )),
                const SizedBox(width: 12),
                Expanded(child: AdminFormField(
                  ctrl: _discountedPrice, label: 'DISCOUNTED PRICE',
                  inputType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final disc = double.tryParse(v);
                    final base = double.tryParse(_basePrice.text);
                    if (disc == null) return 'Invalid number';
                    if (base != null && disc > base) return 'Must be ≤ base price';
                    return null;
                  },
                )),
              ]),

              const SizedBox(height: 8),
              _SectionHeader('INVENTORY'),
              AdminFormField(
                ctrl: _stock, label: 'STOCK QUANTITY',
                inputType: TextInputType.number, required: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Must be an integer';
                  return null;
                },
              ),

              const SizedBox(height: 8),
              _SectionHeader('DETAILS'),
              AdminFormField(ctrl: _description, label: 'DESCRIPTION', maxLines: 4),
              AdminFormField(ctrl: _imageUrl,    label: 'IMAGE URL'),

              if (_imageUrl.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    _imageUrl.text, height: 160, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160, color: AppColors.border,
                      child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.mutedText)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.white))
                      : Text(_isEditing ? 'SAVE CHANGES' : 'ADD PRODUCT'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 14),
    child: Text(text, style: AppTextStyles.label()),
  );
}