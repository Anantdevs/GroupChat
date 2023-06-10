import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class editMessages {
  TextEditingController _textEditingController;
  String message;
  String documentId;
  bool isMe;
  bool reply = false;
  editMessages(
      this._textEditingController, this.message, this.documentId, this.isMe);

  void editChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text(
            'Edit Chat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: isMe
              ? TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: 'Enter new message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                )
              : null,
          actions: [
            if (isMe)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Change the button color as desired
                  onPrimary: Colors.white, // Change the text color as desired
                ),
                onPressed: () {
                  String newMessage = _textEditingController.text.trim();
                  // Perform the edit action here
                  updateChatText(newMessage, false);
                  print('Editing chat: $message to $newMessage');
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Change the button color as desired
                onPrimary: Colors.white, // Change the text color as desired
              ),
              onPressed: () {
                bool delete = true;
                updateChatText('This message is deleted', delete);
                // Perform the delete action here after a delay of 10 seconds
                Timer(Duration(seconds: 10), () {
                  deleteChat();
                });
                print('Deleting chat: $message');
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey, // Change the text color as desired
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteChat() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        firestore.collection('chat').doc(documentId);
    documentReference.delete().then((_) {
      print('Chat deleted successfully');
    }).catchError((error) {
      print('Failed to delete chat: $error');
    });
  }

  void updateChatText(String newText, bool delete) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        firestore.collection('chat').doc(documentId);
    documentReference
        .update({'text': newText, if (delete) 'imageUrl': ""}).then((_) {
      print('Chat text updated successfully');
    }).catchError((error) {
      print('Failed to update chat text: $error');
    });
  }
}
