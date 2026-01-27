import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../providers/category_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';
import '../../widgets/app_image.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _pickedBase64;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

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

  void _addCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String finalImageUrl = _imageUrlController.text.trim();
        final String categoryName = _nameController.text.trim();

        if (_pickedBase64 != null) {
          final String imagePath = 'categories/$categoryName';
          await _databaseService.saveImage(imagePath, _pickedBase64!);
          finalImageUrl = imagePath;
        }

        await Provider.of<CategoryProvider>(context, listen: false)
            .addCategory(categoryName, finalImageUrl);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully')),
          );
          _nameController.clear();
          _imageUrlController.clear();
          Navigator.pop(context); // Close dialog
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Error: $e'),
               backgroundColor: Colors.red,
             ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    _pickedBase64 = null;
    _imageUrlController.clear();
    _nameController.clear();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Add New Category', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hintText: 'Category Name',
                controller: _nameController,
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: 'Image URL or Path',
                      controller: _imageUrlController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await _pickImage();
                      setDialogState(() {}); // Refresh dialog UI
                    },
                    icon: const Icon(Icons.add_a_photo, color: AppTheme.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (_pickedBase64 != null || _imageUrlController.text.isNotEmpty)
                Container(
                  height: 100,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppImage(
                    imageUrl: _pickedBase64 ?? _imageUrlController.text,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addCategory,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Add'),
          ),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Theme.of(context).cardColor,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.categories.isEmpty
               ? Center(child: Text('No categories found', style: Theme.of(context).textTheme.bodyMedium))
               : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[800],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppImage(imageUrl: category.imageUrl),
                          ),
                        ),
                        title: Text(category.name, style: Theme.of(context).textTheme.bodyLarge),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                          onPressed: () async {
                             final confirm = await showDialog<bool>(
                               context: context,
                               builder: (ctx) => AlertDialog(
                                 backgroundColor: Theme.of(context).cardColor,
                                 title: Text('Delete Category?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                 content: Text('This cannot be undone.', style: TextStyle(color: Colors.grey)),
                                 actions: [
                                   TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                   TextButton(
                                     onPressed: () => Navigator.pop(ctx, true), 
                                     child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor))
                                   ),
                                 ],
                               ),
                             );
                             
                             if (confirm == true) {
                               await categoryProvider.deleteCategory(category.id);
                             }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
