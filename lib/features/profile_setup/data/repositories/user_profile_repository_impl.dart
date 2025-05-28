// lib/features/profile_setup/data/repositories/user_profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer; // Для логування

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    developer.log("Fetching user profile for userId: $userId", name: "UserProfileRepoImpl");
    if (userId.isEmpty) {
      developer.log("UserId is empty, cannot fetch profile.", name: "UserProfileRepoImpl");
      throw ArgumentError("User ID cannot be empty.");
    }
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        developer.log("User profile found for userId: $userId", name: "UserProfileRepoImpl");
        return UserProfile.fromFirestore(docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      } else {
        developer.log("User profile NOT found for userId: $userId", name: "UserProfileRepoImpl");
        return null; // Повертаємо null, якщо документ не існує
      }
    } catch (e, s) {
      developer.log("Error fetching user profile for userId: $userId", error: e, stackTrace: s, name: "UserProfileRepoImpl");
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile userProfile) async {
    developer.log("Updating user profile for userId: ${userProfile.uid}", name: "UserProfileRepoImpl");
    if (userProfile.uid.isEmpty) {
      developer.log("UserId is empty, cannot update profile.", name: "UserProfileRepoImpl");
      throw ArgumentError("User ID in profile cannot be empty for update.");
    }
    try {
      final dataToUpdate = userProfile.toMap()
        ..['updatedAt'] = FieldValue.serverTimestamp(); // profileSetupComplete вже має бути в userProfile.toMap()

      // uid не є частиною даних документа, а є його ID, тому його не потрібно записувати в поля.
      // createdAt встановлюється один раз при створенні і не має оновлюватися.
      // Ми припускаємо, що toMap() вже правильно обробляє, які поля включати.
      // Якщо ви хочете бути впевненим, що createdAt не перезаписується,
      // ви можете його видалити з dataToUpdate, якщо він там є, але це залежить від реалізації toMap().
      // dataToUpdate.remove('createdAt'); 

      await _firestore.collection('users').doc(userProfile.uid).update(dataToUpdate);
      developer.log("User profile updated successfully for userId: ${userProfile.uid}", name: "UserProfileRepoImpl");
    } catch (e, s) {
      developer.log("Error updating user profile for userId: ${userProfile.uid}", error: e, stackTrace: s, name: "UserProfileRepoImpl");
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Stream<UserProfile?> getUserProfileStream(String userId) {
    developer.log("Setting up user profile stream for userId: $userId", name: "UserProfileRepoImpl");
    if (userId.isEmpty) {
      developer.log("UserId is empty, cannot create profile stream.", name: "UserProfileRepoImpl");
      return Stream.error(ArgumentError("User ID cannot be empty for stream."));
    }
    try {
      return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          developer.log("Profile stream received data for userId: $userId", name: "UserProfileRepoImpl");
          return UserProfile.fromFirestore(snapshot as DocumentSnapshot<Map<String, dynamic>>);
        }
        developer.log("Profile stream received no data (document might not exist) for userId: $userId", name: "UserProfileRepoImpl");
        return null;
      }).handleError((error, stackTrace) { // Обробка помилок у стрімі
        developer.log("Error in user profile stream for userId: $userId", error: error, stackTrace: stackTrace, name: "UserProfileRepoImpl");
        // Можна або передати помилку далі, або повернути null/попереднє значення, якщо є логіка кешування
        throw Exception('Error in profile stream: ${error.toString()}');
      });
    } catch (e, s) {
      developer.log("Error setting up user profile stream for userId: $userId", error: e, stackTrace: s, name: "UserProfileRepoImpl");
      return Stream.error(Exception('Failed to set up user profile stream: ${e.toString()}'));
    }
  }
}