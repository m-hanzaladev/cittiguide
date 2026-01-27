import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../theme/app_theme.dart';
import '../../providers/city_provider.dart';
import '../../models/city_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';

class AddEditCityScreen extends StatefulWidget {
  final CityModel? city;

  const AddEditCityScreen({super.key, this.city});

  @override
  State<AddEditCityScreen> createState() => _AddEditCityScreenState();
}

class _AddEditCityScreenState extends State<AddEditCityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
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
    _nameController = TextEditingController(text: widget.city?.name ?? '');
    _countryController = TextEditingController(text: widget.city?.country ?? '');
    _descriptionController = TextEditingController(text: widget.city?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.city?.imageUrl ?? '');
    _latController = TextEditingController(text: widget.city?.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: widget.city?.longitude?.toString() ?? '');
    
    // If the imageUrl is a path (doesn't start with http or data:), we might want to fetch it
    // But for preview, we'll just show it if it's already there or wait for new pick
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
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
          _imageUrlController.text = 'Picking local image...'; // Placeholder
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrlController.text.trim();
      final String cityId = widget.city?.id ?? 'city_${DateTime.now().millisecondsSinceEpoch}';

      // If we picked a new image, save it to the "images" folder in RTDB
      if (_pickedBase64 != null) {
        final String imagePath = 'cities/$cityId';
        await _databaseService.saveImage(imagePath, _pickedBase64!);
        finalImageUrl = imagePath; // Store the "folder path" in the city record
      }

      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final city = CityModel(
        id: widget.city?.id ?? '', 
        name: _nameController.text.trim(),
        country: _countryController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: finalImageUrl,
        latitude: double.tryParse(_latController.text.trim()),
        longitude: double.tryParse(_lngController.text.trim()),
      );

      if (widget.city == null) {
        await cityProvider.addCity(city);
      } else {
        await cityProvider.updateCity(city);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('City saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("SAVE ERROR (City): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving city: $e'),
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
      // Show local picked image
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
      // It's a "folder path" like cities/city1. We need to fetch it from RTDB
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
        title: Text(widget.city == null ? 'Add City' : 'Edit City'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'City Name',
                prefixIcon: Icons.location_city,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _countryController,
                hintText: 'Country',
                prefixIcon: Icons.flag,
                validator: (val) => val!.isEmpty ? 'Required' : null,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _latController,
                      hintText: 'Latitude (e.g. 48.8584)',
                      labelText: 'Latitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lngController,
                      hintText: 'Longitude (e.g. 2.2945)',
                      labelText: 'Longitude',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveCity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppTheme.backgroundColor)
                    : const Text(
                        'Save City',
                        style: TextStyle(
                          color: AppTheme.backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
