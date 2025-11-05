import 'package:days_tracker/core/utils/country_utils.dart';
import 'package:days_tracker/core/utils/date_utils.dart';
import 'package:days_tracker/domain/entities/visit.dart';
import 'package:flutter/material.dart';

class VisitItem extends StatelessWidget {
  final Visit visit;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const VisitItem({
    required this.visit,
    this.isActive = false,
    this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final countryName = CountryUtils.getCountryName(visit.countryCode);
    final dateRange =
        AppDateUtils.formatDateRange(visit.startDate, visit.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? Colors.green.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          countryName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (visit.city != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        visit.city!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateRange,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
