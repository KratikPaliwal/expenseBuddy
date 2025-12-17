import '../expense/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class MonthlySummary {
  final String month;
  final double total;

  MonthlySummary({required this.month, required this.total});
}

class SummaryUtils {
  static List<MonthlySummary> calculateMonthlySummary(
      List<Expense> expenses) {
    final Map<String, double> monthlyTotals = {};

    for (final expense in expenses) {
      final monthKey = DateFormat('MMM yyyy').format(expense.date);
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    return monthlyTotals.entries.map((entry) {
      return MonthlySummary(
        month: entry.key,
        total: entry.value,
      );
    }).toList();
  }


  static double calculateTotal(List<MonthlySummary> data) {
    return data.fold(0, (sum, item) => sum + item.total);
  }

  static MonthlySummary? highestMonth(List<MonthlySummary> data) {
    if (data.isEmpty) return null;
    return data.reduce((a, b) => a.total > b.total ? a : b);
  }
  static List<MonthlySummary> filterLastMonths(
      List<MonthlySummary> data,
      int months,
      ) {
    if (months == 0) return data;

    final now = DateTime.now();

    return data.where((item) {
      final parts = item.month.split(' ');
      final month = _monthToInt(parts[0]);
      final year = int.parse(parts[1]);

      final date = DateTime(year, month);
      final diffMonths =
          (now.year - date.year) * 12 + now.month - date.month;

      return diffMonths < months;
    }).toList();
  }

  static int _monthToInt(String m) {
    const map = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return map[m]!;
  }
  static List<MonthlySummary> filterByDateRange(
      List<MonthlySummary> data,
      DateTimeRange range,
      ) {
    return data.where((item) {
      final parts = item.month.split(' ');
      final month = _monthToInt(parts[0]);
      final year = int.parse(parts[1]);

      final date = DateTime(year, month);

      return !date.isBefore(
        DateTime(range.start.year, range.start.month),
      ) &&
          !date.isAfter(
            DateTime(range.end.year, range.end.month),
          );
    }).toList();
  }

}

