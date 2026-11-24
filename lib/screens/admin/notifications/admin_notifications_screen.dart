import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/notification_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';

/// Send barangay notifications to all or selected residents and review the
/// notification records created by the app.
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _message = TextEditingController();
  String? _recipientId;
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final AppState state = AppScope.read(context);
    final List<UserModel> recipients = state.residents
        .where((UserModel u) => u.role == UserRole.resident && u.isActive)
        .where((UserModel u) => _recipientId == null || u.id == _recipientId)
        .toList();
    if (recipients.isEmpty) {
      AppDialogs.toast(context, 'There are no active recipients.', error: true);
      return;
    }
    setState(() => _sending = true);
    try {
      await state.sendNotificationToResidents(
        recipients: recipients,
        title: _title.text.trim(),
        message: _message.text.trim(),
      );
      if (!mounted) return;
      _title.clear();
      _message.clear();
      setState(() => _recipientId = null);
      AppDialogs.toast(
        context,
        'Notification sent to ${recipients.length} resident${recipients.length == 1 ? '' : 's'}.',
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not send the notification.',
          error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<UserModel> residents = state.residents
        .where((UserModel u) => u.role == UserRole.resident)
        .toList();
    final Map<String, String> names = <String, String>{
      for (final UserModel user in residents) user.id: user.fullName,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Management'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          children: <Widget>[
            const ScreenHeading(
              title: 'Send an update',
              subtitle:
                  'Only active resident accounts receive app notifications.',
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  AppTextField(
                    label: 'Title',
                    hint: 'e.g. Barangay assembly on Saturday',
                    controller: _title,
                    validator: (String? v) =>
                        Validators.minLength(v, 4, label: 'Title'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Message',
                    hint: 'Write the advisory for residents',
                    controller: _message,
                    validator: (String? v) =>
                        Validators.minLength(v, 10, label: 'Message'),
                    maxLines: 4,
                    minLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  const _FieldLabel('Recipients'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.divider, width: 1.2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _recipientId,
                        isExpanded: true,
                        hint: const Text(
                          'All active residents',
                          style: TextStyle(
                              fontSize: 13.5, color: AppColors.textHint),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        borderRadius: BorderRadius.circular(16),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All active residents'),
                          ),
                          ...residents.map(
                            (UserModel user) => DropdownMenuItem<String?>(
                              value: user.id,
                              child: Text(user.fullName,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (String? value) =>
                            setState(() => _recipientId = value),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Send notification',
                    icon: Icons.send_rounded,
                    loading: _sending,
                    onPressed: _send,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: 'Notification records'),
            if (state.notificationLog.isEmpty)
              const AppCard(
                child: Text(
                  'No notifications have been sent yet.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ...state.notificationLog.take(15).map(
                    (NotificationModel notification) => AppCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                notification.isRead ? 'Read' : 'Unread',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: notification.isRead
                                      ? AppColors.textHint
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notification.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${names[notification.recipientUserId] ?? 'Resident'} · ${Formatters.relative(notification.createdAt)}',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            const Text(
              'Push delivery through Firebase Cloud Messaging activates once the '
              'Firebase project and server key are configured. Notification '
              'records are already saved for every recipient.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
