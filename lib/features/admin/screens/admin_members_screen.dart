import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../shared/widgets/skeleton_loader.dart';
import 'admin_shell.dart';

class AdminMembersScreen extends StatelessWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.adminDashboard);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Members'),
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () => adminScaffoldKey.currentState?.openDrawer(),
          ),
        ),
        body: StreamBuilder<List<AppUser>>(
          stream: service.allUsersStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => const SkeletonBox(height: 72, radius: 6),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text('Error loading members',
                    style: AppTextStyles.bodySmall()),
              );
            }

            final users    = snap.data ?? [];
            final admins   = users.where((u) => u.isAdmin).toList();
            final members  = users.where((u) => !u.isAdmin).toList();

            return RefreshIndicator(
              color: AppColors.adminAccent,
              onRefresh: () async {},
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    _CountChip(
                      label: 'TOTAL',
                      count: users.length,
                      color: AppColors.adminAccent,
                    ),
                    const SizedBox(width: 10),
                    _CountChip(
                      label: 'MEMBERS',
                      count: members.length,
                      color: AppColors.stockGreen,
                    ),
                    const SizedBox(width: 10),
                    _CountChip(
                      label: 'ADMINS',
                      count: admins.length,
                      color: AppColors.mutedText,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  if (admins.isNotEmpty) ...[
                    Text('ADMINS', style: AppTextStyles.label()),
                    const SizedBox(height: 10),
                    ...admins.map((u) => _UserTile(user: u)),
                    const SizedBox(height: 20),
                  ],

                  if (members.isNotEmpty) ...[
                    Text('MEMBERS', style: AppTextStyles.label()),
                    const SizedBox(height: 10),
                    ...members.map((u) => _UserTile(user: u)),
                  ],

                  if (users.isEmpty)
                    Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(height: 48),
                        const Icon(Icons.people_outline,
                            size: 48, color: AppColors.mutedText),
                        const SizedBox(height: 16),
                        Text('No users found', style: AppTextStyles.heading3()),
                      ]),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text('$count',
            style: AppTextStyles.heading3().copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.label().copyWith(color: color, fontSize: 9)),
      ]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isAdmin
                ? AppColors.adminAccent.withOpacity(0.12)
                : AppColors.border,
          ),
          child: Center(
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.body().copyWith(
                fontWeight: FontWeight.w600,
                color: user.isAdmin ? AppColors.adminAccent : AppColors.mutedText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.displayName,
                style: AppTextStyles.body().copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(user.email, style: AppTextStyles.bodySmall()),
            const SizedBox(height: 4),
            Text(
              'Joined ${DateFormat('MMM d, yyyy').format(user.createdAt)}',
              style: AppTextStyles.bodySmall()
                  .copyWith(fontSize: 10, color: AppColors.mutedText),
            ),
          ]),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: user.isAdmin
                ? AppColors.adminAccent.withOpacity(0.1)
                : AppColors.stockGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: user.isAdmin
                  ? AppColors.adminAccent.withOpacity(0.3)
                  : AppColors.stockGreen.withOpacity(0.3),
            ),
          ),
          child: Text(
            user.role.displayLabel.toUpperCase(),
            style: AppTextStyles.label().copyWith(
              fontSize: 8,
              color: user.isAdmin ? AppColors.adminAccent : AppColors.stockGreen,
            ),
          ),
        ),
      ]),
    );
  }
}