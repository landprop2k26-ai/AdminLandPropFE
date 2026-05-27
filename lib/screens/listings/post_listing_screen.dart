import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/colors.dart';
import '../../models/service_model.dart';
import '../../models/property.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class PostListingScreen extends StatefulWidget {
  final Property? initialProperty;
  final VoidCallback? onComplete;

  const PostListingScreen({super.key, this.initialProperty, this.onComplete});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Hyderabad');
  final _stateController = TextEditingController(text: 'Telangana');
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaSqFtController = TextEditingController();
  final _plotAreaController = TextEditingController();
  final _amenitiesController = TextEditingController();

  List<ServiceModel> _mainServices = [];
  ServiceModel? _selectedMainService;
  SubOption? _selectedSubOption;
  bool _isLoadingServices = false;
  bool _isSubmitting = false;

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.initialProperty != null;

  @override
  void initState() {
    super.initState();
    _fetchMainServices().then((_) {
      if (isEditing) {
        _populateFields();
      }
    });
  }

  void _populateFields() {
    final p = widget.initialProperty!;
    _titleController.text = p.title;
    _descriptionController.text = p.description;
    _priceController.text = p.price.toInt().toString();
    _addressController.text = p.location.address;
    _cityController.text = p.location.city;
    _stateController.text = p.location.state;
    _postalCodeController.text = p.location.postalCode;
    _phoneController.text = p.contact.phone;
    _emailController.text = p.contact.email;
    _bedroomsController.text = p.bedrooms.toString();
    _bathroomsController.text = p.bathrooms.toString();
    _areaSqFtController.text = p.areaSqFt.toString();
    _plotAreaController.text = p.plotArea.toString();
    _amenitiesController.text = p.amenities.join(', ');

    try {
      _selectedMainService = _mainServices.firstWhere((s) => s.serviceId == p.serviceId);
      _selectedSubOption = _selectedMainService?.subOptions.firstWhere((so) => so.subOptionId == p.subOptionId);
    } catch (e) {
      print('Error selecting initial service/suboption: $e');
    }
    setState(() {});
  }

  Future<void> _fetchMainServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/services/all'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allServices = data.map((json) => ServiceModel.fromJson(json)).toList();
        setState(() {
          _mainServices = allServices.where((s) => s.serviceId == 9 || s.serviceId == 10).toList();
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
    } finally {
      setState(() => _isLoadingServices = false);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (var image in images) {
        final bytes = await image.readAsBytes();
        final sizeInMb = bytes.length / (1024 * 1024);
        if (sizeInMb > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image ${image.name} exceeds 5MB limit'), backgroundColor: Colors.red),
            );
          }
          continue;
        }
        setState(() {
          _selectedImages.add(image);
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final sizeInMb = bytes.length / (1024 * 1024);
      if (sizeInMb > 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo exceeds 5MB limit'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      setState(() {
        _selectedImages.add(photo);
      });
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_cityController.text.trim().toLowerCase() != 'hyderabad') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only Hyderabad allowed.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedMainService == null || _selectedSubOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select property type')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isRental = _selectedMainService!.serviceId == 10;
      final String endpoint = isRental ? 'rentals' : 'sales';
      final url = isEditing 
        ? Uri.parse('http://localhost:4000/$endpoint/${widget.initialProperty!.id}')
        : Uri.parse('http://localhost:4000/$endpoint');

      var request = http.MultipartRequest(isEditing ? 'PATCH' : 'POST', url);

      // Add simple fields
      if (isEditing) {
        request.fields[isRental ? "rentalId" : "saleId"] = widget.initialProperty!.id!.toString();
      }
      request.fields['serviceId'] = _selectedMainService!.serviceId.toString();
      request.fields['subOptionId'] = _selectedSubOption!.subOptionId.toString();
      request.fields['type'] = _selectedSubOption!.subOptionName;
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price'] = _priceController.text;
      request.fields['bedrooms'] = _bedroomsController.text.isEmpty ? "0" : _bedroomsController.text;
      request.fields['bathrooms'] = _bathroomsController.text.isEmpty ? "0" : _bathroomsController.text;
      request.fields['areaSqFt'] = _areaSqFtController.text.isEmpty ? "0" : _areaSqFtController.text;
      request.fields['plotArea'] = _plotAreaController.text.isEmpty ? "0" : _plotAreaController.text;
      
      // Handle nested objects by stringifying them (standard for Mixed FormData/JSON backends)
      request.fields['location'] = json.encode({
        "address": _addressController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "postalCode": _postalCodeController.text
      });

      request.fields['contact'] = json.encode({
        "phone": _phoneController.text,
        "email": _emailController.text
      });

      request.fields['amenities'] = json.encode(
        _amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
      );

      final dateKey = isRental ? "availableFrom" : "possessionDate";
      request.fields[dateKey] = isEditing 
          ? widget.initialProperty!.possessionDate 
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Add Image Files
      for (var image in _selectedImages) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'images', 
          bytes,
          filename: image.name, // This provides the filename as requested
        ));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Updated successfully' : 'Posted successfully'), backgroundColor: Colors.green),
          );
          if (widget.onComplete != null) {
            widget.onComplete!();
          } else {
            _resetForm();
          }
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _emailController.clear();
    _bedroomsController.clear();
    _bathroomsController.clear();
    _areaSqFtController.clear();
    _plotAreaController.clear();
    _amenitiesController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedMainService = null;
      _selectedSubOption = null;
    });
  }

  Widget _buildPropertySpecs() {
    final subName = _selectedSubOption?.subOptionName.toLowerCase() ?? '';
    final isLand = subName.contains('plot') || subName.contains('land');
    
    return Row(
      children: [
        if (!isLand) ...[
          Expanded(child: TextFormField(controller: _bedroomsController, decoration: const InputDecoration(labelText: 'Bedrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
          const SizedBox(width: 16),
          Expanded(child: TextFormField(controller: _bathroomsController, decoration: const InputDecoration(labelText: 'Bathrooms', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
          const SizedBox(width: 16),
        ],
        Expanded(child: TextFormField(controller: _areaSqFtController, decoration: const InputDecoration(labelText: 'Area (SqFt)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
        if (isLand) ...[
          const SizedBox(width: 16),
          Expanded(child: TextFormField(controller: _plotAreaController, decoration: const InputDecoration(labelText: 'Plot Area', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
        ],
      ],
    );
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
                  Text(isEditing ? 'Edit Listing' : 'Post New Listing', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (isEditing) 
                    TextButton.icon(onPressed: widget.onComplete, icon: const Icon(Icons.arrow_back), label: const Text('Back to List')),
                ],
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ServiceModel>(
                      value: _selectedMainService,
                      decoration: const InputDecoration(labelText: 'Main Category', border: OutlineInputBorder()),
                      items: _mainServices.map((service) {
                        return DropdownMenuItem(value: service, child: Text(service.serviceName));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMainService = val;
                          _selectedSubOption = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: DropdownButtonFormField<SubOption>(
                      value: _selectedSubOption,
                      decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
                      items: _selectedMainService?.subOptions.map((sub) {
                        return DropdownMenuItem(value: sub, child: Text(sub.subOptionName));
                      }).toList() ?? [],
                      onChanged: (val) => setState(() => _selectedSubOption = val),
                      hint: const Text('Select Type'),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Listing Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
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
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Location Details', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      validator: (val) => val?.toLowerCase() != 'hyderabad' ? 'Only Hyderabad' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _postalCodeController, decoration: const InputDecoration(labelText: 'Postal Code', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Property Specifications', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPropertySpecs(),
              const SizedBox(height: 24),
              const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amenitiesController,
                decoration: const InputDecoration(labelText: 'Amenities (comma separated)', border: OutlineInputBorder(), hintText: 'Parking, Gym, Lift'),
              ),
              const SizedBox(height: 24),
              const Text('Photos (Max 5MB each)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (isEditing) ...widget.initialProperty!.images.map((img) => Container(
                    width: 100, height: 100, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: Image.network(
                      img, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                    ),
                  )),
                  ..._selectedImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb ? Image.network(image.path, fit: BoxFit.cover) : Image.file(File(image.path), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(right: -5, top: -5, child: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => setState(() => _selectedImages.remove(image)))),
                      ],
                    );
                  }),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _pickImages(); }),
                              ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Camera'), onTap: () { Navigator.pop(context); _takePhoto(); }),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(border: Border.all(color: AppColors.accent, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8), color: AppColors.accent.withOpacity(0.05)),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: AppColors.accent), Text('Add Photo', style: TextStyle(color: AppColors.accent, fontSize: 12))]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Listing' : 'Post Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
