import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryBreakdownScreen extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryBreakdownScreen({super.key, required this.expenses});

  Map<String, double> get _categoryTotals {
    final Map<String, double> summary = {};
    for (var exp in expenses) {
      summary.update(exp.category, (val) => val + exp.amount, ifAbsent: () => exp.amount);
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _categoryTotals;

    return Scaffold(
      appBar: AppBar(title: const Text('Category Breakdown')),
      body: totals.isEmpty
          ? const Center(child: Text('No data available'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: totals.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF6A1B9A),
                      child: Icon(Icons.category, color: Colors.white),
                    ),
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Color(0xFFE1BEE7), fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}