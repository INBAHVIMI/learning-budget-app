import 'package:flutter/material.dart';

import '../../core/models.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({
    super.key,
    required this.yearPlan,
    required this.onMonthUpdated,
  });

  final YearPlan yearPlan;
  final Future<void> Function(MonthPlan updatedMonth) onMonthUpdated;

  Future<void> _showEditDialog(BuildContext context, MonthPlan monthPlan) async {
    final incomeController = TextEditingController(
      text: monthPlan.income.toStringAsFixed(0),
    );
    final plannedController = TextEditingController(
      text: monthPlan.plannedBudget.toStringAsFixed(0),
    );
    final expenseController = TextEditingController(
      text: monthPlan.expense.toStringAsFixed(0),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${monthPlan.monthLabel} Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: incomeController,
                decoration: const InputDecoration(labelText: 'Income (INR)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: plannedController,
                decoration: const InputDecoration(labelText: 'Planned Budget (INR)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expenseController,
                decoration: const InputDecoration(labelText: 'Expense (INR)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final income = double.tryParse(incomeController.text.trim());
                final planned = double.tryParse(plannedController.text.trim());
                final expense = double.tryParse(expenseController.text.trim());

                if (income == null || planned == null || expense == null) {
                  return;
                }

                await onMonthUpdated(
                  monthPlan.copyWith(
                    income: income,
                    plannedBudget: planned,
                    expense: expense,
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    incomeController.dispose();
    plannedController.dispose();
    expenseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Budget Tracking', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Local-first monthly budget tracking in INR.'),
        const SizedBox(height: 12),
        ...yearPlan.months.map(
          (m) => Card(
            child: ListTile(
              title: Text('${m.monthLabel} Savings'),
              subtitle: Text('Income ${formatInr(m.income)} • Expense ${formatInr(m.expense)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(formatInr(m.savings)),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit month values',
                    onPressed: () => _showEditDialog(context, m),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
