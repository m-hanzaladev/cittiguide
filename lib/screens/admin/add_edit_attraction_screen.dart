import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/attraction_provider.dart';
import '../../models/attraction_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_constants.dart';

class AddEditAttractionScreen extends StatefulWidget {
  final String cityId;
  final AttractionModel? attraction;

  const AddEditAttractionScreen({
    super.key,
    required this.cityId,
    this.attraction,
  });

  @override
  State<AddEditAttractionScreen> createState() => _AddEditAttractionScreenState();
}

class _AddEditAttractionScreenState extends State<AddEditAttractionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _priceRangeController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.attraction;
    _nameController = TextEditingController(text: a?.name ?? '');
    _categoryController = TextEditingController(text: a?.category ?? '');
    _descriptionController = TextEditingController(text: a?.description ?? '');
    _imageUrlController = TextEditingController(text: a?.imageUrls.isNotEmpty == true ? a!.imageUrls.first : '');
    _priceRangeController = TextEditingController(text: a?.priceRange ?? '');
    _addressController = TextEditingController(text: a?.location.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceRangeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAttraction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AttractionProvider>(context, listen: false);
      
      final attraction = AttractionModel(
        id: widget.attraction?.id ?? '',
        cityId: widget.cityId,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: _imageUrlController.text.isNotEmpty ? [_imageUrlController.text.trim()] : [],
        priceRange: _priceRangeController.text.trim(),
        location: LocationData(
          latitude: 0, // Placeholder
          longitude: 0, // Placeholder
          address: _addressController.text.trim(),
        ),
        contactInfo: widget.attraction?.contactInfo ?? ContactInfo(),
      );

      if (widget.attraction == null) {
        await provider.addAttraction(attraction);
      } else {
        await provider.updateAttraction(attraction);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attraction saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.attraction == null ? 'Add Attraction' : 'Edit Attraction'),
        backgroundColor: AppTheme.surfaceColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Attraction Name',
                prefixIcon: Icons.place,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _categoryController,
                hintText: 'Category (e.g. Park, Museum)',
                prefixIcon: Icons.category,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceRangeController,
                hintText: 'Price Range (Free, \$, \$\$)',
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                hintText: 'Address',
                prefixIcon: Icons.map,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                hintText: 'Image URL',
                prefixIcon: Icons.image,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description',
                prefixIcon: Icons.description,
                maxLines: 5,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAttraction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Save Attraction', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
