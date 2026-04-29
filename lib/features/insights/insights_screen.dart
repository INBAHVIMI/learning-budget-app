import 'package:flutter/material.dart';

import '../../core/models.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.yearPlan});

  final YearPlan yearPlan;

  @override
  Widget build(BuildContext context) {
    final averageSpend = yearPlan.totalExpense / 12;
    final averageSavings = yearPlan.totalSavings / 12;

    final highlights = <String>[
      'Average monthly spend: ${formatInr(averageSpend)}',
      'Average monthly savings: ${formatInr(averageSavings)}',
      yearPlan.totalSavings >= 0
          ? 'Positive yearly savings trend.'
          : 'Yearly deficit detected. Review high-spend months.',
      yearPlan.learningCompletion >= 0.75
          ? 'Learning momentum is strong this year.'
          : 'Learning completion is below 75%, plan smaller weekly goals.',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Insights & Highlights', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...highlights.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(item),
            ),
          ),
        ),
      ],
    );
  }
}
