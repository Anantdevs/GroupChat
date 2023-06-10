import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagepickerDialog {
  PickerDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Choose image source",
        ),
        actions: [
          TextButton(
            child: const Text("Camera"),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: const Text("Gallery"),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
