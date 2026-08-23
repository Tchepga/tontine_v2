import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/models/enum/currency.dart';
import '../../../providers/models/member_contribution.dart';
import '../../../providers/tontine_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/currency_utils.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/modern_card.dart';
import '../../../widgets/status_badge.dart';

/// Récapitulatif des cotisations et parts du pot par membre (président / trésorier).
class MemberContributionsSection extends StatelessWidget {
  final Currency currency;

  const MemberContributionsSection({
    super.key,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final contributions = context.watch<TontineProvider>().contributions;
    final sorted = List<MemberContribution>.from(contributions)
      ..sort((a, b) => b.totalApproved.compareTo(a.totalApproved));

    return ModernCard(
      type: ModernCardType.info,
      icon: Icons.people_outline,
      title: 'Parts par membre',
      padding: ResponsiveHelper.getAdaptivePadding(context, all: 16.0),
      child: sorted.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      height: ResponsiveHelper.getAdaptiveSpacing(
                        context,
                        base: 8.0,
                      ),
                    ),
                  _buildMemberRow(context, sorted[i]),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getAdaptivePadding(
        context,
        vertical: 12.0,
      ),
      child: Text(
        'Aucune cotisation enregistrée',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: ResponsiveHelper.getAdaptiveValue(
            context,
            small: 13.0,
            medium: 14.0,
            large: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, MemberContribution member) {
    final itemPadding = ResponsiveHelper.getAdaptivePadding(context, all: 12.0);
    final labelSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 11.0,
      medium: 12.0,
      large: 12.0,
    );
    final valueSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 13.0,
      medium: 14.0,
      large: 14.0,
    );

    return Container(
      padding: itemPadding,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary.withAlpha(30),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  member.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: valueSize,
                  ),
                ),
              ),
              if (member.totalPending > 0)
                PendingBadge(
                  text:
                      'En attente ${CurrencyUtils.formatAmountForCard(member.totalPending, currency)}',
                ),
            ],
          ),
          SizedBox(
            height: ResponsiveHelper.getAdaptiveSpacing(context, base: 10.0),
          ),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: 'Cotisé',
                  value: CurrencyUtils.formatAmountForCard(
                    member.totalApproved,
                    currency,
                  ),
                  labelSize: labelSize,
                  valueSize: valueSize,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  label: 'Part du pot',
                  value: CurrencyUtils.formatAmountForCard(
                    member.shareAmount,
                    currency,
                  ),
                  labelSize: labelSize,
                  valueSize: valueSize,
                  valueColor: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  label: 'Part (%)',
                  value: _formatSharePercent(member.sharePercent),
                  labelSize: labelSize,
                  valueSize: valueSize,
                  align: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required double labelSize,
    required double valueSize,
    Color? valueColor,
    TextAlign align = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment: align == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: align,
          style: TextStyle(
            fontSize: labelSize,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: align,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatSharePercent(double percent) {
    if (percent % 1 == 0) {
      return '${percent.toInt()} %';
    }
    return '${percent.toStringAsFixed(1)} %';
  }
}
