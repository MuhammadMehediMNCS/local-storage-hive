import 'package:hive/hive.dart';
import 'model/transaction.dart';

class Boxes {
  static Box<Transaction> getTransaction() => Hive.box<Transaction>('transactions');
}