import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goran/config/theme_config.dart';
import 'package:goran/models/index.dart';
import 'package:goran/providers/index.dart';
import 'package:goran/utils/formatters.dart';

// پەڕەی زیادکردن، گەڕان، دەستکاریکردن و سڕینەوەی کرێکاران.
class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  @override
  Widget build(BuildContext context) {
    // لیستی کرێکاران و کۆی مووچەی ڕۆژانە لێرە پیشان دەدرێت.
    return Consumer<AppDataProvider>(
      builder: (context, data, _) {
        if (!data.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        final employees = data.employees;
        return Scaffold(
          appBar: AppBar(
            title: const Text('لیستی کرێکاران'),
            actions: [
              IconButton(
                tooltip: 'زیادکردنی کرێکار',
                onPressed: () => _showEmployeeForm(context),
                icon: const Icon(Icons.person_add_alt_1),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showEmployeeForm(context),
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('کرێکاری نوێ'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: data.setSearch,
                  decoration: const InputDecoration(
                    hintText: 'بە ناو، پیشە یان ژمارە بگەڕێ...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${employees.length} کرێکار',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      'مووچەی ڕۆژانە: ${money(data.allEmployees.fold<double>(0, (sum, item) => sum + item.dailySalary))}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    employees.isEmpty
                        ? _EmptyEmployees(
                          onTap: () => _showEmployeeForm(context),
                          hasSearch: data.allEmployees.isNotEmpty,
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: employees.length,
                          itemBuilder:
                              (context, index) => _EmployeeTile(
                                employee: employees[index],
                                onEdit:
                                    () => _showEmployeeForm(
                                      context,
                                      employee: employees[index],
                                    ),
                                onDelete:
                                    () => _confirmDelete(
                                      context,
                                      employees[index],
                                    ),
                                onTap:
                                    () =>
                                        _showDetails(context, employees[index]),
                              ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEmployeeForm(
    BuildContext context, {
    Employee? employee,
  }) async {
    final result = await showModalBottomSheet<_EmployeeFormValue>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EmployeeForm(employee: employee),
    );
    if (!context.mounted || result == null) return;
    final data = context.read<AppDataProvider>();
    if (employee == null) {
      await data.addEmployee(
        name: result.name,
        position: result.position,
        dailySalary: result.dailySalary,
        phoneNumber: result.phoneNumber,
      );
      _message(context, 'کرێکارەکە زیاد کرا');
    } else {
      await data.updateEmployee(
        employeeId: employee.id,
        name: result.name,
        position: result.position,
        dailySalary: result.dailySalary,
        phoneNumber: result.phoneNumber,
      );
      _message(context, 'زانیارییەکە نوێ کرایەوە');
    }
  }

  void _showDetails(BuildContext context, Employee employee) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder:
          (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primaryColor.withOpacity(.1),
                      foregroundColor: AppTheme.primaryColor,
                      child: Text(
                        employee.name.isEmpty
                            ? '?'
                            : employee.name.substring(0, 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        employee.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 28),
                _InfoLine(
                  icon: Icons.work_outline,
                  label: 'پیشە',
                  value: employee.position,
                ),
                _InfoLine(
                  icon: Icons.phone_outlined,
                  label: 'مۆبایل',
                  value: employee.phoneNumber,
                ),
                _InfoLine(
                  icon: Icons.payments_outlined,
                  label: 'کرێی ڕۆژانە',
                  value: money(employee.dailySalary),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showEmployeeForm(context, employee: employee);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('دەستکاریکردنی زانیاری'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Employee employee) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('سڕینەوەی کرێکار؟'),
            content: Text('هەموو تۆمارەکانی ${employee.name} ـیش دەسڕێنەوە.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('پاشگەزبوونەوە'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('بسڕەوە'),
              ),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppDataProvider>().deleteEmployee(employee.id);
      _message(context, 'کرێکارەکە سڕایەوە');
    }
  }

  void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }
}

class _EmployeeTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeTile({
    required this.employee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(.1),
          foregroundColor: AppTheme.primaryColor,
          child: Text(
            employee.name.isEmpty ? '?' : employee.name.substring(0, 1),
          ),
        ),
        title: Text(
          employee.name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${employee.position}  •  ${employee.phoneNumber}\n${money(employee.dailySalary)} بۆ ڕۆژێک',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder:
              (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('دەستکاری'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline),
                    title: Text('سڕینەوە'),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _EmptyEmployees extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasSearch;
  const _EmptyEmployees({required this.onTap, required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.person_add_alt_1,
              size: 52,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'هیچ ئەنجامێک نەدۆزرایەوە' : 'لیستەکە هێشتا بەتاڵە',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add),
                label: const Text('یەکەم کرێکار زیاد بکە'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmployeeFormValue {
  final String name;
  final String position;
  final double dailySalary;
  final String phoneNumber;

  const _EmployeeFormValue({
    required this.name,
    required this.position,
    required this.dailySalary,
    required this.phoneNumber,
  });
}

class _EmployeeForm extends StatefulWidget {
  final Employee? employee;
  const _EmployeeForm({this.employee});

  @override
  State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _position;
  late final TextEditingController _salary;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.employee?.name ?? '');
    _position = TextEditingController(text: widget.employee?.position ?? '');
    _salary = TextEditingController(
      text: widget.employee?.dailySalary.toStringAsFixed(0) ?? '',
    );
    _phone = TextEditingController(text: widget.employee?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _salary.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.employee == null
                    ? 'زیادکردنی کرێکاری نوێ'
                    : 'دەستکاریکردنی زانیاری',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'ناوی کرێکار',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _position,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'پیشە / کار',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'ژمارەی مۆبایل',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salary,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'کرێی ڕۆژانە بە دینار',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator:
                    (value) =>
                        double.tryParse(value ?? '') == null
                            ? 'ژمارەیەکی دروست بنووسە'
                            : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(
                    widget.employee == null ? 'زیادکردن' : 'پاشەکەوتکردن',
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'ئەم خانەیە پڕ بکەرەوە' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _EmployeeFormValue(
        name: _name.text,
        position: _position.text,
        dailySalary: double.parse(_salary.text),
        phoneNumber: _phone.text,
      ),
    );
  }
}
