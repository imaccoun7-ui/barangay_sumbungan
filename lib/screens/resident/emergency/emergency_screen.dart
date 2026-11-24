import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../models/directory_model.dart';
import '../../../providers/app_scope.dart';

/// Emergency Assistance tab: national hotline plus administrator-managed
/// barangay emergency contacts.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _call(
    BuildContext context, {
    required String name,
    required String number,
  }) async {
    final bool proceed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.call_rounded,
                    size: 34, color: AppColors.danger),
                const SizedBox(height: 14),
                Text(
                  'Call $name?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your phone dialer will open next. Confirm the call there.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: const BorderSide(color: AppColors.divider),
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          minimumSize: const Size.fromHeight(46),
                        ),
                        child: const Text('Call now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (!proceed) return;
    final bool launched = await Launchers.call(number);
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No phone app is available on this device. Dial $number manually.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<EmergencyContactModel> contacts =
        AppScope.of(context).emergencyContacts;

    return Scaffold(
      backgroundColor: AppColors.dangerTint,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: <Widget>[
            Center(
              child: Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        size: 30, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Emergency Hotlines',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Tap a number to call for immediate assistance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9DEDB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Life-threatening emergency?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dangerStrong,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Call the national emergency hotline immediately',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _call(context,
                          name: 'National Emergency Hotline', number: '911'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerStrong,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Call 911',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (contacts.isEmpty)
              const EmptyState(
                icon: Icons.phone_disabled_outlined,
                title: 'No hotlines published',
                message:
                    'The barangay has not published emergency contacts yet. '
                    'Call the national hotline in the meantime.',
              )
            else
              ...contacts.map(
                (EmergencyContactModel contact) => EmergencyContactCard(
                  contact: contact,
                  onCall: () => _call(context,
                      name: contact.name, number: contact.contactNumber),
                ),
              ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Hotline numbers are managed by the barangay administrator. '
                'Sample numbers are shown until official information is published.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.5,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
