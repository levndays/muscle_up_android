import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Додано для FieldValue та FirebaseFirestore

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin { // TickerProviderStateMixin для кількох контролерів
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  String? _errorMessage;

  // Кольори
  static const Color primaryOrange = Color(0xFFED5D1A);
  static const Color textBlack = Colors.black87;
  static const Color textGrey = Color(0xFF757575);
  static const Color subtleOrangeBase = Color(0xFFFFF0E5); // Базовий світло-оранжевий
  static const Color whiteWithOpacity = Colors.white70; // Білий з прозорістю

  // Для анімації градієнта
  late AnimationController _gradientController1;
  late AnimationController _gradientController2;
  late Animation<Alignment> _alignmentAnimation1;
  late Animation<Alignment> _alignmentAnimation2;

  // Кольори для шарів градієнта
  final List<Color> _gradientColors1 = [
    primaryOrange.withOpacity(0.25), // Зменшена насиченість
    subtleOrangeBase.withOpacity(0.4),
    whiteWithOpacity.withOpacity(0.3),
  ];
  final List<Color> _gradientColors2 = [
    subtleOrangeBase.withOpacity(0.5),
    primaryOrange.withOpacity(0.15), // Ще менша насиченість
    Colors.white.withOpacity(0.35),
  ];


  @override
  void initState() {
    super.initState();
    _gradientController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Різні тривалості
    )..repeat(reverse: true);

    _gradientController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13), // Різні тривалості
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
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(user.uid);

    final docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      print("User profile already exists for ${user.uid}");
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
        'profileSetupComplete': false, // Важливо для перенаправлення на ProfileSetupPage
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("Initial user profile created for ${user.uid}");
    } catch (e) {
      print("Error creating initial user profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка створення профілю: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          await _createInitialUserProfile(userCredential.user!);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Сталася помилка.');
    } catch (e) {
      setState(() => _errorMessage = 'Сталася невідома помилка.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if ((userCredential.additionalUserInfo?.isNewUser ?? false) && userCredential.user != null) {
        await _createInitialUserProfile(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Помилка входу через Google.');
    } catch (e) {
      setState(() => _errorMessage = 'Невідома помилка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _gradientController1.dispose();
    _gradientController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // Використовуємо Stack для накладання градієнтів та контенту
        children: [
          // Шар градієнта 1
          AnimatedBuilder(
            animation: _gradientController1,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors1,
                    begin: _alignmentAnimation1.value,
                    end: -_alignmentAnimation1.value, // Рух в протилежному напрямку
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          // Шар градієнта 2
          AnimatedBuilder(
            animation: _gradientController2,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors2,
                    begin: _alignmentAnimation2.value,
                    end: -_alignmentAnimation2.value, // Рух в протилежному напрямку
                    stops: const [0.0, 0.4, 1.0], // Трохи інші stops
                  ),
                ),
              );
            },
          ),
          // Основний контент сторінки
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0), // Зменшено вертикальний відступ
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Щоб заголовок був вгорі
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // MuscleUP Title - Зменшено та переміщено вгору
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 40.0), // Відступи
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan( // Важливо встановити стиль за замовчуванням тут
                          style: DefaultTextStyle.of(context).style.copyWith(fontFamily: 'Inter'), // Для успадкування шрифта
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Muscle',
                                style: TextStyle(
                                  fontSize: 30, // Зменшений розмір
                                  fontWeight: FontWeight.bold,
                                  color: primaryOrange,
                                )),
                            TextSpan(
                                text: 'UP',
                                style: TextStyle(
                                  fontSize: 30, // Зменшений розмір
                                  fontWeight: FontWeight.bold,
                                  color: textBlack,
                                )),
                          ],
                        ),
                      ),
                    ),

                    // Sign In Title
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

                    // Email Field
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

                    // Password Field
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

                    // Submit Button
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

                    // Google Sign In Button
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
                      onPressed: _isLoading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(height: 24),

                    // Switch to Sign Up/Sign In
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _formKey.currentState?.reset();
                          _emailController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        _isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
                        style: const TextStyle(
                          color: primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                     const SizedBox(height: 20), // Додатковий відступ знизу, якщо потрібно
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}