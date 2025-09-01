import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpense = [
    Expense(
      amount: 15.55,
      date: DateTime.now(),
      title: 'Flutter Course',
      category: Category.work,
    ),
    Expense(
      amount: 20,
      date: DateTime.now(),
      title: 'Party',
      category: Category.leisure,
    ),
  ];

  void _addExpenseTrackerValue() {
    showModalBottomSheet(context: context, builder: (ctx) => NewExpense());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(onPressed: _addExpenseTrackerValue, icon: Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Text('Expenses Chart'),
          Expanded(child: ExpensesList(expenses: _registeredExpense)),
        ],
      ),
    );
  }
}
