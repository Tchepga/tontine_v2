import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bandeau affiché lorsqu'une tontine clôturée est ouverte en consultation seule.
class TontineClosedBanner extends StatelessWidget {
  const TontineClosedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning.withAlpha(25),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.warning.withAlpha(80)),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tontine clôturée — consultation seule',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
