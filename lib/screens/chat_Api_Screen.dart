import 'dart:convert';
import 'package:chat_app/models/chat_apI.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatGPTScreen extends StatefulWidget {
  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  late TextEditingController _messageController;
  String _response = '';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  Future<String> chatGPTAPI(String prompt) async {
    try {
      final res = ChatApi().res(prompt);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        setState(() {
          _response = content;
        });

        return content;
      }

      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  void _submitRequest() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await chatGPTAPI(message);
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _response));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Text(
                  'Response:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  _response,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _submitRequest,
                  child: Text('Submit'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: Text('Copy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
