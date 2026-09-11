import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goran/config/theme_config.dart';
import 'package:goran/models/index.dart';
import 'package:goran/providers/index.dart';
import 'package:goran/utils/formatters.dart';

// پەڕەی سەرەکی: کورتەی دۆخی ئەمڕۆ و پارەی مانگ.
class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // پیشاندانی سەرەکی تەنها دوای خوێندنەوەی داتا.
    return Consumer<AppDataProvider>(
      builder: (context, data, _) {
        if (!data.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        final today = DateTime.now();
        final summaries = data.monthSummaries;
        final monthDue = summaries.fold<double>(
          0,
          (sum, item) => sum + item.remaining,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('بەڕێوەبردنی کرێکاران'),
            actions: [
              IconButton(
                tooltip: 'ڕێکخستن',
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh:
                () async =>
                    Future<void>.delayed(const Duration(milliseconds: 250)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(
                  'سڵاو، بەخێربێیت',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel(today),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                _buildStats(context, data, monthDue),
                const SizedBox(height: 18),
                _buildQuickActions(context),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'دۆخی ئەمڕۆ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => onNavigate(1),
                      child: const Text('هەمووی ببینە'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.allEmployees.isEmpty)
                  _EmptyState(
                    icon: Icons.groups_outlined,
                    title: 'هێشتا کرێکارێکت زیاد نەکردووە',
                    actionLabel: 'زیادکردنی کرێکار',
                    onAction: () => onNavigate(2),
                  )
                else
                  ...data.allEmployees
                      .take(8)
                      .map(
                        (employee) => _TodayEmployeeTile(
                          employee: employee,
                          attendance: data.attendanceFor(employee.id, today),
                          summary: summaries.firstWhere(
                            (item) => item.employee.id == employee.id,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(
    BuildContext context,
    AppDataProvider data,
    double monthDue,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: 'کۆی کرێکاران',
          value: '${data.allEmployees.length}',
          icon: Icons.groups_outlined,
          color: AppTheme.primaryColor,
        ),
        _StatCard(
          label: 'ئامادەی ئەمڕۆ',
          value: '${data.todayPresentCount}',
          icon: Icons.check_circle_outline,
          color: AppTheme.successColor,
        ),
        _StatCard(
          label: 'دیاریکراوی ئەمڕۆ',
          value: '${data.todayMarkedCount} / ${data.allEmployees.length}',
          icon: Icons.fact_check_outlined,
          color: AppTheme.accentColor,
        ),
        _StatCard(
          label: 'قەرزی مانگ',
          value: money(monthDue),
          icon: Icons.account_balance_wallet_outlined,
          color: AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onNavigate(1),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('تۆمارکردنی ئامادەبوون'),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () => onNavigate(2),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('زیادکردن'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            FittedBox(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEmployeeTile extends StatelessWidget {
  final Employee employee;
  final Attendance? attendance;
  final EmployeeMonthSummary summary;

  const _TodayEmployeeTile({
    required this.employee,
    required this.attendance,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        attendance == null ? 'دیارینەکراو' : attendance!.type.displayName;
    final color =
        attendance == null
            ? AppTheme.textSecondary
            : attendance!.type == AttendanceType.absent
            ? AppTheme.errorColor
            : attendance!.type == AttendanceType.halfDay
            ? AppTheme.warningColor
            : AppTheme.successColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.12),
          foregroundColor: color,
          child: Text(
            employee.name.isEmpty ? '?' : employee.name.characters.first,
          ),
        ),
        title: Text(
          employee.name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          '${employee.position}  •  ${number(summary.workedDays)} ڕۆژ لەم مانگە',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              status,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(height: 3),
            Text(
              money(summary.remaining),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 42, color: AppTheme.textSecondary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
