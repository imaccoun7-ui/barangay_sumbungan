import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Grey rounded tab strip with a white active pill, as used on My Reports.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.scrollable = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final Widget row = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: scrollable ? MainAxisSize.min : MainAxisSize.max,
        children: List<Widget>.generate(labels.length, (int index) {
          final bool active = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 2),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: active
                      ? const <BoxShadow>[
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

    if (!scrollable) return row;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: row,
    );
  }
}
