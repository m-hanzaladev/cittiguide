import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/storage_service.dart';
import '../../services/database_service.dart';
import '../../widgets/app_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _pickedBase64;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error picking profile image: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        String finalImageUrl = currentUser.profilePicture ?? '';

        // If we picked a new image, save it
        if (_pickedBase64 != null) {
          final String imagePath = 'users/${currentUser.id}';
          await _databaseService.saveImage(imagePath, _pickedBase64!);
          finalImageUrl = imagePath;
        }

        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          profilePicture: finalImageUrl,
        );
        
        await authProvider.updateUserProfile(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      }
      
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    String nameToDisplay = _nameController.text.trim();
    if (nameToDisplay.isEmpty) {
        nameToDisplay = user?.name ?? '?';
    }
    String initial = nameToDisplay.isNotEmpty ? nameToDisplay.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check, color: AppTheme.primaryColor),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _pickedBase64 != null
                            ? Image.memory(
                                Uri.parse(_pickedBase64!).data!.contentAsBytes(),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                                ? AppImage(
                                imageUrl: user.profilePicture!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppTheme.backgroundColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Please enter your name' : null,
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: TextEditingController(text: user?.email ?? ''),
                labelText: 'Email',
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
