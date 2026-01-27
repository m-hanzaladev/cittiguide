import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  Widget _buildPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: placeholder ?? const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return SizedBox(
      width: width,
      height: height,
      child: errorWidget ?? const Center(child: Icon(Icons.error, color: Colors.white54)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: _buildImageContent(context),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (imageUrl.isEmpty) return _buildError();

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }

    if (imageUrl.startsWith('data:image')) {
      return _buildMemoryImage(imageUrl);
    }

    // It's likely a path in RTDB
    return FutureBuilder<String?>(
      future: DatabaseService().getImage(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          final String dataString = snapshot.data!;
          if (dataString.startsWith('data:image') || dataString.startsWith('http')) {
             if (dataString.startsWith('http')) {
               return Image.network(dataString, fit: fit, width: width, height: height, errorBuilder: (_, __, ___) => _buildError());
             }
             return _buildMemoryImage(dataString);
          }
        }
        return _buildError();
      },
    );
  }

  Widget _buildMemoryImage(String dataUri) {
    try {
      final uri = Uri.parse(dataUri);
      if (uri.data == null) return _buildError();
      
      return Image.memory(
        uri.data!.contentAsBytes(),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } catch (e) {
      debugPrint("AppImage Error: $e");
      return _buildError();
    }
  }
}
