import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickfn);
  final void Function(File pickedImage) imagePickfn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  // var pickedImageFile;
  File? _pickedImage;

  void _pickImage() async {
    ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text("Choose image source"), actions: [
        TextButton(
          child: Text("Camera"),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        TextButton(
          child: Text("Gallery"),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ]),
    );

    if (source != null) {
      final pickedFile = await ImagePicker().getImage(
        source: source,
        imageQuality: 50,
        maxWidth: 150,
      );
      setState(() => _pickedImage = File(pickedFile!.path));
      widget.imagePickfn(_pickedImage!);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          // Navigator.of(context).pop()
          style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor),
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
