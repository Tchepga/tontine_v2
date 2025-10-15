import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ModernCardType {
  info,
  success,
  warning,
  error,
  primary,
  secondary,
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final ModernCardType type;
  final IconData? icon;
  final String? title;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final VoidCallback? onTap;
  final bool showGradient;

  const ModernCard({
    super.key,
    required this.child,
    this.type = ModernCardType.info,
    this.icon,
    this.title,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardColors = _getCardColors();

    Widget cardContent = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: showGradient ? cardColors.gradient : null,
        color: showGradient ? null : cardColors.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: cardColors.shadowColor,
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || icon != null) ...[
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cardColors.iconBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: cardColors.iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (title != null)
                        Expanded(
                          child: Text(
                            title!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cardColors.textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );

    return cardContent;
  }

  _CardColors _getCardColors() {
    switch (type) {
      case ModernCardType.info:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.info.withAlpha(20),
              AppColors.info.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.info.withAlpha(10),
          iconBackgroundColor: AppColors.info.withAlpha(20),
          iconColor: AppColors.info,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.info.withAlpha(30),
        );
      case ModernCardType.success:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success.withAlpha(20),
              AppColors.success.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.success.withAlpha(10),
          iconBackgroundColor: AppColors.success.withAlpha(20),
          iconColor: AppColors.success,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.success.withAlpha(30),
        );
      case ModernCardType.warning:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warning.withAlpha(20),
              AppColors.warning.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.warning.withAlpha(10),
          iconBackgroundColor: AppColors.warning.withAlpha(20),
          iconColor: AppColors.warning,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.warning.withAlpha(30),
        );
      case ModernCardType.error:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error.withAlpha(20),
              AppColors.error.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.error.withAlpha(10),
          iconBackgroundColor: AppColors.error.withAlpha(20),
          iconColor: AppColors.error,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.error.withAlpha(30),
        );
      case ModernCardType.primary:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(20),
              AppColors.primary.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.primary.withAlpha(10),
          iconBackgroundColor: AppColors.primary.withAlpha(20),
          iconColor: AppColors.primary,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.primary.withAlpha(30),
        );
      case ModernCardType.secondary:
        return _CardColors(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withAlpha(20),
              AppColors.secondary.withAlpha(10),
            ],
          ),
          backgroundColor: AppColors.secondary.withAlpha(10),
          iconBackgroundColor: AppColors.secondary.withAlpha(20),
          iconColor: AppColors.secondary,
          textColor: AppColors.textPrimary,
          shadowColor: AppColors.secondary.withAlpha(30),
        );
    }
  }
}

class _CardColors {
  final LinearGradient gradient;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color shadowColor;

  _CardColors({
    required this.gradient,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.shadowColor,
  });
}

// Widget helper pour créer des mini-cards de statistiques
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ModernCardType type;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.type = ModernCardType.info,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      type: type,
      icon: icon,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
