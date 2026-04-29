import '../models.dart';

class LocalStoreService {
  YearPlan loadOrCreateDefaultPlan() {
    final now = DateTime.now();
    final months = List<MonthPlan>.generate(12, (index) {
      final month = index + 1;
      return MonthPlan(
        month: month,
        income: 80000,
        plannedBudget: 60000,
        expense: 54000 + (month * 500),
        learningTasksDone: 2 + (month % 3),
        learningTasksTotal: 4,
      );
    });

    return YearPlan(year: now.year, months: months);
  }

  Future<void> savePlan(YearPlan plan) async {
    // TODO: Persist to local database (SQLite on mobile and local storage for web).
    await Future<void>.value();
  }
}
