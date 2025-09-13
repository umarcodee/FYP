import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Settings tile widget for various setting types
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  /// Create a switch tile
  static SettingsTile switchTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isFirst: isFirst,
      isLast: isLast,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryNeon,
        activeTrackColor: AppTheme.primaryNeon.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
      onTap: () => onChanged(!value),
    );
  }

  /// Create a slider tile
  static SettingsTile sliderTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isFirst: isFirst,
      isLast: isLast,
      trailing: SizedBox(
        width: 120,
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primaryNeon,
            inactiveTrackColor: AppTheme.primaryNeon.withOpacity(0.3),
            thumbColor: AppTheme.primaryNeon,
            overlayColor: AppTheme.primaryNeon.withOpacity(0.2),
            valueIndicatorColor: AppTheme.primaryNeon,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  /// Create a navigation tile
  static SettingsTile navigationTile({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isFirst: isFirst,
      isLast: isLast,
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.white.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  /// Create a radio tile
  static SettingsTile radioTile<T>({
    required String title,
    String? subtitle,
    IconData? icon,
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isFirst: isFirst,
      isLast: isLast,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: (T? newValue) {
          if (newValue != null) onChanged(newValue);
        },
        activeColor: AppTheme.primaryNeon,
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppTheme.primaryNeon;
          }
          return Colors.grey;
        }),
      ),
      onTap: () => onChanged(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
          bottom: isLast ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(
                      color: AppTheme.primaryNeon.withOpacity(0.1),
                      width: 1,
                    ),
            ),
          ),
          child: Row(
            children: [
              // Icon
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryNeon,
                    size: AppConstants.iconSize,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget
              if (trailing != null) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings section header
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            AppConstants.paddingLarge,
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryNeon,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: AppTheme.primaryNeon.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              
              if (child is SettingsTile) {
                return SettingsTile(
                  title: child.title,
                  subtitle: child.subtitle,
                  icon: child.icon,
                  trailing: child.trailing,
                  onTap: child.onTap,
                  isFirst: index == 0,
                  isLast: index == children.length - 1,
                );
              }
              
              return child;
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Custom toggle switch widget
class NeonToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const NeonToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppTheme.primaryNeon;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? effectiveActiveColor.withOpacity(0.3) : effectiveInactiveColor.withOpacity(0.3),
          border: Border.all(
            color: value ? effectiveActiveColor : effectiveInactiveColor,
            width: 2,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: effectiveActiveColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? effectiveActiveColor : effectiveInactiveColor,
              boxShadow: [
                BoxShadow(
                  color: (value ? effectiveActiveColor : effectiveInactiveColor)
                      .withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}