import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marunthon_app/features/settings/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final user = settingsProvider.user;

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child:
                    user.photoURL == null ? Icon(Icons.person, size: 40) : null,
              ),
              SizedBox(height: 16),
              Text(
                user.displayName ?? "Guest",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                user.email ?? "No email",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await settingsProvider.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
