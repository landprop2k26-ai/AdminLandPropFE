import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/property.dart';

class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  PropertyType _selectedType = PropertyType.land;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Post New Listing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              DropdownButtonFormField<PropertyType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
                items: PropertyType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Listing Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), prefixText: '₹'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(labelText: 'Size (e.g. 200 sq yd)', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property posted successfully')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Post Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
