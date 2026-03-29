import 'package:financialreport/models/summaryModel.dart';
import 'package:financialreport/models/trxModel.dart';
import 'package:financialreport/services/trxService.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  final _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  FinancialSummary get summary {
    final income = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    return FinancialSummary(
      totalBalance: income - expense,
      totalIncome: income,
      totalExpense: expense,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await _service.getAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      date: date,
      note: note,
    );
    await _service.add(transaction);
    await load();
  }

  Future<void> deleteTransaction(String id) async {
    await _service.delete(id);
    await load();
  }
}
