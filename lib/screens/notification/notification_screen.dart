import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),

      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),

            title: Text('Weather Alert'),

            subtitle: Text('Heavy rain expected tomorrow'),
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.store),

            title: Text('Market Price Update'),

            subtitle: Text('Rice price increased today'),
          ),
        ],
      ),
    );
  }
}
