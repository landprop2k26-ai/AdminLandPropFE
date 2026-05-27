import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/property.dart';
import '../../constants/colors.dart';

class PropertiesScreen extends StatefulWidget {
  final Function(Property) onEdit;

  const PropertiesScreen({super.key, required this.onEdit});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<Property> _properties = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() => _isLoading = true);
    try {
      final salesResponse = await http.get(Uri.parse('http://localhost:4000/sales'));
      final rentalsResponse = await http.get(Uri.parse('http://localhost:4000/rentals'));

      List<Property> loadedProperties = [];

      if (salesResponse.statusCode == 200) {
        final List<dynamic> salesData = json.decode(salesResponse.body);
        loadedProperties.addAll(salesData.map((json) => Property.fromJson(json)));
      }
      if (rentalsResponse.statusCode == 200) {
        final List<dynamic> rentalsData = json.decode(rentalsResponse.body);
        loadedProperties.addAll(rentalsData.map((json) => Property.fromJson(json)));
      }

      setState(() {
        _properties = loadedProperties;
      });
    } catch (e) {
      print('Error fetching properties: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Property Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(onPressed: _fetchProperties, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _properties.isEmpty
                ? const Center(child: Text('No properties found.'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: property.images.isNotEmpty 
                                      ? Image.network(
                                          property.images.first, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                            const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                        )
                                      : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(property.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                            IconButton(
                                              onPressed: () => widget.onEdit(property), 
                                              icon: const Icon(Icons.edit, size: 20, color: AppColors.accent),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${property.location.city}, ${property.areaSqFt} sqft', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹${property.price.toInt()}${property.isRental ? "/mo" : ""}', 
                                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                              child: Text(
                                                property.isRental ? 'RENTAL' : 'SALE', 
                                                style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (property.amenities.isNotEmpty)
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: property.amenities.take(2).map((a) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                                              child: Text(a, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                            )).toList(),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  ),
          ),
        ],
      ),
    );
  }
}
