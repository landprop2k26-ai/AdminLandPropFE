import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceProvider with ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/services/all'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _services = data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        // Fallback to mock data if API fails
        _services = _getMockServices();
      }
    } catch (e) {
      print('Error fetching services: $e');
      _services = _getMockServices();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ServiceModel> _getMockServices() {
    return [
      ServiceModel(
        serviceId: 1,
        serviceName: "Home Maintenance Services",
        category: "Home Maintenance Services",
        subOptions: [
          SubOption(subOptionId: 1, subOptionName: "Electrician", category: "Home Maintenance Services"),
          SubOption(subOptionId: 2, subOptionName: "Carpenter", category: "Home Maintenance Services"),
          SubOption(subOptionId: 3, subOptionName: "Plumber", category: "Home Maintenance Services"),
        ],
      ),
      ServiceModel(
        serviceId: 2,
        serviceName: "Appliance Repair",
        category: "Appliance Repair",
        subOptions: [
          SubOption(subOptionId: 1, subOptionName: "AC Repair", category: "Appliance Repair"),
          SubOption(subOptionId: 2, subOptionName: "Refrigerator Repair", category: "Appliance Repair"),
        ],
      ),
      ServiceModel(
        serviceId: 3,
        serviceName: "Painting & Water Proofing",
        category: "Painting & Water Proofing",
        subOptions: [
          SubOption(subOptionId: 1, subOptionName: "Interior Painting", category: "Painting & Water Proofing"),
        ],
      ),
    ];
  }
}
