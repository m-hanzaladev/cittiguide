import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

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

  void _addCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<CategoryProvider>(context, listen: false)
            .addCategory(_nameController.text, _imageUrlController.text);
        
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
             SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              CustomTextField(
                hintText: 'Image URL',
                controller: _imageUrlController,
                // placeholder was also valid? No, CustomTextField has no placeholder. Just hintText.
                // Wait, previous code had placeholder: '...' in second usage.
                // Let's check CustomTextField again. It has hintText only.
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
          onPressed: () => Navigator.pop(context),
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
                            image: category.imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(category.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {},
                                  )
                                : null,
                            color: Colors.grey[800],
                          ),
                          child: category.imageUrl.isEmpty ? const Icon(Icons.category) : null,
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
                                 content: const Text('This cannot be undone.', style: TextStyle(color: Colors.grey)),
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
