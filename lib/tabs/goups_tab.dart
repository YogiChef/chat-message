import 'package:flutter/material.dart';

class GroupTab extends StatefulWidget {
  const GroupTab({super.key});

  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Groups')));
  }
}
