import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.fontSize,
    this.padding,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: (fontSize ?? 12) + 2,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Badges prédéfinis pour les statuts communs
class PendingBadge extends StatelessWidget {
  final String text;

  const PendingBadge({
    super.key,
    this.text = 'En attente',
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: text,
      color: AppColors.warning,
      icon: Icons.pending_actions,
    );
  }
}

class SuccessBadge extends StatelessWidget {
  final String text;

  const SuccessBadge({
    super.key,
    this.text = 'Validé',
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: text,
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }
}

class ErrorBadge extends StatelessWidget {
  final String text;

  const ErrorBadge({
    super.key,
    this.text = 'Rejeté',
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: text,
      color: AppColors.error,
      icon: Icons.cancel,
    );
  }
}

class InfoBadge extends StatelessWidget {
  final String text;

  const InfoBadge({
    super.key,
    this.text = 'Info',
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: text,
      color: AppColors.info,
      icon: Icons.info,
    );
  }
}

class PrimaryBadge extends StatelessWidget {
  final String text;

  const PrimaryBadge({
    super.key,
    this.text = 'Actif',
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      text: text,
      color: AppColors.primary,
      icon: Icons.circle,
    );
  }
}
