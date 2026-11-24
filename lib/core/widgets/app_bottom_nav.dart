import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Bottom navigation with the pale-green active tile from Fidelity V1.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.only(top: 6),
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(items.length, (int index) {
            final AppNavItem item = items[index];
            final bool active = index == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          active ? item.activeIcon : item.icon,
                          size: 21,
                          color: active
                              ? AppColors.primaryDark
                              : const Color(0xFF22303A),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500,
                            color: active
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Scrollable page scaffold that keeps the bottom navigation fixed.
class AppShellPage extends StatelessWidget {
  const AppShellPage({
    super.key,
    required this.child,
    this.floatingActionButton,
  });

  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
