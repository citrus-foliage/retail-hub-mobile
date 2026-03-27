import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    if (user == null) return const SizedBox.shrink();

    final products  = context.watch<ProductProvider>().products;
    final wishItems = products.where((p) => user.wishlist.contains(p.id)).toList();
    final fmt       = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardBg,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.heading1().copyWith(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(user.displayName, style: AppTextStyles.heading2()),
                const SizedBox(height: 4),
                Text(user.email, style: AppTextStyles.bodySmall()),
                const SizedBox(height: 4),
                Text(
                  'Member since ${DateFormat('MMMM yyyy').format(user.createdAt)}',
                  style: AppTextStyles.bodySmall(),
                ),
              ]),
            ),

            const SizedBox(height: 32),

            Text('ACCOUNT', style: AppTextStyles.label()),
            const SizedBox(height: 12),
            _Section(children: [
              _ProfileTile(
                icon: Icons.person_outline, label: 'Display Name',
                value: user.displayName,
                onTap: () => _editNameDialog(context, auth),
              ),
              const _Divider(),
              _ProfileTile(
                icon: Icons.email_outlined, label: 'Email Address',
                value: user.email,
                onTap: () => _editEmailDialog(context, auth),
              ),
              const _Divider(),
              _ProfileTile(
                icon: Icons.lock_outline, label: 'Password',
                value: '••••••••',
                onTap: () => _editPasswordDialog(context, auth),
              ),
              const _Divider(),
              _ProfileTile(
                icon: Icons.verified_user_outlined, label: 'Account Type',
                value: user.role.displayLabel,
              ),
            ]),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('WISHLIST', style: AppTextStyles.label()),
                if (wishItems.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go(AppRoutes.wishlist),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('See all (${wishItems.length})',
                        style: AppTextStyles.bodySmall()
                            .copyWith(color: AppColors.primaryText)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (wishItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Icon(Icons.favorite_border, size: 18, color: AppColors.mutedText),
                  const SizedBox(width: 12),
                  Text('No saved items yet.', style: AppTextStyles.bodySmall()),
                ]),
              )
            else
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: wishItems.length > 5 ? 5 : wishItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final p = wishItems[i];
                    return GestureDetector(
                      onTap: () => context.go(AppRoutes.productDetail, extra: p),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                child: p.imageUrl.isNotEmpty
                                    ? Image.network(p.imageUrl,
                                    width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: AppColors.border))
                                    : Container(color: AppColors.border),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.w600),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('₱${fmt.format(p.effectivePrice)}',
                                      style: const TextStyle(
                                          fontSize: 10, color: AppColors.mutedText)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 28),

            Text('SETTINGS', style: AppTextStyles.label()),
            const SizedBox(height: 12),
            _Section(children: [
              _ProfileTile(
                icon: Icons.logout, label: 'Sign Out',
                color: AppColors.saleRed,
                onTap: () => _confirmSignOut(context, auth),
              ),
              const _Divider(),
              _ProfileTile(
                icon: Icons.delete_forever_outlined,
                label: 'Delete Account',
                color: AppColors.saleRed,
                onTap: () => _deleteAccountDialog(context, auth),
              ),
            ]),

            const SizedBox(height: 32),
            Center(
              child: Text('RETAIL HUB  ·  v1.0.0',
                  style: AppTextStyles.label().copyWith(fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }


  void _editNameDialog(BuildContext scaffoldCtx, AuthProvider auth) {
    final ctrl    = TextEditingController(text: auth.appUser?.displayName ?? '');
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Edit Display Name', style: AppTextStyles.heading3()),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl, autofocus: true,
            decoration: const InputDecoration(labelText: 'DISPLAY NAME'),
            style: AppTextStyles.body(),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogCtx).pop();
              final ok = await auth.updateDisplayName(ctrl.text);
              if (scaffoldCtx.mounted) {
                ScaffoldMessenger.of(scaffoldCtx).showSnackBar(SnackBar(
                  content: Text(ok ? 'Name updated.' : 'Failed to update name.'),
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editEmailDialog(BuildContext scaffoldCtx, AuthProvider auth) {
    final emailCtrl = TextEditingController(text: auth.appUser?.email ?? '');
    final passCtrl  = TextEditingController();
    final formKey   = GlobalKey<FormState>();
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Change Email', style: AppTextStyles.heading3()),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'NEW EMAIL'),
              style: AppTextStyles.body(),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
              (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: passCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'CURRENT PASSWORD'),
              style: AppTextStyles.body(),
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            const SizedBox(height: 10),
            Text('A verification link will be sent to the new address.',
                style: AppTextStyles.bodySmall()),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogCtx).pop();
              final ok = await auth.updateEmail(emailCtrl.text, passCtrl.text);
              if (scaffoldCtx.mounted) {
                ScaffoldMessenger.of(scaffoldCtx).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Verification email sent. Check your inbox.'
                      : auth.errorMessage ?? 'Failed to update email.'),
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPasswordDialog(BuildContext scaffoldCtx, AuthProvider auth) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Change Password', style: AppTextStyles.heading3()),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: currentCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'CURRENT PASSWORD'),
              style: AppTextStyles.body(),
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter your current password' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: newCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'NEW PASSWORD'),
              style: AppTextStyles.body(),
              validator: (v) =>
              (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: confirmCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'CONFIRM NEW PASSWORD'),
              style: AppTextStyles.body(),
              validator: (v) =>
              v != newCtrl.text ? 'Passwords do not match' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogCtx).pop();
              final ok = await auth.updatePassword(currentCtrl.text, newCtrl.text);
              if (scaffoldCtx.mounted) {
                ScaffoldMessenger.of(scaffoldCtx).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Password updated successfully.'
                      : auth.errorMessage ?? 'Failed to update password.'),
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext scaffoldCtx, AuthProvider auth) {
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Sign out?', style: AppTextStyles.heading3()),
        content: Text('You will be returned to the login screen.',
            style: AppTextStyles.bodySmall()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await auth.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.saleRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _deleteAccountDialog(BuildContext scaffoldCtx, AuthProvider auth) {
    final passCtrl = TextEditingController();
    final formKey  = GlobalKey<FormState>();
    showDialog(
      context: scaffoldCtx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('Delete account?',
            style: AppTextStyles.heading3().copyWith(color: AppColors.saleRed)),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'This will permanently delete your account and all associated data. This action cannot be undone.',
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passCtrl, obscureText: true,
              decoration:
              const InputDecoration(labelText: 'ENTER PASSWORD TO CONFIRM'),
              style: AppTextStyles.body(),
              validator: (v) =>
              (v == null || v.isEmpty) ? 'Password is required' : null,
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogCtx).pop();
              final ok = await auth.deleteAccount(passCtrl.text);
              if (scaffoldCtx.mounted && !ok) {
                ScaffoldMessenger.of(scaffoldCtx).showSnackBar(SnackBar(
                  content:
                  Text(auth.errorMessage ?? 'Failed to delete account.'),
                ));
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.saleRed),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1, indent: 52);
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? color;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon, required this.label,
    this.value, this.color, this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    leading: Icon(icon, size: 18, color: color ?? AppColors.mutedText),
    title: Text(label,
        style: AppTextStyles.body().copyWith(color: color ?? AppColors.primaryText)),
    subtitle: value != null ? Text(value!, style: AppTextStyles.bodySmall()) : null,
    trailing: onTap != null
        ? const Icon(Icons.chevron_right, size: 18, color: AppColors.mutedText)
        : null,
    onTap: onTap,
  );
}