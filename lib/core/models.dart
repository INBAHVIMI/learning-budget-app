import 'package:intl/intl.dart';

class YearPlan {
  YearPlan({required this.year, required this.months});

  final int year;
  final List<MonthPlan> months;

  double get totalIncome => months.fold(0, (sum, m) => sum + m.income);
  double get totalExpense => months.fold(0, (sum, m) => sum + m.expense);
  double get totalPlanned => months.fold(0, (sum, m) => sum + m.plannedBudget);
  double get totalSavings => totalIncome - totalExpense;

  double get learningCompletion {
    final totalTasks = months.fold<int>(0, (sum, m) => sum + m.learningTasksTotal);
    if (totalTasks == 0) {
      return 0;
    }
    final completed = months.fold<int>(0, (sum, m) => sum + m.learningTasksDone);
    return completed / totalTasks;
  }

  YearPlan updateMonth(MonthPlan updatedMonth) {
    final updatedMonths = months
        .map((m) => m.month == updatedMonth.month ? updatedMonth : m)
        .toList(growable: false);
    return YearPlan(year: year, months: updatedMonths);
  }
}

class MonthPlan {
  MonthPlan({
    required this.month,
    required this.income,
    required this.plannedBudget,
    required this.expense,
    required this.learningTasksDone,
    required this.learningTasksTotal,
  });

  final int month;
  final double income;
  final double plannedBudget;
  final double expense;
  final int learningTasksDone;
  final int learningTasksTotal;

  double get savings => income - expense;
  double get budgetVariance => plannedBudget - expense;

  String get monthLabel => DateFormat.MMM().format(DateTime(2000, month));

  MonthPlan copyWith({
    double? income,
    double? plannedBudget,
    double? expense,
    int? learningTasksDone,
    int? learningTasksTotal,
  }) {
    return MonthPlan(
      month: month,
      income: income ?? this.income,
      plannedBudget: plannedBudget ?? this.plannedBudget,
      expense: expense ?? this.expense,
      learningTasksDone: learningTasksDone ?? this.learningTasksDone,
      learningTasksTotal: learningTasksTotal ?? this.learningTasksTotal,
    );
  }
}

String formatInr(num amount) {
  final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  return formatter.format(amount);
}
