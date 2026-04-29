import 'package:flutter/material.dart';

import '../../core/models.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({
    super.key,
    required this.yearPlan,
    required this.onMonthUpdated,
  });

  final YearPlan yearPlan;
  final Future<void> Function(MonthPlan updatedMonth) onMonthUpdated;

  Future<void> _showEditDialog(BuildContext context, MonthPlan monthPlan) async {
    final doneController = TextEditingController(
      text: monthPlan.learningTasksDone.toString(),
    );
    final totalController = TextEditingController(
      text: monthPlan.learningTasksTotal.toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${monthPlan.monthLabel} Learning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: doneController,
                decoration: const InputDecoration(labelText: 'Tasks Done'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(labelText: 'Tasks Total'),
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
                final done = int.tryParse(doneController.text.trim());
                final total = int.tryParse(totalController.text.trim());
                if (done == null || total == null || total <= 0) {
                  return;
                }

                final clampedDone = done.clamp(0, total);
                await onMonthUpdated(
                  monthPlan.copyWith(
                    learningTasksDone: clampedDone,
                    learningTasksTotal: total,
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

    doneController.dispose();
    totalController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Learning Plan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Track lessons, weekly tasks, and consistency over the year.'),
        const SizedBox(height: 12),
        ...yearPlan.months.map(
          (m) => Card(
            child: ListTile(
              title: Text('${m.monthLabel} Tasks'),
              subtitle: Text('${m.learningTasksDone} of ${m.learningTasksTotal} done'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${((m.learningTasksDone / m.learningTasksTotal) * 100).toStringAsFixed(0)}%'),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit tasks',
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
