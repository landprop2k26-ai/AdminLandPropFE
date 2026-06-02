import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/service_details.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceDetails> _serviceDetails = [];
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  List<ServiceDetails> get serviceDetails => _serviceDetails;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/services/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchServiceDetails({int? serviceId, int? subOptionId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      String url = 'http://localhost:4000/servicedetails';
      List<String> params = [];
      if (serviceId != null) params.add('serviceId=$serviceId');
      if (subOptionId != null) params.add('subOptionId=$subOptionId');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _serviceDetails = data.map((json) => ServiceDetails.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching service details: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateServiceDetails(ServiceDetails details) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:4000/servicedetails/${details.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(details.toUpdateJson()),
      );
      if (response.statusCode == 200) {
        await fetchServiceDetails();
        return true;
      }
    } catch (e) {
      print('Error updating service details: $e');
    }
    return false;
  }

  Future<bool> createServiceDetails(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/servicedetails'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchServiceDetails();
        return true;
      }
    } catch (e) {
      print('Error creating service details: $e');
    }
    return false;
  }
}
