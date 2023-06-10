import 'package:chat_app/models/chat_apI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chat/messages.dart';
import '../widgets/chat/new_message.dart';
import 'chat_Api_Screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchBar = false;

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _searchChats(String searchText) {
    _updateSearchQuery(searchText);
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _searchController.clear();
        _updateSearchQuery('');
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _chatIconPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatGPTScreen(),
      ),
    );
  }

  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _toggleSearchBar,
            icon: const Icon(
              Icons.search,
            ),
          ),
          title: const Text('Flutter chat'),
          actions: [
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 'Logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      Text('Logout')
                    ],
                  ),
                )
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'Logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
              icon: const Icon(
                Icons.more_vert,
                color: Colors.amber,
              ),
            ),
            IconButton(
              icon: Icon(
                _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                color: Colors.amber,
              ),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showSearchBar ? 56 : 0,
                curve: Curves.easeInOut,
                child: Visibility(
                  visible: _showSearchBar,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchChats,
                      decoration: InputDecoration(
                        labelText: 'Search Chats',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.chat),
                          onPressed: () => _chatIconPressed(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Messages(searchQuery: _searchQuery),
              ),
              NewMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
