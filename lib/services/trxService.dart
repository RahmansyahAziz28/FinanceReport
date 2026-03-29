import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:financialreport/models/trxModel.dart';

class TransactionService {
  final String baseUrl = "https://script.google.com/macros/s/AKfycbwQ-qtQanVUAlIgAUHpMNJ-PiRUvd23cXyWlUhNMhLHVzUqC5yLB0MMq1m62kM13o3GKg/exec";

  Future<List<TransactionModel>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    
    final List data = jsonDecode(res.body);
    return data.map((e) => TransactionModel.fromJson(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(TransactionModel trx) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(trx.toJson()),
    );
  }

  Future<void> delete(String id) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "delete", "id": id}),
    );
  }
}
