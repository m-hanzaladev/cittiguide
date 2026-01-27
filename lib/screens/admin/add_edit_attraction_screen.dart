import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../theme/app_theme.dart';
import '../../providers/attraction_provider.dart';
import '../../models/attraction_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_constants.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';

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
  late TextEditingController _latController;
  late TextEditingController _lngController;
  bool _isLoading = false;
  String? _pickedBase64;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

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
    _latController = TextEditingController(text: a?.location.latitude.toString() ?? '');
    _lngController = TextEditingController(text: a?.location.longitude.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceRangeController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        final base64 = await _storageService.fileToBase64(image);
        setState(() {
          _pickedBase64 = base64;
          _imageUrlController.text = 'Picking local image...';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAttraction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AttractionProvider>(context, listen: false);
      
      String finalImageUrl = _imageUrlController.text.trim();
      final String attractionId = widget.attraction?.id ?? 'attr_${DateTime.now().millisecondsSinceEpoch}';

      if (_pickedBase64 != null) {
        final String imagePath = 'attractions/$attractionId';
        await _databaseService.saveImage(imagePath, _pickedBase64!);
        finalImageUrl = imagePath;
      }

      final attraction = AttractionModel(
        id: widget.attraction?.id ?? '',
        cityId: widget.cityId,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: finalImageUrl.isNotEmpty ? [finalImageUrl] : [],
        priceRange: _priceRangeController.text.trim(),
        location: LocationData(
          latitude: double.tryParse(_latController.text.trim()) ?? 0, 
          longitude: double.tryParse(_lngController.text.trim()) ?? 0, 
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attraction saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attraction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedBase64 != null) {
      final UriData data = Uri.parse(_pickedBase64!).data!;
      return Image.memory(data.contentAsBytes(), fit: BoxFit.cover);
    }

    final String url = _imageUrlController.text;
    if (url.startsWith('http')) {
      return Image.network(
        url, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.white54)),
      );
    }

    if (url.startsWith('data:image')) {
       final UriData data = Uri.parse(url).data!;
       return Image.memory(data.contentAsBytes(), fit: BoxFit.cover);
    }

    if (url.isNotEmpty && !url.contains('Picking')) {
      return FutureBuilder<String?>(
        future: _databaseService.getImage(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            final UriData data = Uri.parse(snapshot.data!).data!;
            return Image.memory(data.contentAsBytes(), fit: BoxFit.cover);
          }
          return const Center(child: Icon(Icons.image_not_supported, color: Colors.white54));
        },
      );
    }

    return const Center(child: Icon(Icons.image, color: Colors.white24, size: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.attraction == null ? 'Add Attraction' : 'Edit Attraction'),
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
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
                labelText: 'Address',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: CustomTextField(
                      controller: _latController,
                      hintText: 'Latitude',
                      labelText: 'Latitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lngController,
                      hintText: 'Longitude',
                      labelText: 'Longitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _imageUrlController,
                      hintText: 'Image URL or Path',
                      prefixIcon: Icons.image,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _pickImage,
                    icon: Icon(Icons.add_a_photo, color: AppTheme.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildImagePreview(),
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
                    : const Text(
                        'Save Attraction', 
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
