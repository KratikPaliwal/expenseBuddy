import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expense_model.dart';
import '../currency/currency_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    final currencyProvider =
    Provider.of<CurrencyProvider>(context, listen: false);

    titleController =
        TextEditingController(text: widget.expense.title);

    amountController = TextEditingController(
      text: currencyProvider
          .convert(widget.expense.amount)
          .toStringAsFixed(2),
    );

    selectedDate = widget.expense.date;
  }

  void saveEdit() {
    final title = titleController.text.trim();
    final displayAmount =
    double.tryParse(amountController.text.trim());

    if (title.isEmpty || displayAmount == null || displayAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid data")),
      );
      return;
    }

    final currencyProvider =
    context.read<CurrencyProvider>();

    final amountInInr =
    currencyProvider.toBase(displayAmount);

    Navigator.pop(
      context,
      Expense(
        id: widget.expense.id,
        title: title,
        amount: amountInInr,
        date: selectedDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Expense"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Amount (${currency.symbol})",
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: const Text("Pick Date"),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveEdit,
                child: const Text("Update Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
