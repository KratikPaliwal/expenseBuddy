import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/db_helper.dart';
import '../expense/expense_model.dart';
import '../currency/currency_provider.dart';

import 'monthly_bar_chart.dart';
import 'summary_utils.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<MonthlySummary> _allSummary = [];
  bool isLoading = true;

  int _selectedFilter = 0;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final List<Expense> expenses = await DBHelper.getExpenses();
    final summary =
    SummaryUtils.calculateMonthlySummary(expenses);

    if (!mounted) return;

    setState(() {
      _allSummary = summary;
      isLoading = false;
    });
  }

  List<MonthlySummary> get _filteredSummary {
    if (_customRange != null) {
      return SummaryUtils.filterByDateRange(
        _allSummary,
        _customRange!,
      );
    }
    return SummaryUtils.filterLastMonths(
      _allSummary,
      _selectedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filteredSummary;
    final highest = SummaryUtils.highestMonth(filtered);
    final rawTotal = SummaryUtils.calculateTotal(filtered);
    final convertedTotal = currency.convert(rawTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Summary"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Pick date range",
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: filtered.isEmpty
          ? const Center(child: Text("No data available"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 FILTER CHIPS
            Wrap(
              spacing: 8,
              children: [
                _filterChip("3 Months", 3),
                _filterChip("6 Months", 6),
                _filterChip("All", 0),
              ],
            ),

            if (_customRange != null) ...[
              const SizedBox(height: 8),
              Text(
                "From ${_format(_customRange!.start)} "
                    "to ${_format(_customRange!.end)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],

            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Expense",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${currency.symbol}${convertedTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            MonthlyBarChart(
              data: filtered,
              highlightMonth: highest?.month,
            ),

            const SizedBox(height: 24),

            // 🔹 MONTH LIST (FIXED)
            ListView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isHighest =
                    item.month == highest?.month;

                final converted =
                currency.convert(item.total);

                return Card(
                  color: isHighest
                      ? Colors.teal.withOpacity(0.08)
                      : null,
                  child: ListTile(
                    title: Text(
                      item.month,
                      style: TextStyle(
                        fontWeight: isHighest
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      "${currency.symbol}${converted.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isHighest
                            ? Colors.teal
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _filterChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value &&
          _customRange == null,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
          _customRange = null;
        });
      },
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (range != null) {
      setState(() {
        _customRange = range;
      });
    }
  }

  String _format(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
