// FILE: lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../widgets/lava_lamp_background.dart';

const Color primaryOrange = Color(0xFFED5D1A);
const Color textBlackColor = Colors.black87; // Використовуємо більш узгоджену назву
const Color textGreyColor = Color(0xFF757575); // Використовуємо більш узгоджену назву

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log("LoginPage initState", name: "LoginPage");
  }

  // !! ВИДАЛІТЬ ЦЕЙ МЕТОД ПОВНІСТЮ (якщо він ще є) !!
  // Future<void> _createInitialUserProfile(User user) async { /* ... */ }

  Future<void> _submitForm() async {
    developer.log("Entering _submitForm. _formKey.currentState is: ${_formKey.currentState}", name: "LoginPage._submitForm");

    if (_formKey.currentState == null) {
      developer.log("CRITICAL: _formKey.currentState is NULL. Form might not be in the widget tree or key is not assigned.", name: "LoginPage._submitForm");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Internal form error. Please try again.')),
        );
      }
      return;
    }

    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      developer.log("Form is NOT valid. Validation errors should be visible.", name: "LoginPage._submitForm");
      return;
    }
    developer.log("Form is VALID. Proceeding with submission. _isLogin: $_isLogin", name: "LoginPage._submitForm");

    if(mounted) setState(() { _isLoading = true; _errorMessage = null; });

    try {
      UserCredential userCredential;
      if (_isLogin) {
        developer.log("Attempting to sign in with email: ${_emailController.text.trim()}", name: "LoginPage._submitForm");
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        developer.log("Sign in successful: ${userCredential.user?.uid}", name: "LoginPage._submitForm");
      } else { // Create Account logic
        developer.log("Attempting to create account with email: ${_emailController.text.trim()}", name: "LoginPage._submitForm");
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        developer.log("Account creation successful with Firebase Auth: ${userCredential.user?.uid}", name: "LoginPage._submitForm");
        // !! ВИДАЛІТЬ ЗВІДСИ ВИКЛИК _createInitialUserProfile !!
        // if (userCredential.user != null) {
        //   await _createInitialUserProfile(userCredential.user!);
        // }
      }
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException: ${e.code} - ${e.message}", name: "LoginPage._submitForm");
      if(mounted) setState(() => _errorMessage = e.message ?? 'Сталася помилка автентифікації.');
    } catch (e, s) {
      developer.log("Generic Exception in _submitForm: $e", name: "LoginPage._submitForm", error: e, stackTrace: s);
      if(mounted) setState(() => _errorMessage = 'Сталася невідома помилка: ${e.toString()}');
    } finally {
      developer.log("_submitForm finally block. Mounted: $mounted. Setting _isLoading to false.", name: "LoginPage._submitForm");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    developer.log("Attempting Google Sign-In...", name: "LoginPage._signInWithGoogle");
    if(mounted) setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        developer.log("Google Sign-In cancelled by user.", name: "LoginPage._signInWithGoogle");
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      developer.log("Google User obtained: ${googleUser.email}", name: "LoginPage._signInWithGoogle");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      developer.log("Firebase Sign-In with Google successful: ${userCredential.user?.uid}", name: "LoginPage._signInWithGoogle");

      // !! ВИДАЛІТЬ ЗВІДСИ ВИКЛИК _createInitialUserProfile !!
      // if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
      //   developer.log("New user detected via Google Sign-In. Creating profile...", name: "LoginPage._signInWithGoogle");
      //   await _createInitialUserProfile(userCredential.user!);
      // }
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}", name: "LoginPage._signInWithGoogle");
       if(mounted) setState(() => _errorMessage = e.message ?? 'Помилка входу через Google.');
    } catch (e, s) {
      developer.log("Generic Exception during Google Sign-In: $e", name: "LoginPage._signInWithGoogle", error: e, stackTrace: s);
      if(mounted) setState(() => _errorMessage = 'Невідома помилка під час входу через Google: ${e.toString()}');
    } finally {
      developer.log("Google Sign-In finally block. Mounted: $mounted. Setting _isLoading to false.", name: "LoginPage._signInWithGoogle");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    developer.log("LoginPage dispose", name: "LoginPage");
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log("LoginPage build method. _isLogin: $_isLogin, _isLoading: $_isLoading", name: "LoginPage");
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: LavaLampBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0), // Збільшено вертикальний padding
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Центрування контенту
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0), // Збільшено відступ знизу
                        child: DefaultTextStyle(
                          style: const TextStyle(decoration: TextDecoration.none),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 36, // Збільшено розмір шрифту логотипа
                                fontWeight: FontWeight.w900, // <--- ЗМІНЕНО НА Black
                                decoration: TextDecoration.none,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Muscle',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontWeight: FontWeight.w900, // <--- ЗМІНЕНО НА Black
                                  ),
                                ),
                                TextSpan(
                                  text: 'UP',
                                  style: TextStyle(
                                    color: textBlackColor,
                                    fontWeight: FontWeight.w900, // <--- ЗМІНЕНО НА Black
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold, // Залишаємо Bold, щоб відрізнялося від лого
                          color: textBlackColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 25),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined, color: textGreyColor),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                           border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: primaryOrange, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: textBlackColor, decoration: TextDecoration.none),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your email';
                          if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: textGreyColor),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.85),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: primaryOrange, width: 1.5),
                          ),
                           contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                        ),
                        obscureText: true,
                        style: const TextStyle(color: textBlackColor, decoration: TextDecoration.none),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (!_isLogin && value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: primaryOrange))
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 3,
                          ),
                          onPressed: _submitForm,
                          child: Text(
                            _isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Image.asset('assets/images/google_logo.png', height: 22.0),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(color: textBlackColor, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: textBlackColor,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          elevation: 1,
                        ),
                        onPressed: _signInWithGoogle,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          if (_isLoading) {
                            developer.log("Switch auth mode button pressed while loading, ignoring.", name: "LoginPage");
                            return;
                          }
                          developer.log("Switching auth mode. Current _isLogin: $_isLogin", name: "LoginPage");
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                            _formKey.currentState?.reset();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                           developer.log("Auth mode switched. New _isLogin: $_isLogin", name: "LoginPage");
                        },
                        child: Text(
                          _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
                          style: const TextStyle(
                            color: primaryOrange,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}