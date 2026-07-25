import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/models/member.dart';
import '../providers/models/tontine.dart';
import '../theme/app_theme.dart';

/// Enrichit une part avec le membre complet de la tontine (nom, avatar…).
PartOrder enrichPartOrder(PartOrder part, List<Member> members) {
  final id = part.member.id;
  if (id == null || members.isEmpty) return part;

  for (final member in members) {
    if (member.id == id) {
      return PartOrder(
        id: part.id,
        order: part.order,
        member: member,
        period: part.period,
      );
    }
  }
  return part;
}

List<PartOrder> enrichPartOrders(
  List<PartOrder> parts,
  List<Member> members,
) {
  final enriched = parts.map((p) => enrichPartOrder(p, members)).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return enriched;
}

String memberDisplayName(Member member) {
  final name =
      '${member.firstname ?? ''} ${member.lastname ?? ''}'.trim();
  if (name.isNotEmpty) return name;
  final username = member.user?.username?.trim();
  if (username != null && username.isNotEmpty) return username;
  return 'Membre #${member.id ?? '?'}';
}

String memberInitials(Member member) {
  final first = member.firstname?.trim();
  final last = member.lastname?.trim();
  if (first != null &&
      first.isNotEmpty &&
      last != null &&
      last.isNotEmpty) {
    return '${first[0]}${last[0]}'.toUpperCase();
  }
  final name = memberDisplayName(member);
  if (name.length >= 2) return name.substring(0, 2).toUpperCase();
  return '?';
}

/// Carte compacte (dashboard : actuel / suivant).
class CircularOrderCard extends StatelessWidget {
  final PartOrder partOrder;
  final bool isCurrent;
  final bool isNext;

  const CircularOrderCard({
    super.key,
    required this.partOrder,
    this.isCurrent = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = memberDisplayName(partOrder.member);
    final accent = isCurrent
        ? AppColors.primary
        : isNext
            ? AppColors.secondaryDark
            : AppColors.textSecondary;

    return Card(
      elevation: isCurrent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _OrderBadge(
                  order: partOrder.order,
                  color: accent,
                  filled: isCurrent,
                ),
                const Spacer(),
                if (isCurrent || isNext)
                  _StatusChip(
                    label: isCurrent ? 'Actuel' : 'Suivant',
                    color: accent,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.18),
                  child: Text(
                    memberInitials(partOrder.member),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (partOrder.period != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(partOrder.period!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Liste lisible de l'ordre des parts (réglages tontine).
class CircularOrderGrid extends StatelessWidget {
  final List<PartOrder> parts;
  final List<Member> members;
  final PartOrder? currentPart;
  final PartOrder? nextPart;

  const CircularOrderGrid({
    super.key,
    required this.parts,
    this.members = const [],
    this.currentPart,
    this.nextPart,
  });

  @override
  Widget build(BuildContext context) {
    final displayParts = members.isEmpty
        ? (List<PartOrder>.from(parts)
          ..sort((a, b) => a.order.compareTo(b.order)))
        : enrichPartOrders(parts, members);

    if (displayParts.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            children: [
              Icon(Icons.route_outlined,
                  size: 40, color: AppColors.textLight),
              const SizedBox(height: 12),
              const Text(
                'Aucun ordre de passage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ajoutez une part pour définir qui reçoit le pot et quand.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.format_list_numbered,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Calendrier des passages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${displayParts.length} part${displayParts.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Chaque ligne indique qui reçoit le pot et à quelle date.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            ...displayParts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              final isCurrentResolved = currentPart != null &&
                  (currentPart!.id == part.id ||
                      (currentPart!.id == 0 &&
                          currentPart!.order == part.order));
              final isNextResolved = nextPart != null &&
                  (nextPart!.id == part.id ||
                      (nextPart!.id == 0 && nextPart!.order == part.order));
              final isPast = part.period != null &&
                  part.period!.isBefore(DateTime.now()) &&
                  !isCurrentResolved;

              return _PartTimelineTile(
                part: part,
                isLast: index == displayParts.length - 1,
                isCurrent: isCurrentResolved,
                isNext: isNextResolved,
                isPast: isPast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PartTimelineTile extends StatelessWidget {
  final PartOrder part;
  final bool isLast;
  final bool isCurrent;
  final bool isNext;
  final bool isPast;

  const _PartTimelineTile({
    required this.part,
    required this.isLast,
    required this.isCurrent,
    required this.isNext,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final name = memberDisplayName(part.member);
    final accent = isCurrent
        ? AppColors.primary
        : isNext
            ? AppColors.secondaryDark
            : isPast
                ? AppColors.success
                : AppColors.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _OrderBadge(
                  order: part.order,
                  color: accent,
                  filled: isCurrent || isNext,
                  size: 32,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 8 : 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withAlpha(10)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary.withAlpha(60)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: accent.withValues(alpha: 0.18),
                    child: Text(
                      memberInitials(part.member),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                part.period != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(part.period!)
                                    : 'Date non définie',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent || isNext || isPast) ...[
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: isCurrent
                          ? 'Actuel'
                          : isNext
                              ? 'Suivant'
                              : 'Passé',
                      color: accent,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  final int order;
  final Color color;
  final bool filled;
  final double size;

  const _OrderBadge({
    required this.order,
    required this.color,
    this.filled = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : color.withValues(alpha: 0.12),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$order',
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
