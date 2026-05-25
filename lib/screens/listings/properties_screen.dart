import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../constants/colors.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final properties = [
      Property(id: '1', title: '3BHK Flat, Banjara Hills', location: 'Hyderabad', type: PropertyType.flat, status: PropertyStatus.active, price: 20000, size: '1,600 sqft'),
      Property(id: '2', title: 'Open Plot, Kompally', location: 'Hyderabad', type: PropertyType.plot, status: PropertyStatus.sold, price: 4200000, size: '200 sq yd'),
      Property(id: '3', title: 'Office Space, Madhapur', location: 'Hyderabad', type: PropertyType.office, status: PropertyStatus.active, price: 40000, size: '500 sqft'),
    ];

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Property Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(property.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(property.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₹${property.price}', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: property.status == PropertyStatus.active ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    property.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: property.status == PropertyStatus.active ? Colors.green : Colors.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
