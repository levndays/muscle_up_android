// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'core/domain/repositories/predefined_exercise_repository.dart';
import 'features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart';
import 'core/domain/repositories/routine_repository.dart';
import 'features/routines/data/repositories/routine_repository_impl.dart';

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
    const Color primaryOrange = Color(0xFFED5D1A);
    const Color textBlackColor = Colors.black87;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PredefinedExerciseRepository>(
          create: (context) => PredefinedExerciseRepositoryImpl(),
        ),
        RepositoryProvider<RoutineRepository>(
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
            accentColor: Colors.amber,
          ).copyWith(
            primary: primaryOrange,
            onPrimary: Colors.white,
            secondary: Colors.amber,
            surface: Colors.white,
            onSurface: textBlackColor,
            error: Colors.redAccent,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          iconTheme: const IconThemeData(color: primaryOrange),
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
              borderSide: BorderSide(color: primaryOrange, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryOrange,
              textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
            )
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0.5,
            backgroundColor: Colors.white,
            // Загальний стиль для тексту AppBar. Якщо потрібна інша жирність для "MuscleUP",
            // це краще встановити безпосередньо в RichText.
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22, // Збільшено для назви додатку
              fontWeight: FontWeight.w900, // BLACK жирність для "MuscleUP"
              color: textBlackColor
            ),
            iconTheme: IconThemeData(color: primaryOrange), // Для іконок в AppBar, якщо вони будуть
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: textBlackColor,
            unselectedItemColor: primaryOrange,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            elevation: 8.0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            elevation: 6.0, // Збільшена тінь для FAB
            // shape: StadiumBorder(), // Можна глобально, якщо всі FAB будуть такими
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}