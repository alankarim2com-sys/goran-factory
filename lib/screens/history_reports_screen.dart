import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goran/config/theme_config.dart';
import 'package:goran/providers/index.dart';
import 'package:goran/utils/formatters.dart';

// پەڕەی ڕاپۆرتی مانگ و حسابی کۆتایی هەر کرێکار.
class HistoryReportsScreen extends StatelessWidget {
  const HistoryReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // هەموو شایستەیی و پارەدانەکان بەپێی مانگی هەڵبژێردراو حساب دەکرێن.
    return Consumer<AppDataProvider>(
      builder: (context, data, _) {
        if (!data.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        final summaries = data.monthSummaries;
        return Scaffold(
          appBar: AppBar(title: const Text('ڕاپۆرتی مانگانە')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _MonthSwitcher(
                month: data.reportMonth,
                onChanged: data.setReportMonth,
              ),
              const SizedBox(height: 14),
              _ReportTotals(data: data),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حسابی هەر کرێکار',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${summaries.length} کەس',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (summaries.isEmpty)
                const _NoReport()
              else
                ...summaries.map(
                  (summary) => _SummaryCard(
                    summary: summary,
                    onPay: () => _showPaymentDialog(context, summary),
                    onDetails: () => _showDetails(context, summary),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    EmployeeMonthSummary summary,
  ) async {
    final result = await showDialog<_PaymentValue>(
      context: context,
      builder: (_) => _PaymentDialog(summary: summary),
    );
    if (!context.mounted || result == null) return;
    final data = context.read<AppDataProvider>();
    await data.addPayment(
      employeeId: summary.employee.id,
      amount: result.amount,
      date: DateTime(data.reportMonth.year, data.reportMonth.month, 1),
      note: result.note,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('پارەدانەکە تۆمار کرا'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDetails(BuildContext context, EmployeeMonthSummary summary) {
    final data = context.read<AppDataProvider>();
    final payments =
        data.payments
            .where(
              (payment) =>
                  payment.employeeId == summary.employee.id &&
                  payment.date.year == data.reportMonth.year &&
                  payment.date.month == data.reportMonth.month,
            )
            .toList();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.employee.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  monthLabel(data.reportMonth),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 26),
                _DetailRow(label: 'ڕۆژی تەواو', value: '${summary.fullDays}'),
                _DetailRow(label: 'نیوەڕۆژ', value: '${summary.halfDays}'),
                _DetailRow(label: 'غایب', value: '${summary.absentDays}'),
                _DetailRow(
                  label: 'ڕۆژی کارکراو',
                  value: number(summary.workedDays),
                ),
                _DetailRow(label: 'کۆی شایستە', value: money(summary.earned)),
                _DetailRow(label: 'کۆی پارەدراو', value: money(summary.paid)),
                _DetailRow(
                  label: 'ماوەی پارە',
                  value: money(summary.remaining),
                  valueColor:
                      summary.remaining > 0
                          ? AppTheme.accentColor
                          : AppTheme.successColor,
                ),
                if (payments.isNotEmpty) ...[
                  const Divider(height: 26),
                  Text(
                    'پارەدانەکان',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...payments.map(
                    (payment) => _DetailRow(
                      label: dateLabel(payment.date),
                      value: money(payment.amount),
                    ),
                  ),
                ],
              ],
            ),
          ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onChanged;
  const _MonthSwitcher({required this.month, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          IconButton(
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
            tooltip: 'مانگی پێشوو',
            icon: const Icon(Icons.chevron_right),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'مانگی ڕاپۆرت',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  monthLabel(month),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => onChanged(DateTime(month.year, month.month + 1)),
            tooltip: 'مانگی داهاتوو',
            icon: const Icon(Icons.chevron_left),
          ),
        ],
      ),
    );
  }
}

class _ReportTotals extends StatelessWidget {
  final AppDataProvider data;
  const _ReportTotals({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TotalCard(
            label: 'کۆی شایستە',
            value: money(data.totalEarned),
            color: AppTheme.primaryColor,
            icon: Icons.trending_up,
          ),
          const SizedBox(width: 10),
          _TotalCard(
            label: 'پارەدراو',
            value: money(data.totalPaid),
            color: AppTheme.successColor,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 10),
          _TotalCard(
            label: 'ماوە بۆ دان',
            value: money(data.totalRemaining),
            color: AppTheme.accentColor,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _TotalCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          FittedBox(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final EmployeeMonthSummary summary;
  final VoidCallback onPay;
  final VoidCallback onDetails;
  const _SummaryCard({
    required this.summary,
    required this.onPay,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final remainingColor =
        summary.remaining > 0 ? AppTheme.accentColor : AppTheme.successColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(.1),
                  foregroundColor: AppTheme.primaryColor,
                  child: Text(
                    summary.employee.name.isEmpty
                        ? '?'
                        : summary.employee.name.substring(0, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.employee.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${number(summary.workedDays)} ڕۆژ کارکراو  •  ${summary.absentDays} غایب',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      money(summary.remaining),
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: remainingColor),
                    ),
                    Text('ماوە', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniMetric(label: 'تەواو', value: '${summary.fullDays}'),
                _MiniMetric(label: 'نیوە', value: '${summary.halfDays}'),
                _MiniMetric(label: 'شایستە', value: money(summary.earned)),
                _MiniMetric(label: 'پارەدراو', value: money(summary.paid)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetails,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('وردەکاری'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('پارەدان'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentValue {
  final double amount;
  final String? note;
  const _PaymentValue({required this.amount, required this.note});
}

class _PaymentDialog extends StatefulWidget {
  final EmployeeMonthSummary summary;
  const _PaymentDialog({required this.summary});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text:
          widget.summary.remaining > 0
              ? widget.summary.remaining.toStringAsFixed(0)
              : '',
    );
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تۆمارکردنی پارەدان'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.summary.employee.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'ماوە: ${money(widget.summary.remaining)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'بڕی پارە بە دینار'),
              validator:
                  (value) =>
                      double.tryParse(value ?? '') == null ||
                              double.parse(value!) <= 0
                          ? 'بڕێکی دروست بنووسە'
                          : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'تێبینی (ئارەزوومەندانە)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('پاشگەزبوونەوە'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('تۆمارکردن')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _PaymentValue(amount: double.parse(_amount.text), note: _note.text),
    );
  }
}

class _NoReport extends StatelessWidget {
  const _NoReport();
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text('بۆ دروستکردنی ڕاپۆرت سەرەتا کرێکار زیاد بکە')),
    ),
  );
}
