import 'package:flutter/material.dart';
import 'package:chat_app/screens/ProfileScreen.dart';
import 'package:chat_app/widgets/methods/editchat.dart';
import 'package:provider/provider.dart';
import '../../screens/FullscreenImage.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble(
    this.filterchatdocs,
    this.index,
    this.message,
    this.username,
    this.userImage,
    this.isMe, {
    required this.documentId,
  });
  final String message;
  final bool isMe;
  final String username;
  final String userImage;
  final String documentId;

  final filterchatdocs;
  final index;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.message);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _openProfileScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ProfileScreen(widget.username, widget.userImage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onLongPress: () => editMessages(_textEditingController,
                      widget.message, widget.documentId, widget.isMe)
                  .editChat(context),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? Colors.grey[300]
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: !widget.isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                    bottomRight: widget.isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                ),
                width: 140,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: TextStyle(
                        color: widget.isMe
                            ? Colors.black
                            : Theme.of(context).textTheme.displayLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.message,
                      style: TextStyle(
                        // fontStyle: FontStyle.normal,
                        color: widget.isMe
                            ? Colors.black
                            : Theme.of(context).textTheme.displayLarge?.color,
                      ),
                      textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
                    ),
                    if (widget.filterchatdocs[widget.index]['imageUrl'] != '')
                      SizedBox(
                        height: 100,
                        width: 400,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              FullScreenImageRoute(
                                  imageUrl: widget.filterchatdocs[widget.index]
                                      ['imageUrl'],
                                  timestamp: widget.filterchatdocs[widget.index]
                                      ['createdAt'],
                                  userName: widget.username),
                            );
                          },
                          child: Image.network(
                            widget.filterchatdocs[widget.index]['imageUrl'],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 18,
          right: widget.isMe ? -1 : null,
          child: GestureDetector(
            onTap: () {
              final userName = widget.filterchatdocs[widget.index]['username'];
              final text = widget.filterchatdocs[widget.index]['text'];
              final imageUrl = widget.filterchatdocs[widget.index]['imageUrl'];
              // widget.reply = true;
            },
            child: Icon(
              Icons.reply,
              color: widget.isMe ? Colors.grey : Colors.black,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: !widget.isMe ? 120 : null,
          right: widget.isMe ? 120 : null,
          child: GestureDetector(
            onTap: () => widget.isMe ? _openProfileScreen(context) : null,
            onLongPress: () => editMessages(_textEditingController,
                    widget.message, widget.documentId, widget.isMe)
                .editChat(context),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.userImage),
            ),
          ),
        ),
      ],
    );
  }
}
