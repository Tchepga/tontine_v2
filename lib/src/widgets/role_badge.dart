import 'package:flutter/material.dart';
import '../providers/models/enum/role.dart';

class RoleBadge extends StatelessWidget {
  final Role role;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsets? padding;

  const RoleBadge({
    super.key,
    required this.role,
    this.showIcon = true,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: role.color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: role.color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              role.icon,
              size: 14,
              color: role.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: role.color,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleBadgeList extends StatelessWidget {
  final List<Role> roles;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsets? padding;
  final double spacing;

  const RoleBadgeList({
    super.key,
    required this.roles,
    this.showIcon = true,
    this.fontSize,
    this.padding,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: roles
          .map((role) => RoleBadge(
                role: role,
                showIcon: showIcon,
                fontSize: fontSize,
                padding: padding,
              ))
          .toList(),
    );
  }
}
