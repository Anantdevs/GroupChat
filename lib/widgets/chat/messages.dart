import 'package:chat_app/widgets/chat/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  final String searchQuery;

  Messages({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    Future<User?> data() async {
      return FirebaseAuth.instance.currentUser;
    }

    return FutureBuilder(
      future: data(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final chatDocs = chatSnapshot.data?.docs;
            final filteredChatDocs = chatDocs
                ?.where((doc) => doc['text']
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

            return ListView.builder(
              reverse: searchQuery == '' ? true : false,
              itemCount: filteredChatDocs != null ? filteredChatDocs.length : 0,
              itemBuilder: (ctx, index) => filteredChatDocs != null
                  ? MessageBubble(
                      filteredChatDocs,
                      index,
                      filteredChatDocs[index]['text'],
                      filteredChatDocs[index]['username'],
                      filteredChatDocs[index]['userImage'],
                      filteredChatDocs[index]['userId'] ==
                          futureSnapshot.data?.uid,
                      documentId: filteredChatDocs[index].id,
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
