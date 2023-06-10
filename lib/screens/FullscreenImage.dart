import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String userName;
  final Timestamp timestamp;

  const FullScreenImage({
    required this.imageUrl,
    required this.timestamp,
    required this.userName,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool _showAppBar = false;
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    String formattedDateTime =
        "${widget.userName ?? 'Unknown User'} on ${_formatDateTime(widget.timestamp)}";

    bool isNightTime = _isNightTime();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          color: _showAppBar ? Colors.black : Colors.grey,
          child: AppBar(
            backgroundColor: Colors.transparent,
            // automaticallyImplyLeading: !_showAppBar,
            title: Text(
              formattedDateTime,
              style: TextStyle(
                fontSize: 18,
                color: _showAppBar ? Colors.black : Colors.white,
              ),
            ),
            iconTheme:
                IconThemeData(color: !_showAppBar ? Colors.blue : Colors.black),
          ),
        ),
      ),
      body: GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = details.scale.clamp(1.0, 3.0);
          });
        },
        onTap: () {
          setState(() {
            _showAppBar = !_showAppBar;
          });
        },
        child: Container(
          color: isNightTime ? Colors.black : Colors.white,
          child: Center(
            child: Hero(
              tag: widget.imageUrl,
              child: Transform.scale(
                scale: _scale,
                child: Image.network(widget.imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isNightTime() {
    DateTime now = DateTime.now();
    int currentHour = now.hour;
    return currentHour >= 19 || currentHour < 6;
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    String formattedTime = DateFormat.jm().format(dateTime);
    return "$formattedDate at $formattedTime";
  }
}

class FullScreenImageRoute extends PageRouteBuilder {
  final String imageUrl;
  final Timestamp timestamp;
  final String userName;

  FullScreenImageRoute({
    required this.imageUrl,
    required this.timestamp,
    required this.userName,
  }) : super(
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FullScreenImage(
            imageUrl: imageUrl,
            timestamp: timestamp,
            userName: userName,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                ),
              ),
              child: child,
            );
          },
        );
}
