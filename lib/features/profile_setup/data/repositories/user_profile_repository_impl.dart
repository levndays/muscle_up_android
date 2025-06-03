// lib/features/profile_setup/data/repositories/user_profile_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer;

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
        return null;
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
      final Map<String, dynamic> dataToUpdate = userProfile.toMap();
      // Важливо: `toMap()` тепер включає `following` але не `followersCount` чи `followingCount`
      // Ці лічильники будуть оновлюватися тільки Cloud Functions
      // `updatedAt` має бути встановлено
      dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

      // Видаляємо поля, які не повинні оновлюватися клієнтом напряму,
      // якщо toMap їх включає, окрім `following`
      dataToUpdate.remove('followersCount'); 
      dataToUpdate.remove('followingCount'); 
      dataToUpdate.remove('createdAt'); // createdAt не має оновлюватися
      dataToUpdate.remove('uid'); // uid - це ID документа
      dataToUpdate.remove('email'); // email зазвичай не змінюється
      dataToUpdate.remove('xp');
      dataToUpdate.remove('level');
      dataToUpdate.remove('currentStreak');
      dataToUpdate.remove('longestStreak');
      dataToUpdate.remove('lastWorkoutTimestamp');
      dataToUpdate.remove('lastScheduledWorkoutCompletionTimestamp');
      dataToUpdate.remove('lastScheduledWorkoutDayKey');
      dataToUpdate.remove('achievedRewardIds');
      
      await _firestore.collection('users').doc(userProfile.uid).update(dataToUpdate);
      developer.log("User profile updated successfully for userId: ${userProfile.uid}. Data: $dataToUpdate", name: "UserProfileRepoImpl");
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
      }).handleError((error, stackTrace) {
        developer.log("Error in user profile stream for userId: $userId", error: error, stackTrace: stackTrace, name: "UserProfileRepoImpl");
        throw Exception('Error in profile stream: ${error.toString()}');
      });
    } catch (e, s) {
      developer.log("Error setting up user profile stream for userId: $userId", error: e, stackTrace: s, name: "UserProfileRepoImpl");
      return Stream.error(Exception('Failed to set up user profile stream: ${e.toString()}'));
    }
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      throw ArgumentError("User IDs cannot be empty.");
    }
    if (currentUserId == targetUserId) {
      throw ArgumentError("Cannot follow yourself.");
    }
    developer.log("User $currentUserId attempting to follow $targetUserId", name: "UserProfileRepoImpl.followUser");
    try {
      final currentUserDocRef = _firestore.collection('users').doc(currentUserId);
      // Функція Cloud оновить лічильники та список followers у targetUserId
      await currentUserDocRef.update({
        'following': FieldValue.arrayUnion([targetUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      developer.log("User $currentUserId successfully added $targetUserId to their following list. Cloud Function will handle reciprocal.", name: "UserProfileRepoImpl.followUser");
    } catch (e, s) {
      developer.log("Error following user $targetUserId by $currentUserId: $e", error: e, stackTrace: s, name: "UserProfileRepoImpl.followUser");
      throw Exception('Failed to follow user: ${e.toString()}');
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      throw ArgumentError("User IDs cannot be empty.");
    }
    developer.log("User $currentUserId attempting to unfollow $targetUserId", name: "UserProfileRepoImpl.unfollowUser");
    try {
      final currentUserDocRef = _firestore.collection('users').doc(currentUserId);
      // Функція Cloud оновить лічильники та список followers у targetUserId
      await currentUserDocRef.update({
        'following': FieldValue.arrayRemove([targetUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
       developer.log("User $currentUserId successfully removed $targetUserId from their following list. Cloud Function will handle reciprocal.", name: "UserProfileRepoImpl.unfollowUser");
    } catch (e, s) {
      developer.log("Error unfollowing user $targetUserId by $currentUserId: $e", error: e, stackTrace: s, name: "UserProfileRepoImpl.unfollowUser");
      throw Exception('Failed to unfollow user: ${e.toString()}');
    }
  }

  @override
  Future<List<UserProfile>> getFollowingList(String userId, {String? lastFetchedUserId, int limit = 20}) async {
    if (userId.isEmpty) throw ArgumentError("User ID cannot be empty.");
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];
      
      final List<String> followingIds = List<String>.from(userDoc.data()?['following'] ?? []);
      if (followingIds.isEmpty) return [];

      // Firestore 'in' query supports up to 30 elements per query.
      // We need to paginate this manually if `followingIds` is large.
      // For simplicity, this example will fetch all or up to `limit` if it's small enough.
      // A more robust solution would use multiple queries or a different data structure if lists are very large.
      
      final List<UserProfile> profiles = [];
      for (int i = 0; i < followingIds.length; i += 10) { // Fetch in chunks of 10 (max 30 for 'in')
          final chunk = followingIds.sublist(i, i + 10 > followingIds.length ? followingIds.length : i + 10);
          if (chunk.isEmpty) break;

          final querySnapshot = await _firestore.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
          profiles.addAll(querySnapshot.docs.map((doc) => UserProfile.fromFirestore(doc as DocumentSnapshot<Map<String,dynamic>>)));
          if (profiles.length >= limit) break;
      }
      return profiles.take(limit).toList();

    } catch (e,s) {
      developer.log("Error fetching following list for $userId: $e", error: e, stackTrace: s, name: "UserProfileRepoImpl.getFollowingList");
      throw Exception('Failed to fetch following list: ${e.toString()}');
    }
  }
  
  @override
  Future<List<UserProfile>> getFollowersList(String userId, {String? lastFetchedUserId, int limit = 20}) async {
    if (userId.isEmpty) throw ArgumentError("User ID cannot be empty.");
    try {
      // Followers are not stored as a list on the user's document directly for easy querying (for this method).
      // Instead, we query for users who have `userId` in their `following` list.
      // This is less efficient for getting a follower list but ensures consistency.
      // An alternative (more complex) would be to maintain a `followers` subcollection or list.
      Query query = _firestore.collection('users')
          .where('following', arrayContains: userId)
          .orderBy('username') // Or another field for consistent pagination
          .limit(limit);

      if (lastFetchedUserId != null) {
        final lastDoc = await _firestore.collection('users').doc(lastFetchedUserId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc as DocumentSnapshot<Map<String,dynamic>>)).toList();

    } catch (e,s) {
      developer.log("Error fetching followers list for $userId: $e", error: e, stackTrace: s, name: "UserProfileRepoImpl.getFollowersList");
      throw Exception('Failed to fetch followers list: ${e.toString()}');
    }
  }
}