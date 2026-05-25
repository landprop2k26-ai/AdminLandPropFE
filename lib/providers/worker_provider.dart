import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/worker.dart';

class WorkerProvider with ChangeNotifier {
  List<Worker> _workers = [];
  bool _isLoading = false;

  List<Worker> get workers => [..._workers];
  bool get isLoading => _isLoading;

  Future<void> fetchWorkers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/workers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _workers = data.map((item) => Worker.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching workers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> registerWorker({
    required String name,
    required String phone,
    required List<Map<String, dynamic>> skills,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/api/workers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'phone': phone,
          'skills': skills,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newWorker = Worker.fromJson(data);
        _workers.add(newWorker);
        notifyListeners();
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to register worker');
      }
    } catch (e) {
      print('Error registering worker: $e');
      rethrow;
    }
  }

  Future<bool> updateWorker({
    required String id,
    required String name,
    required String phone,
    required String status,
    required List<Map<String, dynamic>> skills,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:4000/api/workers/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'workerId': int.tryParse(id) ?? id,
          'name': name,
          'phone': phone,
          'status': status,
          'skills': skills,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedWorker = Worker.fromJson(data);
        final index = _workers.indexWhere((w) => w.id == id);
        if (index >= 0) {
          _workers[index] = updatedWorker;
          notifyListeners();
        }
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update worker');
      }
    } catch (e) {
      print('Error updating worker: $e');
      rethrow;
    }
  }

  void toggleWorkerStatus(String id) {
    // This is now handled by updateWorker, but keeping for local state if needed
  }

  Future<bool> deleteWorker(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:4000/api/workers/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _workers.removeWhere((w) => w.id == id);
        notifyListeners();
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete worker');
      }
    } catch (e) {
      print('Error deleting worker: $e');
      rethrow;
    }
  }

  double get totalEarningsMonth => _workers.fold(0, (sum, item) => sum + item.earningsThisMonth);
}
