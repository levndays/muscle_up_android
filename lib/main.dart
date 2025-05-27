// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'core/domain/repositories/predefined_exercise_repository.dart';
import 'features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart';
import 'core/domain/repositories/routine_repository.dart';
import 'features/routines/data/repositories/routine_repository_impl.dart'; // Переконайтесь, що це правильний шлях

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PredefinedExerciseRepository>(
          create: (context) => PredefinedExerciseRepositoryImpl(),
        ),
        RepositoryProvider<RoutineRepository>(
          // FirebaseAuth.instance буде використано всередині RoutineRepositoryImpl
          create: (context) => RoutineRepositoryImpl(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Muscle UP',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.amber, // Для зворотної сумісності, якщо десь використовується
          ).copyWith(
            secondary: Colors.amber, // Основний акцентний колір
            primary: const Color(0xFFED5D1A), // Основний колір бренду
            onPrimary: Colors.white, // Колір тексту/іконок на primary
            surface: Colors.white, // Колір фону карток, діалогів
            onSurface: Colors.black87, // Колір тексту на surface
            error: Colors.redAccent,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xF2FFFFFF), 
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder( 
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Color(0xFFED5D1A), width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: const Color(0xFFED5D1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFED5D1A),
               textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
            )
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0.5,
            backgroundColor: Colors.grey[50], 
            titleTextStyle: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            iconTheme: const IconThemeData(color: Color(0xFFED5D1A)), 
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFFED5D1A),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
          // Виправлення тут:
          cardTheme: CardThemeData( 
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFED5D1A),
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}