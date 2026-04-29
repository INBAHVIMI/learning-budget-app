import 'package:flutter/material.dart';

import '../../app.dart' show kBrandBlue;
import '../../core/models.dart';

class YearDashboardScreen extends StatelessWidget {
  const YearDashboardScreen({super.key, required this.yearPlan});

  final YearPlan yearPlan;

  @override
  Widget build(BuildContext context) {
    final avgSavings = yearPlan.totalSavings / yearPlan.months.length;
    final savingsRate = yearPlan.totalIncome == 0
        ? 0.0
        : (yearPlan.totalSavings / yearPlan.totalIncome).clamp(0.0, 1.0);

    final topSavingsMonth =
        yearPlan.months.reduce((a, b) => a.savings >= b.savings ? a : b);
    final mostOverspentMonth =
        yearPlan.months.reduce((a, b) => a.budgetVariance <= b.budgetVariance ? a : b);
    final maxIncome = yearPlan.months.map((m) => m.income).reduce((a, b) => a > b ? a : b);
    final maxExpense = yearPlan.months.map((m) => m.expense).reduce((a, b) => a > b ? a : b);
    final maxSavingsAbs = yearPlan.months
        .map((m) => m.savings.abs())
        .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI cards with mini bar charts ───────────────────────────
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  title: 'Total Income',
                  value: formatInr(yearPlan.totalIncome),
                  barData: yearPlan.months.map((m) => m.income).toList(),
                  maxVal: maxIncome,
                  color: kBrandBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: 'Total Expense',
                  value: formatInr(yearPlan.totalExpense),
                  barData: yearPlan.months.map((m) => m.expense).toList(),
                  maxVal: maxExpense,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: 'Net Savings',
                  value: formatInr(yearPlan.totalSavings),
                  barData: yearPlan.months.map((m) => m.savings).toList(),
                  maxVal: maxSavingsAbs == 0 ? 1 : maxSavingsAbs,
                  color: yearPlan.totalSavings >= 0
                      ? const Color(0xFF2ECC71)
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  title: 'Learning Done',
                  value:
                      '${(yearPlan.learningCompletion * 100).toStringAsFixed(0)}%',
                  barData: yearPlan.months
                      .map((m) => m.learningTasksTotal == 0
                          ? 0.0
                          : m.learningTasksDone /
                              m.learningTasksTotal *
                              100)
                      .toList(),
                  maxVal: 100,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Highlights row ───────────────────────────────────────────
          Row(
            children: [
              _HighlightCard(
                title: 'Best Savings',
                value:
                    '${topSavingsMonth.monthLabel}  ${formatInr(topSavingsMonth.savings)}',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              _HighlightCard(
                title: 'Most Overspent',
                value:
                    '${mostOverspentMonth.monthLabel}  ${formatInr(mostOverspentMonth.budgetVariance)}',
                icon: Icons.warning_amber,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 12),
              _HighlightCard(
                title: 'Avg Monthly Savings',
                value: formatInr(avgSavings),
                icon: Icons.show_chart,
                color: kBrandBlue,
              ),
              const SizedBox(width: 12),
              _HighlightCard(
                title: 'Savings Rate',
                value: '${(savingsRate * 100).toStringAsFixed(1)}%',
                icon: Icons.pie_chart,
                color: Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Monthly performance table ────────────────────────────────
          const Text('Monthly Performance',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(56),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                  5: FlexColumnWidth(3),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: kBrandBlue),
                    children: [
                      _th('Month'),
                      _th('Income'),
                      _th('Planned'),
                      _th('Actual'),
                      _th('Variance'),
                      _th('Learning'),
                    ],
                  ),
                  ...yearPlan.months.asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    final prog = m.learningTasksTotal == 0
                        ? 0.0
                        : (m.learningTasksDone / m.learningTasksTotal)
                            .clamp(0.0, 1.0);
                    final varColor = m.budgetVariance >= 0
                        ? const Color(0xFF27AE60)
                        : Colors.redAccent;
                    return TableRow(
                      decoration: BoxDecoration(
                        color: i.isOdd
                            ? const Color(0xFFF8FAFC)
                            : Colors.white,
                      ),
                      children: [
                        _tdBold(m.monthLabel),
                        _td(formatInr(m.income)),
                        _td(formatInr(m.plannedBudget)),
                        _td(formatInr(m.expense)),
                        _tdColor(
                          m.budgetVariance >= 0
                              ? '+${formatInr(m.budgetVariance)}'
                              : formatInr(m.budgetVariance),
                          varColor,
                        ),
                        _tdProgress(
                            prog, m.learningTasksDone, m.learningTasksTotal),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI card with inline mini bar chart ────────────────────────────────────
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.barData,
    required this.maxVal,
    required this.color,
  });

  final String title;
  final String value;
  final List<double> barData;
  final double maxVal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: _MiniBarChart(
                        data: barData, maxVal: maxVal, color: color),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    6,
                    (i) => Container(
                      width: 28,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.65 - i * 0.08),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart(
      {required this.data, required this.maxVal, required this.color});

  final List<double> data;
  final double maxVal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (maxVal == 0) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: data.map((v) {
        final frac =
            (v.abs() / maxVal).clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: frac < 0.04 ? 0.04 : frac,
              child: Container(
                decoration: BoxDecoration(
                  color: v < 0 ? Colors.redAccent : color,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Highlight card ──────────────────────────────────────────────────────────
class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Table cell helpers ───────────────────────────────────────────────────────
Widget _th(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );

Widget _td(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(t, style: const TextStyle(fontSize: 12)),
    );

Widget _tdBold(String t) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(t,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );

Widget _tdColor(String t, Color c) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(t,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: c)),
    );

Widget _tdProgress(double prog, int done, int total) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prog,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation(Colors.purple),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$done/$total',
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
