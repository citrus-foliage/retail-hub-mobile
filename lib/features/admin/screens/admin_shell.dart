import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';

final adminScaffoldKey = GlobalKey<ScaffoldState>();

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:             adminScaffoldKey,
      backgroundColor: AppColors.background,
      drawer:          const _AdminDrawer(),
      body:            child,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    final loc  = GoRouterState.of(context).uri.toString();
    final auth = context.read<AuthProvider>();
    final user = auth.appUser;

    return Drawer(
      backgroundColor: AppColors.cardBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RETAIL HUB', style: AppTextStyles.label()),
                  const SizedBox(height: 4),
                  Text('Admin Panel',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adminAccent,
                      )),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  if (user != null) ...[
                    Text(user.displayName, style: AppTextStyles.body()),
                    Text(user.email,       style: AppTextStyles.bodySmall()),
                  ],
                ],
              ),
            ),

            _DrawerItem(
              icon:   Icons.dashboard_outlined,
              label:  'DASHBOARD',
              active: loc == AppRoutes.adminDashboard,
              onTap:  () {
                adminScaffoldKey.currentState?.closeDrawer();
                context.go(AppRoutes.adminDashboard);
              },
            ),
            _DrawerItem(
              icon:   Icons.inventory_2_outlined,
              label:  'PRODUCTS',
              active: loc.startsWith(AppRoutes.adminProducts),
              onTap:  () {
                adminScaffoldKey.currentState?.closeDrawer();
                context.go(AppRoutes.adminProducts);
              },
            ),
            _DrawerItem(
              icon:   Icons.receipt_long_outlined,
              label:  'ORDERS',
              active: loc == AppRoutes.adminOrders,
              onTap:  () {
                adminScaffoldKey.currentState?.closeDrawer();
                context.go(AppRoutes.adminOrders);
              },
            ),
            _DrawerItem(
              icon:   Icons.people_outline,
              label:  'MEMBERS',
              active: loc == AppRoutes.adminMembers,
              onTap:  () {
                adminScaffoldKey.currentState?.closeDrawer();
                context.go(AppRoutes.adminMembers);
              },
            ),

            const Spacer(),
            const Divider(color: AppColors.border),

            _DrawerItem(
              icon:  Icons.logout,
              label: 'SIGN OUT',
              onTap: () async {
                adminScaffoldKey.currentState?.closeDrawer();
                await auth.signOut();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          size:  18,
          color: active ? AppColors.adminAccent : AppColors.mutedText),
      title: Text(
        label,
        style: AppTextStyles.label().copyWith(
          color:         active ? AppColors.adminAccent : AppColors.mutedText,
          letterSpacing: 1.2,
          fontSize:      11,
        ),
      ),
      selected:          active,
      selectedTileColor: AppColors.border.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      onTap: onTap,
    );
  }
}