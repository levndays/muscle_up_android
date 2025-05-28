import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile userProfile);
  Stream<UserProfile?> getUserProfileStream(String userId); // <--- НОВИЙ МЕТОД
}
