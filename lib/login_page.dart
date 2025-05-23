import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // const конструктор

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true; // true для входу, false для реєстрації
  String? _errorMessage;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save(); // Важливо для onSaved, якщо використовується

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Скидаємо попередню помилку
    });

    try {
      if (_isLogin) {
        // Логін
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Реєстрація
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Можна додати автоматичний логін після реєстрації або перенаправлення
        // Наразі AuthGate обробить зміну стану
      }
      // Успішний вхід/реєстрація перенаправить через AuthGate
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Сталася помилка автентифікації.';
      });
    } catch (e) {
      // Для інших непередбачених помилок
      setState(() {
        _errorMessage = 'Сталася невідома помилка. Спробуйте ще раз.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Вхід' : 'Реєстрація'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Дозволяє скролити, якщо контент не вміщується
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Розтягує кнопки
              children: <Widget>[
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Будь ласка, введіть ваш email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Будь ласка, введіть дійсний email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Будь ласка, введіть ваш пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль має містити щонайменше 6 символів';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    onPressed: _submitForm,
                    child: Text(_isLogin ? 'Увійти' : 'Зареєструватися', style: const TextStyle(fontSize: 16)),
                  ),
                TextButton(
                  onPressed: _isLoading ? null : () { // Блокуємо кнопку під час завантаження
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null; // Скидаємо помилку при зміні режиму
                      _formKey.currentState?.reset(); // Опціонально: очистити поля
                      _emailController.clear();
                      _passwordController.clear();
                    });
                  },
                  child: Text(_isLogin
                      ? 'Немає акаунту? Зареєструватися'
                      : 'Вже є акаунт? Увійти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}