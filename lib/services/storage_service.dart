import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class StorageService {
  // Utility to convert picked image to Base64
  Future<String> fileToBase64(XFile file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      // Determine content type (default to jpeg for simplicity or detect from extension)
      final String extension = file.path.split('.').last.toLowerCase();
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint("Error converting to Base64: $e");
      rethrow;
    }
  }
}
