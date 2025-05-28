// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/domain/repositories/user_profile_repository.dart';
import 'core/domain/entities/user_profile.dart';
import 'features/profile/presentation/cubit/user_profile_cubit.dart'; // Cubit для профілю
import 'home_page.dart';
import 'login_page.dart';
import 'features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'dart:developer' as developer;

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
          // Користувач увійшов, передаємо FirebaseAuth instance, який вже є в RepositoryProvider з main.dart
          return _ProfileCheckGate(
            userId: authSnapshot.data!.uid,
            // firebaseAuth: RepositoryProvider.of<fb_auth.FirebaseAuth>(context), // Не потрібно, якщо кубіт отримує його напряму
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
  // final fb_auth.FirebaseAuth firebaseAuth; // Не потрібно, якщо кубіт отримує його напряму

  const _ProfileCheckGate({
    super.key, // Додано super.key
    required this.userId,
    // required this.firebaseAuth,
  });

  @override
  Widget build(BuildContext context) {
    final userProfileRepository = RepositoryProvider.of<UserProfileRepository>(context);
    final firebaseAuthFromProvider = RepositoryProvider.of<fb_auth.FirebaseAuth>(context); // Отримуємо з main.dart

    developer.log("_ProfileCheckGate: Building FutureBuilder for userId: $userId", name: "AuthGate._ProfileCheckGate");

    return FutureBuilder<UserProfile?>(
      future: userProfileRepository.getUserProfile(userId),
      builder: (context, profileSnapshot) {
        developer.log("_ProfileCheckGate: FutureBuilder received profileSnapshot - connectionState: ${profileSnapshot.connectionState}, hasData: ${profileSnapshot.hasData}, hasError: ${profileSnapshot.hasError}", name: "AuthGate._ProfileCheckGate");

        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          developer.log("_ProfileCheckGate: Profile fetch waiting for userId: $userId", name: "AuthGate._ProfileCheckGate");
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (profileSnapshot.hasError) {
          developer.log(
            "_ProfileCheckGate: Error fetching profile for $userId: ${profileSnapshot.error}",
            name: "AuthGate._ProfileCheckGate",
            error: profileSnapshot.error,
            stackTrace: profileSnapshot.stackTrace
          );
          return const LoginPage(); // Або спеціальна сторінка помилки
        }

        final userProfile = profileSnapshot.data;

        if (userProfile == null) {
            developer.log(
              "_ProfileCheckGate: Profile NOT FOUND for user $userId after login/auth change. This might be a sync issue or profile creation failed. Redirecting to login.",
              name: "AuthGate._ProfileCheckGate"
            );
            // Можна спробувати вийти, щоб уникнути циклів, якщо щось пішло не так з створенням профілю
            // fb_auth.FirebaseAuth.instance.signOut();
            return const LoginPage();
        }
        
        developer.log("_ProfileCheckGate: Profile loaded for $userId. profileSetupComplete: ${userProfile.profileSetupComplete}", name: "AuthGate._ProfileCheckGate");

        if (userProfile.profileSetupComplete) {
          developer.log("_ProfileCheckGate: Profile setup is complete. Navigating to HomePage with UserProfileCubit.", name: "AuthGate._ProfileCheckGate");
          return BlocProvider<UserProfileCubit>(
            create: (cubitContext) => UserProfileCubit(
              userProfileRepository, // Вже отримано вище
              firebaseAuthFromProvider, // Передаємо з RepositoryProvider
            ), // fetchUserProfile буде викликано в конструкторі UserProfileCubit
            child: const HomePage(),
          );
        } else {
          developer.log("_ProfileCheckGate: Profile setup is NOT complete. Navigating to ProfileSetupScreen.", name: "AuthGate._ProfileCheckGate");
          // ProfileSetupScreen сам створить свій ProfileSetupCubit,
          // якому потрібен UserProfileRepository та FirebaseAuth, які вже є в RepositoryProvider.
          return const ProfileSetupScreen();
        }
      },
    );
  }
}