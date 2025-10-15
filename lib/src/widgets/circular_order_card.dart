import 'package:flutter/material.dart';
import '../providers/models/tontine.dart';
import '../theme/app_theme.dart';

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
    Color circleColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade700;

    if (isCurrent) {
      circleColor = AppColors.primary;
      textColor = Colors.white;
    } else if (isNext) {
      circleColor = AppColors.primary.withAlpha(20);
      textColor = AppColors.primary;
    }

    return Card(
      elevation: isCurrent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle avec le numéro d'ordre
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  partOrder.order.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Nom du membre
            Text(
              '${partOrder.member.firstname ?? ''} ${partOrder.member.lastname ?? ''}'
                  .trim(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (partOrder.period != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(partOrder.period!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (isCurrent) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Actuel',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ] else if (isNext) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Suivant',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class CircularOrderGrid extends StatelessWidget {
  final List<PartOrder> parts;
  final PartOrder? currentPart;
  final PartOrder? nextPart;

  const CircularOrderGrid({
    super.key,
    required this.parts,
    this.currentPart,
    this.nextPart,
  });

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Text(
              'Aucun ordre configuré',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordre des parts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: parts.map((part) {
                final isCurrent = currentPart?.id == part.id;
                final isNext = nextPart?.id == part.id;

                return SizedBox(
                  width: 120,
                  child: CircularOrderCard(
                    partOrder: part,
                    isCurrent: isCurrent,
                    isNext: isNext,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
