import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String userImage;
  ProfileScreen(this.username, this.userImage);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String _newUsername = '';
  bool _isUpdating = false;
  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> updateProfile() async {
    setState(() {
      _isUpdating = true;
    });
    if (_newUsername.isNotEmpty || _image != null) {
      final user = FirebaseAuth.instance.currentUser;
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('${user?.uid}.jpg');
      if (_image != null) {
        await ref.putFile(_image!);
      }
      final imageUrl =
          _image != null ? await ref.getDownloadURL() : widget.userImage;
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({
          'username': _newUsername.isNotEmpty ? _newUsername : widget.username,
          'image_url': imageUrl,
        });
        final chatSnapshot = await FirebaseFirestore.instance
            .collection('chat')
            .where('userId', isEqualTo: user?.uid)
            .get();
        final chatDocs = chatSnapshot.docs;
        for (final doc in chatDocs) {
          await doc.reference.update({
            'username':
                _newUsername.isNotEmpty ? _newUsername : widget.username,
            'userImage': imageUrl,
          });
        }
        print('Profile updated successfully');
      } catch (error) {
        print('Failed to update profile: $error');
      }
      setState(() {
        _isUpdating = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: getImageFromGallery,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 200,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(widget.userImage)
                              as ImageProvider<Object>?,
                    ),
                    if (_image == null)
                      Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: getImageFromGallery,
                child: Text('Change Image'),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _newUsername = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter new username',
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateProfile,
                child: _isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
