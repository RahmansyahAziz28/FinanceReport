// lib/services/transaction_service.dart

import 'dart:convert';
import 'package:financialreport/models/trxModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  static const _storageKey = 'transactions';

  Future<List<TransactionModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((e) => TransactionModel.fromJson(jsonDecode(e))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(TransactionModel transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? [];
    existing.add(jsonEncode(transaction.toJson()));
    await prefs.setStringList(_storageKey, existing);
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? [];
    existing.removeWhere((e) {
      final decoded = jsonDecode(e) as Map<String, dynamic>;
      return decoded['id'] == id;
    });
    await prefs.setStringList(_storageKey, existing);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
