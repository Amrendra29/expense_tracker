import 'package:uuid/uuid.dart';

const  uuid = Uuid();

class Expense {
  const Expense({
    required this.amount,
    required this.date,
    required this.title,
  }) : id=uuid.v4();
  final String id;
  final String title;
  final double amount;
  final DateTime date;
}
