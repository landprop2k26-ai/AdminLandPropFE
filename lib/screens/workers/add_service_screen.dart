import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_details.dart';
import '../../providers/service_provider.dart';
import '../../constants/colors.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceDetails? initialService;
  final VoidCallback? onComplete;

  const AddServiceScreen({super.key, this.initialService, this.onComplete});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<_SubCategoryControllers> _subControllers = [];
  bool _isSubmitting = false;

  bool get isEditing => widget.initialService != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.initialService!.name;
      _categoryController.text = widget.initialService!.category;
      for (var sub in widget.initialService!.subCategories) {
        _subControllers.add(_SubCategoryControllers(
          name: TextEditingController(text: sub.subCategoryName),
          price: TextEditingController(text: sub.price.toInt().toString()),
          time: TextEditingController(text: sub.time),
          id: sub.subCategoryId,
          rating: sub.rating,
          reviews: sub.reviews,
        ));
      }
    }
    if (_subControllers.isEmpty) {
      _addSubCategory();
    }
  }

  void _addSubCategory() {
    setState(() {
      _subControllers.add(_SubCategoryControllers(
        name: TextEditingController(),
        price: TextEditingController(),
        time: TextEditingController(),
        id: DateTime.now().millisecondsSinceEpoch % 1000,
        rating: 0.0,
        reviews: 0,
      ));
    });
  }

  void _removeSubCategory(int index) {
    setState(() {
      _subControllers.removeAt(index);
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final List<DetailedSubCategory> subCategories = _subControllers.map((c) {
        return DetailedSubCategory(
          subCategoryName: c.name.text,
          price: double.tryParse(c.price.text) ?? 0.0,
          time: c.time.text,
          subCategoryId: c.id,
          rating: c.rating,
          reviews: c.reviews,
        );
      }).toList();

      final provider = Provider.of<ServiceProvider>(context, listen: false);
      bool success;

      if (isEditing) {
        final updated = ServiceDetails(
          id: widget.initialService!.id,
          serviceId: widget.initialService!.serviceId,
          subOptionId: widget.initialService!.subOptionId,
          categoryId: widget.initialService!.categoryId,
          name: _nameController.text,
          category: _categoryController.text,
          subCategories: subCategories,
        );
        success = await provider.updateServiceDetails(updated);
      } else {
        final newData = {
          "serviceId": 1, // Default or dynamic
          "subOptionId": 1,
          "categoryId": 1,
          "name": _nameController.text,
          "category": _categoryController.text,
          "subCategories": subCategories.map((s) => s.toJson()).toList(),
        };
        success = await provider.createServiceDetails(newData);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Updated' : 'Created'), backgroundColor: Colors.green),
          );
          widget.onComplete?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? 'Edit Service Details' : 'Add Service Detail',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: widget.onComplete,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to List'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service Name (e.g. Electrician)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category (e.g. Repair & Maintenance)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              const Text('Sub-Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(_subControllers.length, (index) {
                final c = _subControllers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: c.name,
                                decoration: const InputDecoration(labelText: 'Sub-Category Name', border: OutlineInputBorder()),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: c.price,
                                decoration: const InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: c.time,
                                decoration: const InputDecoration(labelText: 'Time (e.g. 60 mins)', border: OutlineInputBorder()),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _removeSubCategory(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: _addSubCategory,
                icon: const Icon(Icons.add),
                label: const Text('Add Sub-Category'),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Details' : 'Save Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubCategoryControllers {
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController time;
  final int id;
  final double rating;
  final int reviews;

  _SubCategoryControllers({
    required this.name,
    required this.price,
    required this.time,
    required this.id,
    required this.rating,
    required this.reviews,
  });
}
