import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../currency/currency_provider.dart';
import 'summary_utils.dart';

class MonthlyBarChart extends StatefulWidget {
  final List<MonthlySummary> data;
  final String? highlightMonth;

  const MonthlyBarChart({
    super.key,
    required this.data,
    this.highlightMonth,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
  }

  @override
  void didUpdateWidget(covariant MonthlyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 🔁 Re-animate when data or currency changes
    if (oldWidget.data != widget.data ||
        oldWidget.highlightMonth != widget.highlightMonth) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    setState(() => _animate = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) {
          setState(() => _animate = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

    final sortedData = List<MonthlySummary>.from(widget.data)
      ..sort((a, b) => _toDate(a.month).compareTo(_toDate(b.month)));

    if (sortedData.isEmpty) {
      return const SizedBox(height: 260);
    }

    // 🔹 Convert totals to display currency
    final convertedValues =
    sortedData.map((e) => currency.convert(e.total)).toList();

    final maxValue = convertedValues.reduce(max);
    final maxY = _niceMax(maxValue);
    final interval = maxY / 4;

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,

          barTouchData: _buildTouch(currency, sortedData),
          titlesData: _buildTitles(currency, interval, sortedData),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
          ),

          borderData: FlBorderData(show: false),

          barGroups: List.generate(sortedData.length, (index) {
            final item = sortedData[index];
            final value = currency.convert(item.total);
            final isHighest = item.month == widget.highlightMonth;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _animate ? value : 0,
                  width: isHighest ? 26 : 20,
                  borderRadius: BorderRadius.circular(8),
                  color: isHighest
                      ? Colors.teal.shade800
                      : Colors.teal.shade400,
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  // ---------------- HELPERS ----------------
  double _niceMax(double value) {
    if (value <= 0) return 1;

    final exponent = (log(value) / ln10).floor();
    final base = value / pow(10, exponent);

    double niceBase;
    if (base <= 1) {
      niceBase = 1;
    } else if (base <= 2) {
      niceBase = 2;
    } else if (base <= 5) {
      niceBase = 5;
    } else {
      niceBase = 10;
    }

    return niceBase * pow(10, exponent);
  }

  BarTouchData _buildTouch(
      CurrencyProvider currency,
      List<MonthlySummary> sortedData,
      ) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItem: (group, _, __, ___) {
          final item = sortedData[group.x.toInt()];
          final value = currency.convert(item.total);

          return BarTooltipItem(
            '${item.month}\n'
                '${currency.symbol}${value.toStringAsFixed(0)}',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              backgroundColor: Colors.black87,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitles(
      CurrencyProvider currency,
      double interval,
      List<MonthlySummary> sortedData,
      ) {
    return FlTitlesData(
      topTitles:
      AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
      AxisTitles(sideTitles: SideTitles(showTitles: false)),

      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: interval,
          reservedSize: 56,
          getTitlesWidget: (value, _) => Text(
            '${currency.symbol}${value.toInt()}',
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            final month =
            sortedData[value.toInt()].month.split(' ')[0];
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                month,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime _toDate(String monthYear) {
    final parts = monthYear.split(' ');
    const months = {
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
    return DateTime(int.parse(parts[1]), months[parts[0]]!);
  }
}
