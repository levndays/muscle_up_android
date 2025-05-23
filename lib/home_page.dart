import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // const конструктор

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Головна сторінка'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Вийти',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // AuthGate автоматично обробить перенаправлення на LoginPage
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Помилка виходу: ${e.toString()}')),
                 );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Вітаємо!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              if (user != null) ...[
                if (user.displayName != null && user.displayName!.isNotEmpty)
                  Text('Ім\'я: ${user.displayName}', style: const TextStyle(fontSize: 18)),
                Text('Email: ${user.email}',  style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Text('User ID: ${user.uid}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ] else
                const Text('Інформація про користувача недоступна.'),
            ],
          ),
        ),
      ),
    );
  }
}