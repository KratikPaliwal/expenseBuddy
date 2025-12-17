import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../expense/add_expense_screen.dart';
import '../expense/edit_expense_screen.dart';
import '../expense/expense_model.dart';

import '../db/db_helper.dart';
import '../db/firestore_service.dart';

import '../sync/sync_service.dart';
import '../summary/summary_screen.dart';

import '../currency/currency_provider.dart';
import '../currency/currency.dart';

enum SortOption {
  newest,
  oldest,
  amountHigh,
  amountLow,
}

enum ExpenseViewMode {
  currentMonth,
  all,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  bool isLoading = true;
  SortOption currentSort = SortOption.newest;
  ExpenseViewMode viewMode = ExpenseViewMode.currentMonth;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    while (!SyncService.isInitialSyncDone) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _reloadFromDb();
  }

  Future<void> _reloadFromDb() async {
    final data = await DBHelper.getExpenses();
    if (!mounted) return;

    setState(() {
      expenses = _sortExpenses(data);
      isLoading = false;
    });
  }

  List<Expense> _sortExpenses(List<Expense> list) {
    final sorted = List<Expense>.from(list);

    switch (currentSort) {
      case SortOption.newest:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.oldest:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHigh:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLow:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return sorted;
  }

  List<Expense> get visibleExpenses {
    if (viewMode == ExpenseViewMode.all) return expenses;

    final now = DateTime.now();
    return expenses.where((e) =>
    e.date.year == now.year &&
        e.date.month == now.month
    ).toList();
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

    final rawTotal = visibleExpenses.fold<double>(
      0,
          (sum, e) => sum + e.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("ExpenseBuddy"),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                currentSort = value;
                expenses = _sortExpenses(expenses);
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: SortOption.newest, child: Text("Newest")),
              PopupMenuItem(value: SortOption.oldest, child: Text("Oldest")),
              PopupMenuItem(value: SortOption.amountHigh, child: Text("Amount ↓")),
              PopupMenuItem(value: SortOption.amountLow, child: Text("Amount ↑")),
            ],
          ),

          PopupMenuButton<Currency>(
            icon: const Icon(Icons.currency_exchange),
            onSelected: currency.changeCurrency,
            itemBuilder: (_) => const [
              PopupMenuItem(value: Currency.inr, child: Text("₹ INR")),
              PopupMenuItem(value: Currency.usd, child: Text("\$ USD")),
              PopupMenuItem(value: Currency.eur, child: Text("€ EUR")),
              PopupMenuItem(value: Currency.jpy, child: Text("¥ JPY")),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔹 TOTAL CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      viewMode == ExpenseViewMode.currentMonth
                          ? "Spent in ${_monthName(DateTime.now().month)}"
                          : "Total Spent (All)",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "${currency.symbol}${currency.convert(rawTotal).toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("This Month"),
                  selected: viewMode == ExpenseViewMode.currentMonth,
                  onSelected: (_) {
                    setState(() {
                      viewMode = ExpenseViewMode.currentMonth;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text("All"),
                  selected: viewMode == ExpenseViewMode.all,
                  onSelected: (_) {
                    setState(() {
                      viewMode = ExpenseViewMode.all;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: visibleExpenses.isEmpty
                ? const Center(child: Text("No expenses"))
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              itemCount: visibleExpenses.length,
              itemBuilder: (_, index) {
                return _animatedExpenseCard(
                  context,
                  visibleExpenses[index],
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final expense = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );

          if (expense is Expense) {
            await DBHelper.insertExpense(expense);
            await FirestoreService.addExpense(expense);
            await _reloadFromDb();
          }
        },
      ),
    );
  }

  Widget _animatedExpenseCard(BuildContext context, Expense expense) {
    final currency = context.watch<CurrencyProvider>();

    return StatefulBuilder(
      builder: (context, setLocal) {
        bool pressed = false;

        return GestureDetector(
          onLongPressStart: (_) => setLocal(() => pressed = true),
          onLongPressEnd: (_) => setLocal(() => pressed = false),
          onLongPress: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Delete Expense"),
                content:
                const Text("Are you sure you want to delete this expense?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await DBHelper.deleteExpense(expense.id);
              await FirestoreService.deleteExpense(expense.id);
              await _reloadFromDb();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: pressed
                  ? Colors.red.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedScale(
              scale: pressed ? 0.97 : 1,
              duration: const Duration(milliseconds: 180),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(expense.title),
                  subtitle: Text(
                    expense.date.toLocal().toString().split(' ')[0],
                  ),
                  trailing: Text(
                    "${currency.symbol}${currency.convert(expense.amount).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditExpenseScreen(expense: expense),
                      ),
                    );

                    if (updated is Expense) {
                      await DBHelper.updateExpense(updated);
                      await FirestoreService.updateExpense(updated);
                      await _reloadFromDb();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
