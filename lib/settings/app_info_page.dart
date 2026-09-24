import 'package:flutter/material.dart';

class AppInformationPage extends StatelessWidget {
  const AppInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Date of manufacture'),
            trailing: Text(
              'Dec 2019',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Divider(height: 0),
          ListTile(
            title: Text('Version'),
            trailing: Text(
              '9.0.2',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Divider(height: 0),
          ListTile(
            title: Text('Language'),
            trailing: Text(
              'English',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Divider(height: 0),
        ],
      ),
    );
  }
}
