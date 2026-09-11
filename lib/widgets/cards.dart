import 'package:flutter/material.dart';
import 'package:goran/config/theme_config.dart';
import 'package:goran/models/index.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const EmployeeCard({
    Key? key,
    required this.employee,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // سەری کارتەکە: ناوی کرێکار و کردارەکان.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.position,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            if (onEdit != null)
                              PopupMenuItem(
                                child: const Text('Edit'),
                                onTap: onEdit,
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                child: const Text('Delete'),
                                onTap: onDelete,
                              ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.borderColor),
              const SizedBox(height: 12),
              // زانیاری کرێی ڕۆژانە و پەیوەندی.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Salary',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${employee.dailySalary.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.successColor),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Phone',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final Attendance attendance;
  final Employee employee;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AttendanceCard({
    Key? key,
    required this.attendance,
    required this.employee,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        attendance.type == AttendanceType.fullDay
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.warningColor.withOpacity(0.1);

    final typeColor =
        attendance.type == AttendanceType.fullDay
            ? AppTheme.successColor
            : AppTheme.warningColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ناوی کرێکار و جۆری ئامادەبوون.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          attendance.type.displayName,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          if (onEdit != null)
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: onEdit,
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: onDelete,
                            ),
                        ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // بڕی شایستەیی بۆ ئەو تۆمارە.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Earned', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  '\$${attendance.earnedAmount.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: typeColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SalaryCard extends StatelessWidget {
  final SalaryRecord record;
  final Employee employee;

  const SalaryCard({Key? key, required this.record, required this.employee})
    : super(key: key);

  String getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ناوی کرێکار و مانگی حساب.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${getMonthName(record.date.month)} ${record.date.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppTheme.borderColor),
            const SizedBox(height: 12),
            // کورتەی ژمارەکانی حساب.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(
                  label: 'Full Days',
                  value: record.fullDaysCount.toString(),
                ),
                _StatColumn(
                  label: 'Half Days',
                  value: record.halfDaysCount.toString(),
                ),
                _StatColumn(
                  label: 'Total',
                  value: '\$${record.totalEarnings.toStringAsFixed(2)}',
                  valueColor: AppTheme.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
