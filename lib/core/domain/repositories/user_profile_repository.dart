import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile userProfile);
  Stream<UserProfile?> getUserProfileStream(String userId);
  
  // NEW METHODS for Follow/Unfollow
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<UserProfile>> getFollowingList(String userId, {String? lastFetchedUserId, int limit = 20});
  Future<List<UserProfile>> getFollowersList(String userId, {String? lastFetchedUserId, int limit = 20});
}