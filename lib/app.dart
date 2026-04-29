import 'package:flutter/material.dart';

import 'core/models.dart';
import 'core/services/local_store_service.dart';
import 'core/services/onedrive_sync_service.dart';
import 'features/budget/budget_screen.dart';
import 'features/dashboard/year_dashboard_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/learning/learning_screen.dart';
import 'features/settings/settings_screen.dart';

const Color kBrandBlue = Color(0xFF009FD4);

class LearningBudgetApp extends StatefulWidget {
  const LearningBudgetApp({super.key});

  @override
  State<LearningBudgetApp> createState() => _LearningBudgetAppState();
}

class _LearningBudgetAppState extends State<LearningBudgetApp> {
  final LocalStoreService _localStore = LocalStoreService();
  final OneDriveSyncService _syncService = OneDriveSyncService();

  int _index = 0;
  late YearPlan _yearPlan;

  @override
  void initState() {
    super.initState();
    _yearPlan = _localStore.loadOrCreateDefaultPlan();
  }

  Future<void> _updateMonth(MonthPlan updatedMonth) async {
    setState(() {
      _yearPlan = _yearPlan.updateMonth(updatedMonth);
    });
    await _localStore.savePlan(_yearPlan);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      YearDashboardScreen(yearPlan: _yearPlan),
      BudgetScreen(yearPlan: _yearPlan, onMonthUpdated: _updateMonth),
      LearningScreen(yearPlan: _yearPlan, onMonthUpdated: _updateMonth),
      InsightsScreen(yearPlan: _yearPlan),
      SettingsScreen(
        syncService: _syncService,
        localStore: _localStore,
        yearPlan: _yearPlan,
      ),
    ];

    return MaterialApp(
      title: 'Learning & Budget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        cardTheme: const CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: _AppShell(
        index: _index,
        pages: pages,
        yearPlan: _yearPlan,
        onTabSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Branded app shell ─────────────────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.index,
    required this.pages,
    required this.yearPlan,
    required this.onTabSelected,
  });

  final int index;
  final List<Widget> pages;
  final YearPlan yearPlan;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    (icon: Icons.bar_chart, label: 'Dashboard'),
    (icon: Icons.account_balance_wallet, label: 'Budget'),
    (icon: Icons.menu_book, label: 'Learning'),
    (icon: Icons.insights, label: 'Insights'),
    (icon: Icons.settings, label: 'Settings'),
  ];

  static String _shortInr(double v) {
    if (v.abs() >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v.abs() >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          // ── Branded header ────────────────────────────────────────────
          Container(
            color: kBrandBlue,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 20,
              right: 20,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'M',
                        style: TextStyle(
                          color: kBrandBlue,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'FY ${yearPlan.year}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _Pill(label: _shortInr(yearPlan.totalIncome), sub: 'Income'),
                    const SizedBox(width: 8),
                    _Pill(label: _shortInr(yearPlan.totalExpense), sub: 'Expense'),
                    const SizedBox(width: 8),
                    _Pill(
                      label:
                          '${(yearPlan.learningCompletion * 100).toStringAsFixed(0)}%',
                      sub: 'Learning',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Top tab bar ───────────────────────────────────────
                Row(
                  children: List.generate(_tabs.length, (i) {
                    final sel = i == index;
                    return GestureDetector(
                      onTap: () => onTabSelected(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  sel ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_tabs[i].icon,
                                size: 14,
                                color:
                                    sel ? Colors.white : Colors.white60),
                            const SizedBox(width: 5),
                            Text(
                              _tabs[i].label,
                              style: TextStyle(
                                color: sel
                                    ? Colors.white
                                    : Colors.white60,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // ── Page body ────────────────────────────────────────────────
          Expanded(child: pages[index]),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.sub});
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
          Text(sub,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
