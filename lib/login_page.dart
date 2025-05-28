// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

const Color primaryOrange = Color(0xFFED5D1A);
const Color textBlack = Colors.black87;
const Color textGrey = Color(0xFF757575);
const Color subtleOrangeBase = Color(0xFFFFF0E5);
const Color whiteWithOpacity = Colors.white70;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMessage;

  late AnimationController _gradientController1;
  late AnimationController _gradientController2;
  late Animation<Alignment> _alignmentAnimation1;
  late Animation<Alignment> _alignmentAnimation2;

  final List<Color> _gradientColors1 = [
    primaryOrange.withOpacity(0.25),
    subtleOrangeBase.withOpacity(0.4),
    whiteWithOpacity.withOpacity(0.3),
  ];
  final List<Color> _gradientColors2 = [
    subtleOrangeBase.withOpacity(0.5),
    primaryOrange.withOpacity(0.15),
    Colors.white.withOpacity(0.35),
  ];

  @override
  void initState() {
    super.initState();
    developer.log("LoginPage initState", name: "LoginPage");
    _gradientController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _gradientController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat(reverse: true);

    _alignmentAnimation1 = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.centerLeft), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.centerLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.topLeft), weight: 1),
    ]).animate(CurvedAnimation(parent: _gradientController1, curve: Curves.easeInOut));

    _alignmentAnimation2 = TweenSequence<Alignment>([
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.centerRight), weight: 1),
      TweenSequenceItem(tween: AlignmentTween(begin: Alignment.centerRight, end: Alignment.bottomLeft), weight: 1),
    ]).animate(CurvedAnimation(parent: _gradientController2, curve: Curves.easeInOut));
  }

  Future<void> _createInitialUserProfile(User user) async {
    developer.log("Attempting to create initial user profile for ${user.uid}", name: "LoginPage._createInitialUserProfile");
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      developer.log("User profile already exists for ${user.uid}", name: "LoginPage._createInitialUserProfile");
      return;
    }
    try {
      await userDocRef.set({
        'uid': user.uid,
        'email': user.email?.toLowerCase(),
        'displayName': user.displayName,
        'profilePictureUrl': user.photoURL,
        'username': null,
        'xp': 0,
        'level': 1,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastWorkoutTimestamp': null,
        'scheduledWorkoutDays': [],
        'preferredUnits': 'kg',
        'currentLeagueId': null,
        'city': null,
        'country': null,
        'isProfilePublic': true,
        'fcmTokens': [],
        'appSettings': {},
        'initialFitnessLevel': null,
        'profileSetupComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log("Initial user profile CREATED for ${user.uid}", name: "LoginPage._createInitialUserProfile");
    } catch (e) {
      developer.log("Error creating initial user profile: $e", name: "LoginPage._createInitialUserProfile");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка створення профілю: ${e.toString()}')),
        );
      }
    }
    developer.log("Finished _createInitialUserProfile for ${user.uid}", name: "LoginPage._createInitialUserProfile");
  }

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
        if (userCredential.user != null) {
          await _createInitialUserProfile(userCredential.user!);
        } else {
           developer.log("User is null after createUserWithEmailAndPassword, cannot create profile.", name: "LoginPage._submitForm");
        }
      }
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException: ${e.code} - ${e.message}", name: "LoginPage._submitForm");
      if(mounted) setState(() => _errorMessage = e.message ?? 'Сталася помилка автентифікації.');
    } catch (e, s) { // Додано stackTrace
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
      
      if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
        developer.log("New user detected via Google Sign-In. Creating profile...", name: "LoginPage._signInWithGoogle");
        await _createInitialUserProfile(userCredential.user!);
      } else if (userCredential.user != null) {
        developer.log("Existing user via Google Sign-In or profile already handled.", name: "LoginPage._signInWithGoogle");
      } else {
        developer.log("User is null after Google Sign-In, cannot create profile.", name: "LoginPage._signInWithGoogle");
      }
    } on FirebaseAuthException catch (e) {
      developer.log("FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}", name: "LoginPage._signInWithGoogle");
       if(mounted) setState(() => _errorMessage = e.message ?? 'Помилка входу через Google.');
    } catch (e, s) { // Додано stackTrace
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
    _gradientController1.dispose();
    _gradientController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log("LoginPage build method. _isLogin: $_isLogin, _isLoading: $_isLoading", name: "LoginPage");
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientController1,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors1,
                    begin: _alignmentAnimation1.value,
                    end: -_alignmentAnimation1.value,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _gradientController2,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors2,
                    begin: _alignmentAnimation2.value,
                    end: -_alignmentAnimation2.value,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
                child: Form( // Дуже важливо: Form обгортає поля та має ключ
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 40.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(fontFamily: 'Inter'),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: 'Muscle',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                  )),
                              TextSpan(
                                  text: 'UP',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: textBlack,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textBlack,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined, color: textGrey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
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
                        style: const TextStyle(color: textBlack),
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
                          prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
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
                        style: const TextStyle(color: textBlack),
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
                          onPressed: _submitForm, // Виклик _submitForm
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
                          style: TextStyle(color: textBlack, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: textBlack,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          elevation: 1,
                        ),
                        onPressed: _signInWithGoogle, // Виклик _signInWithGoogle
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