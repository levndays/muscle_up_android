// lib/core/services/image_picker_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:developer' as developer;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  Future<File?> pickAndCropImage({
    ImageSource source = ImageSource.gallery,
    CropStyle cropStyle = CropStyle.circle,
    int maxWidth = 512,
    int maxHeight = 512,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        developer.log('Image picking cancelled by user.', name: 'ImagePickerService');
        return null;
      }
      developer.log('Image picked: ${pickedFile.path}', name: 'ImagePickerService');

      final CroppedFile? croppedFile = await _cropper.cropImage(
        sourcePath: pickedFile.path,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 75,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFFED5D1A),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: cropStyle, // <-- MOVED HERE
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockDimensionSwapEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        developer.log('Image cropped successfully: ${croppedFile.path}', name: 'ImagePickerService');
        return File(croppedFile.path);
      }
      developer.log('Image cropping cancelled by user.', name: 'ImagePickerService');
      return null;
    } catch (e, s) {
      developer.log('Error picking/cropping image: $e', name: 'ImagePickerService', error: e, stackTrace: s);
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        developer.log('Image picked from gallery: ${pickedFile.path}', name: 'ImagePickerService');
        return File(pickedFile.path);
      }
      developer.log('Image picking from gallery cancelled by user.', name: 'ImagePickerService');
      return null;
    } catch (e, s) {
      developer.log('Error picking image from gallery: $e', name: 'ImagePickerService', error: e, stackTrace: s);
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