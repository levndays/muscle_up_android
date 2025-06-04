// lib/core/services/image_picker_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Стиснення зображення для економії місця та трафіку
        maxWidth: 1024, // Обмеження максимальної ширини
        maxHeight: 1024, // Обмеження максимальної висоти
      );
      if (pickedFile != null) {
        developer.log('Image picked from gallery: ${pickedFile.path}', name: 'ImagePickerService');
        return File(pickedFile.path);
      }
      developer.log('Image picking from gallery cancelled by user.', name: 'ImagePickerService');
      return null;
    } catch (e, s) {
      developer.log('Error picking image from gallery: $e', name: 'ImagePickerService', error: e, stackTrace: s);
      // Можна додати обробку specific exceptions від image_picker, якщо потрібно
      return null;
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        developer.log('Image taken with camera: ${pickedFile.path}', name: 'ImagePickerService');
        return File(pickedFile.path);
      }
      developer.log('Image capture with camera cancelled by user.', name: 'ImagePickerService');
      return null;
    } catch (e, s) {
      developer.log('Error taking image with camera: $e', name: 'ImagePickerService', error: e, stackTrace: s);
      return null;
    }
  }
}