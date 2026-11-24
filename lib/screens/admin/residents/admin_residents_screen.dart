import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';

class AdminResidentsScreen extends StatefulWidget {
  const AdminResidentsScreen({super.key});

  @override
  State<AdminResidentsScreen> createState() => _AdminResidentsScreenState();
}

class _AdminResidentsScreenState extends State<AdminResidentsScreen> {
  String _query = '';

  Future<void> _toggleStatus(AppState state, UserModel resident) async {
    final bool suspending = resident.isActive;
    final bool confirmed = await AppDialogs.confirm(
      context,
      title: suspending ? 'Suspend this account?' : 'Reactivate this account?',
      message: suspending
          ? '${resident.fullName} will not be able to sign in or submit reports '
              'until the account is reactivated.'
          : '${resident.fullName} will be able to sign in and use barangay '
              'services again.',
      confirmLabel: suspending ? 'Suspend' : 'Reactivate',
      destructive: suspending,
    );
    if (!confirmed || !mounted) return;
    try {
      await state.setResidentStatus(
        resident,
        suspending ? AccountStatus.suspended : AccountStatus.active,
      );
      if (!mounted) return;
      AppDialogs.toast(
        context,
        suspending ? 'Account suspended.' : 'Account reactivated.',
      );
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not update the account.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final String query = _query.trim().toLowerCase();
    final List<UserModel> residents = state.residents
        .where((UserModel u) => u.role == UserRole.resident)
        .where((UserModel u) =>
            query.isEmpty ||
            u.fullName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query) ||
            u.address.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Residents'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: AppTextField(
                hint: 'Search residents',
                prefixIcon: Icons.search_rounded,
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: residents.isEmpty
                  ? const EmptyState(
                      icon: Icons.groups_2_outlined,
                      title: 'No residents found',
                      message: 'Registered resident accounts will appear here.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      itemCount: residents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final UserModel resident = residents[index];
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  AppAvatar(
                                    initials: resident.initials,
                                    size: 42,
                                    background: AppColors.primarySoft,
                                    foreground: AppColors.primaryDark,
                                    fontSize: 14,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          resident.fullName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          resident.email,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: resident.isActive
                                          ? AppColors.successSoft
                                          : AppColors.dangerSoft,
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      resident.isActive
                                          ? 'Active'
                                          : 'Suspended',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: resident.isActive
                                            ? AppColors.success
                                            : AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                text: resident.contactNumber.isEmpty
                                    ? 'No contact number'
                                    : resident.contactNumber,
                              ),
                              const SizedBox(height: 4),
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: resident.address.isEmpty
                                    ? 'No address on record'
                                    : resident.address,
                              ),
                              const SizedBox(height: 4),
                              _InfoRow(
                                icon: Icons.event_outlined,
                                text:
                                    'Joined ${Formatters.date(resident.createdAt)}',
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _toggleStatus(state, resident),
                                  icon: Icon(
                                    resident.isActive
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline_rounded,
                                    size: 16,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: resident.isActive
                                        ? AppColors.danger
                                        : AppColors.primary,
                                  ),
                                  label: Text(
                                    resident.isActive
                                        ? 'Suspend account'
                                        : 'Reactivate account',
                                    style: const TextStyle(fontSize: 11.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
