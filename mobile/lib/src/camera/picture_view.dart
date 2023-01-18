import 'dart:io';

import 'package:flutter/material.dart';

class PictureView extends StatelessWidget {
  final String imagePath;

  const PictureView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
