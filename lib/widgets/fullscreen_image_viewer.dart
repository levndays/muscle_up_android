// lib/widgets/fullscreen_image_viewer.dart
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageProvider,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: heroTag != null
              ? Hero(
                  tag: heroTag!,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                )
              : Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}