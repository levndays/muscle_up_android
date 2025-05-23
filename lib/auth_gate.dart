import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Переконайся, що цей файл існує
import 'login_page.dart'; // Переконайся, що цей файл існує

class AuthGate extends StatelessWidget {
  const AuthGate({super.key}); // const конструктор

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Йде перевірка з'єднання
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Користувач увійшов
        if (snapshot.hasData) {
          return const HomePage(); // Використовуємо const, якщо HomePage має const конструктор
        }

        // Користувач не увійшов або сталася помилка (snapshot.hasError)
        // У простому випадку, якщо немає даних, показуємо логін
        return const LoginPage(); // Використовуємо const, якщо LoginPage має const конструктор
      },
    );
  }
}