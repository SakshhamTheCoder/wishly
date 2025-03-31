import 'package:flutter/material.dart';

class DefaultScaffold extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;
  final FloatingActionButton? floatingActionButton;
  const DefaultScaffold({super.key, required this.child, this.appBar, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: appBar == null ? 24 : 12,
          vertical: appBar == null ? 36 : 8,
        ),
        child: child,
      ),
    );
  }
}
