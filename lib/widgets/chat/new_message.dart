import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class NewMessage extends StatefulWidget {
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _controller = TextEditingController();
  String _enteredMessage = '';
  File? _selectedImage;
  String? _imageUrl;
  bool send = false;
  bool Reply = false;
  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 400,
    );
    if (pickedImage != null) {
      setState(() {
        send = true;
        _selectedImage = File(pickedImage.path);
        _imageUrl = null;
      });
    }
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final timestamp = Timestamp.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child('image_url')
        .child('${user?.uid}.jpg');

    if (_selectedImage != null) {
      await ref.putFile(_selectedImage!);
    }
    final imageUrl = _selectedImage != null ? await ref.getDownloadURL() : '';

    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': timestamp,
      'userId': user?.uid,
      'username': userData['username'],
      'userImage': userData['image_url'],
      if (_selectedImage != null) 'imageUrl': imageUrl,
      if (_selectedImage == null) 'imageUrl': '',
    });

    _controller.clear();
    setState(() {
      _enteredMessage = '';
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Choose an Image'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          GestureDetector(
                            child: const Text('Gallery'),
                            onTap: () {
                              _getImage(ImageSource.gallery);
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 8.0),
                          GestureDetector(
                            child: const Text('Camera'),
                            onTap: () {
                              _getImage(
                                ImageSource.camera,
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty && _selectedImage == null
                ? null
                : _sendMessage,
            icon: const Icon(Icons.send),
          ),
          if (_selectedImage != null)
            Image.file(
              _selectedImage!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }
}
