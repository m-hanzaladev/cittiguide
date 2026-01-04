import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(XFile file, String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_pic_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final data = await file.readAsBytes();
      final snapshot = await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Image upload failed: ${e.toString()}';
    }
  }

  Future<String> uploadCityImage(XFile file, String cityId) async {
    try {
      final ref = _storage.ref().child('cities/$cityId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final data = await file.readAsBytes();
      await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'City upload failed: ${e.toString()}';
    }
  }
  
  Future<String> uploadAttractionImage(XFile file, String attractionId) async {
    try {
      final ref = _storage.ref().child('attractions/$attractionId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final data = await file.readAsBytes();
      await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Attraction upload failed: ${e.toString()}';
    }
  }
}
