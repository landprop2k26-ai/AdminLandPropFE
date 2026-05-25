import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker.dart';
import '../../models/service_model.dart';
import '../../providers/worker_provider.dart';
import '../../providers/service_provider.dart';
import '../../constants/colors.dart';

class AddWorkerScreen extends StatefulWidget {
  final Worker? initialWorker;
  final VoidCallback? onCancel;

  const AddWorkerScreen({super.key, this.initialWorker, this.onCancel});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<Map<String, dynamic>> _selectedSkills = [];
  ServiceModel? _selectedService;
  bool _isSubmitting = false;
  bool _isActive = true;

  bool get isEditing => widget.initialWorker != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.initialWorker!.name;
      _phoneController.text = widget.initialWorker!.phone ?? '';
      _isActive = widget.initialWorker!.isActive;
      _selectedSkills.addAll(widget.initialWorker!.rawSkills);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

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
                  Text(isEditing ? 'Edit Worker' : 'Add New Worker',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (isEditing && widget.onCancel != null)
                    TextButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to List'),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Worker Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter a name' : null,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a phone number';
                        if (value.length < 10) return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (isEditing) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Worker Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Switch(
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      activeColor: AppColors.accent,
                    ),
                    Text(_isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                            color: _isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              const Text('Select Service Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              if (serviceProvider.isLoading)
                const CircularProgressIndicator()
              else
                DropdownButtonFormField<ServiceModel>(
                  value: _selectedService,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose a service category',
                  ),
                  items: serviceProvider.services.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(service.serviceName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedService = val;
                    });
                  },
                ),
              const SizedBox(height: 32),
              if (_selectedService != null) ...[
                Text('Select Skills in ${_selectedService!.serviceName}',
                    style:
                        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                if (_selectedService!.subOptions.isEmpty)
                  const Text('No specific skills listed for this category.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _selectedService!.subOptions.map((sub) {
                      final isSelected = _selectedSkills.any((s) => 
                        s['subOptionId'].toString() == sub.subOptionId.toString() && 
                        s['serviceId'].toString() == _selectedService!.serviceId.toString()
                      );
                      
                      return FilterChip(
                        label: Text(sub.subOptionName),
                        selected: isSelected,
                        selectedColor: AppColors.accent.withOpacity(0.2),
                        checkmarkColor: AppColors.accent,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add({
                                "serviceId": _selectedService!.serviceId.toString(),
                                "subOptionId": sub.subOptionId.toString(),
                                "categoryId": _selectedService!.serviceId.toString(),
                                "subCategoryId": sub.subOptionId.toString(),
                                "subCategoryName": sub.subOptionName,
                              });
                            } else {
                              _selectedSkills.removeWhere((s) => 
                                s['subOptionId'].toString() == sub.subOptionId.toString() && 
                                s['serviceId'].toString() == _selectedService!.serviceId.toString()
                              );
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
              if (_selectedSkills.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text('Assigned Skills:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedSkills
                      .map((skill) => Chip(
                            label: Text(skill['subCategoryName'] ?? 'Skill', style: const TextStyle(fontSize: 12)),
                            onDeleted: () {
                              setState(() => _selectedSkills.remove(skill));
                            },
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 48),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveWorker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(isEditing ? 'Update Worker' : 'Save Worker', style: const TextStyle(fontSize: 16)),
                  ),
                  if (isEditing) ...[
                    const SizedBox(width: 20),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _deleteWorker,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete Worker', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(150, 50),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteWorker() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this worker? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSubmitting = true);
      try {
        await Provider.of<WorkerProvider>(context, listen: false).deleteWorker(widget.initialWorker!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker deleted successfully')));
          if (widget.onCancel != null) widget.onCancel!();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _saveWorker() async {
    if (_formKey.currentState!.validate() && _selectedSkills.isNotEmpty) {
      setState(() => _isSubmitting = true);
      try {
        bool success;
        if (isEditing) {
          success = await Provider.of<WorkerProvider>(context, listen: false).updateWorker(
            id: widget.initialWorker!.id,
            name: _nameController.text,
            phone: _phoneController.text,
            status: _isActive ? 'active' : 'inactive',
            skills: _selectedSkills,
          );
        } else {
          success = await Provider.of<WorkerProvider>(context, listen: false).registerWorker(
            name: _nameController.text,
            phone: _phoneController.text,
            skills: _selectedSkills,
          );
        }

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(isEditing ? 'Worker updated successfully' : 'Worker registered successfully'),
                backgroundColor: Colors.green),
          );
          if (isEditing) {
            if (widget.onCancel != null) widget.onCancel!();
          } else {
            _nameController.clear();
            _phoneController.clear();
            setState(() {
              _selectedSkills.clear();
              _selectedService = null;
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
    }
  }
}
