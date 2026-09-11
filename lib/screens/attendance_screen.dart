import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goran/config/theme_config.dart';
import 'package:goran/models/index.dart';
import 'package:goran/providers/index.dart';
import 'package:goran/utils/formatters.dart';

// پەڕەی تۆمارکردنی ئامادەبوون بۆ هەر ڕۆژێک.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // هەموو کرێکاران پیشان دەدرێن، تەنانەت ئەگەر هێشتا دۆخیان دیاری نەکرابێت.
    return Consumer<AppDataProvider>(
      builder: (context, data, _) {
        if (!data.isReady)
          return const Center(child: CircularProgressIndicator());
        final marked =
            data.allEmployees
                .where(
                  (employee) =>
                      data.attendanceFor(employee.id, _selectedDate) != null,
                )
                .length;
        final present =
            data.allEmployees.where((employee) {
              final item = data.attendanceFor(employee.id, _selectedDate);
              return item != null && item.type != AttendanceType.absent;
            }).length;
        final absent =
            data.allEmployees
                .where(
                  (employee) =>
                      data.attendanceFor(employee.id, _selectedDate)?.type ==
                      AttendanceType.absent,
                )
                .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('ئامادەبوونی ڕۆژانە'),
            actions: [
              if (data.allEmployees.isNotEmpty)
                IconButton(
                  tooltip: 'هەموو ئامادە',
                  onPressed: () async {
                    for (final employee in data.allEmployees) {
                      await data.setAttendance(
                        employeeId: employee.id,
                        date: _selectedDate,
                        type: AttendanceType.fullDay,
                      );
                    }
                  },
                  icon: const Icon(Icons.done_all),
                ),
            ],
          ),
          body: Column(
            children: [
              _buildDateHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    _CountPill(
                      label: 'ئامادە',
                      value: present,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    _CountPill(
                      label: 'غایب',
                      value: absent,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    _CountPill(
                      label: 'ماوە',
                      value: data.allEmployees.length - marked,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    data.allEmployees.isEmpty
                        ? _NoEmployees(
                          onTap:
                              () => _showMessage(
                                context,
                                'لە پەڕەی کرێکارانەوە کرێکار زیاد بکە',
                              ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: data.allEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = data.allEmployees[index];
                            return _AttendanceEmployeeCard(
                              employee: employee,
                              attendance: data.attendanceFor(
                                employee.id,
                                _selectedDate,
                              ),
                              onSelect: (type) async {
                                await data.setAttendance(
                                  employeeId: employee.id,
                                  date: _selectedDate,
                                  type: type,
                                );
                                if (context.mounted)
                                  _showMessage(
                                    context,
                                    '${employee.name}: ${type.displayName}',
                                  );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final isToday = _sameDay(_selectedDate, DateTime.now());
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'ئەمڕۆ' : 'بەرواری هەڵبژێردراو',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _pickDate,
            color: Colors.white,
            tooltip: 'گۆڕینی بەروار',
            icon: const Icon(Icons.edit_calendar_outlined),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'بەرواری ئامادەبوون هەڵبژێرە',
      cancelText: 'پاشگەزبوونەوە',
      confirmText: 'هەڵبژێرە',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _CountPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(.09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceEmployeeCard extends StatelessWidget {
  final Employee employee;
  final Attendance? attendance;
  final ValueChanged<AttendanceType> onSelect;

  const _AttendanceEmployeeCard({
    required this.employee,
    required this.attendance,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = attendance?.type;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withOpacity(.1),
                  foregroundColor: AppTheme.primaryColor,
                  child: Text(
                    employee.name.isEmpty ? '?' : employee.name.substring(0, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${employee.position}  •  ${money(employee.dailySalary)} بۆ ڕۆژێک',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (selected != null)
                  Icon(
                    _statusIcon(selected),
                    color: _statusColor(selected),
                    size: 22,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusButton(
                  label: 'ئامادە',
                  icon: Icons.check,
                  color: AppTheme.successColor,
                  selected: selected == AttendanceType.fullDay,
                  onTap: () => onSelect(AttendanceType.fullDay),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  label: 'نیوەڕۆژ',
                  icon: Icons.timelapse,
                  color: AppTheme.warningColor,
                  selected: selected == AttendanceType.halfDay,
                  onTap: () => onSelect(AttendanceType.halfDay),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  label: 'غایب',
                  icon: Icons.close,
                  color: AppTheme.errorColor,
                  selected: selected == AttendanceType.absent,
                  onTap: () => onSelect(AttendanceType.absent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(AttendanceType type) {
    switch (type) {
      case AttendanceType.fullDay:
        return Icons.check_circle;
      case AttendanceType.halfDay:
        return Icons.timelapse;
      case AttendanceType.absent:
        return Icons.cancel;
    }
  }

  Color _statusColor(AttendanceType type) {
    switch (type) {
      case AttendanceType.fullDay:
        return AppTheme.successColor;
      case AttendanceType.halfDay:
        return AppTheme.warningColor;
      case AttendanceType.absent:
        return AppTheme.errorColor;
    }
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(.13) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : AppTheme.borderColor,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? color : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? color : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoEmployees extends StatelessWidget {
  final VoidCallback onTap;
  const _NoEmployees({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.groups_outlined,
              size: 52,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text('بۆ دەستپێکردن سەرەتا کرێکار زیاد بکە'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_back),
              label: const Text('چۆن کرێکار زیاد بکەم؟'),
            ),
          ],
        ),
      ),
    );
  }
}
