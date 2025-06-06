// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/domain/repositories/user_profile_repository.dart';
import 'core/domain/entities/user_profile.dart';
import 'features/profile/presentation/cubit/user_profile_cubit.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart'; // Import AppLocalizations

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log("AuthGate: Building with authStateChanges stream", name: "AuthGate");
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        developer.log("AuthGate: StreamBuilder received authSnapshot - connectionState: ${authSnapshot.connectionState}, hasData: ${authSnapshot.hasData}, hasError: ${authSnapshot.hasError}", name: "AuthGate");
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          developer.log("AuthGate: Auth state waiting", name: "AuthGate");
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          developer.log("AuthGate: User is authenticated (UID: ${authSnapshot.data!.uid}). Checking profile.", name: "AuthGate");
          return _ProfileCheckGate( // Передаємо тільки userId
            userId: authSnapshot.data!.uid,
          );
        }
        developer.log("AuthGate: User is not authenticated. Navigating to LoginPage.", name: "AuthGate");
        return const LoginPage();
      },
    );
  }
}

class _ProfileCheckGate extends StatelessWidget {
  final String userId;

  const _ProfileCheckGate({
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final userProfileRepository = RepositoryProvider.of<UserProfileRepository>(context);
    final firebaseAuthFromProvider = RepositoryProvider.of<fb_auth.FirebaseAuth>(context); // Для UserProfileCubit
    final loc = AppLocalizations.of(context); // For localization

    developer.log("_ProfileCheckGate: Building StreamBuilder for userId: $userId", name: "AuthGate._ProfileCheckGate");

    return StreamBuilder<UserProfile?>(
      stream: userProfileRepository.getUserProfileStream(userId),
      builder: (context, profileSnapshot) {
        developer.log(
            "_ProfileCheckGate: StreamBuilder received profileSnapshot - connectionState: ${profileSnapshot.connectionState}, hasData: ${profileSnapshot.hasData}, hasError: ${profileSnapshot.hasError}, data: ${profileSnapshot.data?.profileSetupComplete}",
            name: "AuthGate._ProfileCheckGate"
        );

        // 1. Обробка помилки потоку
        if (profileSnapshot.hasError) {
          developer.log(
            "_ProfileCheckGate: Error in profile stream for $userId: ${profileSnapshot.error}",
            name: "AuthGate._ProfileCheckGate", error: profileSnapshot.error, stackTrace: profileSnapshot.stackTrace
          );
          // Можна спробувати вийти, щоб уникнути зациклення
          // fb_auth.FirebaseAuth.instance.signOut();
          return const LoginPage(); // Або екран помилки
        }

        // 2. Обробка стану очікування початкових даних
        if (profileSnapshot.connectionState == ConnectionState.waiting && !profileSnapshot.hasData) {
          developer.log("_ProfileCheckGate: Profile stream waiting for initial data for userId: $userId", name: "AuthGate._ProfileCheckGate");
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userProfile = profileSnapshot.data;

        // 3. Якщо профіль ще не створений (null з потоку)
        if (userProfile == null) {
          developer.log(
            "_ProfileCheckGate: Profile is STILL NULL for user $userId from stream. Waiting for Firestore creation/sync.",
            name: "AuthGate._ProfileCheckGate"
          );
          // Показуємо індикатор, поки Firestore не синхронізує створений профіль
          return Scaffold(body: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(loc.authGateFinalizingAccountSetup), // LOCALIZED
            ],
          )));
        }

        // 4. Профіль завантажений, перевіряємо profileSetupComplete
        developer.log("_ProfileCheckGate: Profile loaded via stream for $userId. profileSetupComplete: ${userProfile.profileSetupComplete}", name: "AuthGate._ProfileCheckGate");

        if (userProfile.profileSetupComplete) {
          developer.log("_ProfileCheckGate: Profile setup is complete. Navigating to HomePage.", name: "AuthGate._ProfileCheckGate");
          return BlocProvider<UserProfileCubit>(
            create: (cubitContext) => UserProfileCubit(
              userProfileRepository,
              firebaseAuthFromProvider,
            ),
            child: const HomePage(),
          );
        } else {
          developer.log("_ProfileCheckGate: Profile setup is NOT complete. Navigating to ProfileSetupScreen.", name: "AuthGate._ProfileCheckGate");
          return const ProfileSetupScreen();
        }
      },
    );
  }
}