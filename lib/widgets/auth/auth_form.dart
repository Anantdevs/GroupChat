// ignore_for_file: prefer_const_constructors

import 'package:chat_app/widgets/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
  ) submitFn;
  AuthForm(
    this.submitFn,
    this.isLoading,
  );
  final bool isLoading;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';
  var _isLogin = true;
  var _isobsecure = false;
  var _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Pick an image.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userImageFile,
        _isLogin,
      );

      //use those values to send our auth request
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (!_isLogin) UserImagePicker(_pickedImage),
                TextFormField(
                  key: ValueKey('email'),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email addrress',
                  ),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('username'),
                    decoration: InputDecoration(labelText: 'User Name'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Please enter at least 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password must be atleast 7 characters long.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isobsecure = !_isobsecure;
                          });
                        },
                        icon: _isobsecure
                            ? Icon(Icons.lock_open)
                            : Icon(Icons.lock)),
                  ),
                  obscureText: !_isobsecure,
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'Login' : 'Signup'),
                  ),
                if (!widget.isLoading)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    child: Text(_isLogin
                        ? 'Create an acoount'
                        : 'I already have an account'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
