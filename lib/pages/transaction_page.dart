import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../model/transaction.dart';
import '../widget/transaction_dialog.dart';  // For .listenable()


class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  @override
  void dispose() {
    super.dispose();

    Hive.close();

    // If I want to close Specific Box, Sothe type Hive.box('transactions').close();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Hive Expense Tracker'),
      centerTitle: true,
    ),
    body: ValueListenableBuilder<Box<Transaction>>(
      valueListenable: Boxes.getTransaction().listenable(),
      builder: (context, box, _) {
        final transactions = box.values.toList().cast<Transaction>();

        return buildContent(transactions);
      }
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => TransactionDialog(
          onClickedDone: addTransaction
        )
      )
    ),
  );

  Widget buildContent(List<Transaction> transactions) {
    if(transactions.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netExpense = transactions.fold<double>(
        0,
        (previousValue, transaction) => transaction.isExpense
          ? previousValue - transaction.amount
          : previousValue + transaction.amount
      );
      final newExpenseString = '\$${netExpense.toStringAsFixed(2)}';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext contex, int index) {
                final transaction = transactions[index];

                return buildTransaction(contex, transaction);
              }
            )
          )
        ],
      );
    }
  }

  Widget buildTransaction(BuildContext context, Transaction transaction) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    final amount = '\$' + transaction.amount.toStringAsFixed(2);

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.name,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        ),
        children: [
          buildButton(context, transaction)
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, Transaction transaction) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: Text('Edit'),
          icon: Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TransactionDialog(
              transaction: transaction,
              onClickedDone: (name, amount, isExpense) => editTransaction(transaction, name, amount, isExpense)
              )
            )
          )
        )
      ),
      Expanded(
        child: TextButton.icon(
          label: Text('Delete'),
          icon: Icon(Icons.delete),
          onPressed: () => deleteTransaction(transaction)
        )
      )
    ],
  );

  Future addTransaction(String name, double amount, bool isExpense) async {
    final trnasaction = Transaction()
      ..name = name
      ..createdDate = DateTime.now()
      ..amount = amount
      ..isExpense = isExpense;
    final box = Boxes.getTransaction();

    box.add(trnasaction);

    /*
    box.put('myKey', transaction);
    final mybox = Boxes.getTransaction();
    final myTransaction = mybox.get('key');
    mybox.values;
    mybox.keys;
    */
  }

  void editTransaction(Transaction transaction, String name, double amount, bool isExpense) {
    transaction.name = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;

    transaction.save();

    /*
    final box = Boxes.getTransaction();

    box.put(transaction.key, transaction);
    */
  }

  void deleteTransaction(Transaction transaction) {
    transaction.delete();

    //setState(() => transactions.remove(transaction));

    /*
    final box = Boxes.getTransaction();

    box.delete(transaction.key);
    */
  }
}