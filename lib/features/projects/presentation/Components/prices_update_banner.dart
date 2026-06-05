import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
class PricesUpdateBanner extends StatelessWidget {
  final String city;
  final int suppliersCount;
  final String? syncedAgo;

  const PricesUpdateBanner({
    super.key,
    required this.city,
    this.suppliersCount = 42,
    this.syncedAgo = 'hace 8 min',
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1F9E5A);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: green.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.trending_up, size: 18, color: green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precios actualizados en $city',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$suppliersCount proveedores activos${syncedAgo == null ? "" : "  ·  última sincronización $syncedAgo"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
