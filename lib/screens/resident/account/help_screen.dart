import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/app_scope.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<List<String>> _faqs = <List<String>>[
    <String>[
      'How do I submit a report?',
      'Open Submit Report from the dashboard, choose a category, describe the '
          'concern, add your location and up to five photos, then submit. You '
          'will receive a reference number for tracking.',
    ],
    <String>[
      'How long does a report take to resolve?',
      'Resolution time depends on the concern. The barangay updates the status '
          'from Pending to In progress and finally Solved. You will be notified '
          'at every change.',
    ],
    <String>[
      'How do I request a barangay document?',
      'Open Request Documents, choose the document type, complete the form and '
          'submit. Track the request under My document requests until it is '
          'ready for pickup at the barangay office.',
    ],
    <String>[
      'Is the document issued inside the app?',
      'No. The app only manages requests. Official documents are still signed '
          'and released at the barangay hall after verification.',
    ],
    <String>[
      'Why can I not call a hotline from the app?',
      'Calling uses your phone dialer. On devices without a phone app the '
          'number is shown so you can dial it manually.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final String hotline = AppScope.of(context).emergencyContacts.isEmpty
        ? '911'
        : AppScope.of(context).emergencyContacts.first.contactNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & FAQs'),
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
            const Text(
              'How can we help?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Answers to the questions residents ask most.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ..._faqs.map(
              (List<String> faq) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      iconColor: AppColors.primary,
                      collapsedIconColor: AppColors.textHint,
                      title: Text(
                        faq[0],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq[1],
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            AppCard(
              color: AppColors.primarySoft,
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Call the barangay hotline or visit the barangay hall during '
                    'office hours.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Launchers.call(hotline),
                    icon: const Icon(Icons.call_outlined, size: 16),
                    label: Text('Call $hotline'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${AppConstants.appName} · Version 1.0.0\n${AppConstants.tagline}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.6,
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
