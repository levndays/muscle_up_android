// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'firebase_options.dart';
import 'auth_gate.dart';

// Репозиторії
import 'core/domain/repositories/predefined_exercise_repository.dart';
import 'features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart';
import 'core/domain/repositories/routine_repository.dart';
import 'features/routines/data/repositories/routine_repository_impl.dart';
import 'core/domain/repositories/user_profile_repository.dart';
import 'features/profile_setup/data/repositories/user_profile_repository_impl.dart';
import 'core/domain/repositories/notification_repository.dart'; // <--- ДОДАНО
import 'features/notifications/data/repositories/notification_repository_impl.dart'; // <--- ДОДАНО

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
        RepositoryProvider<UserProfileRepository>(
          create: (context) => UserProfileRepositoryImpl(),
        ),
        RepositoryProvider<fb_auth.FirebaseAuth>(
          create: (context) => fb_auth.FirebaseAuth.instance,
        ),
        RepositoryProvider<NotificationRepository>( // <--- ДОДАНО
          create: (context) => NotificationRepositoryImpl(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Muscle UP',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.amberAccent,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryOrange,
            onPrimary: Colors.white,
            secondary: Colors.amberAccent,
            surface: Colors.white,
            onSurface: textBlackColor,
            background: const Color(0xFFF5F5F5),
            onBackground: textBlackColor,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: textBlackColor),
            displayMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: textBlackColor),
            displaySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900, color: textBlackColor),
            headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: textBlackColor),
            headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: textBlackColor),
            headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: textBlackColor),
            titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: textBlackColor),
            titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: textBlackColor),
            titleSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, color: textBlackColor),
            bodyLarge: TextStyle(fontFamily: 'Inter', color: textBlackColor),
            bodyMedium: TextStyle(fontFamily: 'Inter', color: Colors.black54),
            bodySmall: TextStyle(fontFamily: 'Inter', color: Colors.grey),
            labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white),
            labelMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
          ).apply(
             bodyColor: textBlackColor,
             displayColor: textBlackColor,
          ),

          iconTheme: const IconThemeData(color: primaryOrange),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Inter'),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: primaryOrange, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.redAccent.shade200, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: Colors.redAccent.shade400, width: 2.0),
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
              elevation: 3,
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
            elevation: 0.8,
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textBlackColor,
            ),
            iconTheme: IconThemeData(color: primaryOrange),
            actionsIconTheme: IconThemeData(color: primaryOrange),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: textBlackColor,
            unselectedItemColor: primaryOrange.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            elevation: 8.0,
          ),
          cardTheme: CardThemeData(
            elevation: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            elevation: 6.0,
          ),
          listTileTheme: ListTileThemeData(
            iconColor: primaryOrange,
            titleTextStyle: const TextStyle(fontFamily: 'Inter', color: textBlackColor, fontSize: 16, fontWeight: FontWeight.w500),
            subtitleTextStyle: TextStyle(fontFamily: 'Inter', color: Colors.grey[600], fontSize: 14),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            titleTextStyle: const TextStyle(fontFamily: 'Inter', color: textBlackColor, fontSize: 20, fontWeight: FontWeight.w600),
            contentTextStyle: const TextStyle(fontFamily: 'Inter', color: textBlackColor, fontSize: 16),
          ),
           chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[200],
            selectedColor: primaryOrange.withOpacity(0.25),
            labelStyle: const TextStyle(fontFamily: 'Inter', color: textBlackColor, fontWeight: FontWeight.w500),
            secondaryLabelStyle: const TextStyle(fontFamily: 'Inter', color: primaryOrange, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            checkmarkColor: primaryOrange,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}