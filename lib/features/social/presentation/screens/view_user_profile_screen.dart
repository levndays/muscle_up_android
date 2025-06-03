// lib/features/social/presentation/screens/view_user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/user_interaction_cubit.dart';
import 'dart:developer' as developer;
// NEW IMPORTS
import 'follow_list_screen.dart';
import '../cubit/follow_list_cubit.dart' show FollowListType;


const Color profilePrimaryOrange = Color(0xFFED5D1A);
const Color profileTextBlack = Colors.black87;
// (інші константи кольорів, якщо потрібні, як у ProfileScreen)
const Color profileBlue = Color(0xFF0077FF);


class ViewUserProfileScreen extends StatelessWidget {
  final String targetUserId;

  const ViewUserProfileScreen({super.key, required this.targetUserId});

  static Route route(String targetUserId) {
    return MaterialPageRoute(
      builder: (_) => ViewUserProfileScreen(targetUserId: targetUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;

    if (currentAuthUserId == targetUserId) {
      developer.log("Viewing own profile via ViewUserProfileScreen. CurrentUserID: $currentAuthUserId, TargetUserID: $targetUserId", name: "ViewUserProfileScreen");
    }

    return BlocProvider(
      create: (context) => UserInteractionCubit(
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        targetUserId,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<UserInteractionCubit, UserInteractionState>(
            builder: (context, state) {
              if (state is UserInteractionProfileLoaded) {
                return Text(state.targetUserProfile.displayName ?? state.targetUserProfile.username ?? 'User Profile');
              }
              return const Text('User Profile');
            },
          ),
        ),
        body: BlocConsumer<UserInteractionCubit, UserInteractionState>(
          listener: (context, state) {
            if (state is UserInteractionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is UserInteractionInitial || state is UserInteractionLoading) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(state is UserInteractionLoading && state.loadingMessage!=null ? Colors.transparent : profilePrimaryOrange)));
            }
            if (state is UserInteractionError && state.targetUserProfile == null) {
              return Center(child: Text('Could not load profile: ${state.message}'));
            }
            if (state is UserInteractionProfileLoaded || (state is UserInteractionError && state.targetUserProfile != null) ) {
              
              UserProfile userProfile;
              bool isFollowingUser;
              bool isProcessingFollowAction;

              if (state is UserInteractionProfileLoaded) {
                 userProfile = state.targetUserProfile;
                 isFollowingUser = state.isFollowing;
                 isProcessingFollowAction = state.isProcessingFollow;
              } else if (state is UserInteractionError && state.targetUserProfile != null) {
                 userProfile = state.targetUserProfile!;
                 isFollowingUser = state.wasFollowing ?? false;
                 isProcessingFollowAction = false;
              } else {
                return const Center(child: Text("An unexpected error occurred displaying the profile."));
              }
             
              final theme = Theme.of(context);
              final bool isOwnProfile = currentAuthUserId == userProfile.uid;
              
              String firstName = "User";
              String lastName = "";
              if (userProfile.displayName != null && userProfile.displayName!.trim().isNotEmpty) {
                final names = userProfile.displayName!.trim().split(' ');
                firstName = names.first;
                if (names.length > 1) lastName = names.sublist(1).join(' ');
              } else if (userProfile.username != null && userProfile.username!.trim().isNotEmpty) {
                firstName = userProfile.username!;
              }


              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: profilePrimaryOrange,
                          backgroundImage: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(userProfile.profilePictureUrl!)
                              : null,
                          child: userProfile.profilePictureUrl == null || userProfile.profilePictureUrl!.isEmpty
                              ? const Icon(Icons.person, size: 45, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName.toUpperCase(),
                                style: theme.textTheme.headlineMedium?.copyWith(color: profileTextBlack, fontWeight: FontWeight.w900, height: 1.1),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              if (lastName.isNotEmpty)
                                Text(
                                  lastName.toUpperCase(),
                                  style: theme.textTheme.headlineMedium?.copyWith(color: profilePrimaryOrange, fontWeight: FontWeight.w900, height: 1.1),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              if (userProfile.username != null && userProfile.username!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '@${userProfile.username}',
                                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          context,
                          userProfile.followersCount,
                          'Followers',
                          onTap: () {
                             Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.followers));
                          }
                        ),
                        _buildStatColumn(
                          context,
                          userProfile.followingCount,
                          'Following',
                          onTap: () {
                             Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.following));
                          }
                        ),
                        _buildStatColumn(context, userProfile.level, 'Level'),
                      ],
                    ),
                    const SizedBox(height: 25),

                    if (!isOwnProfile && currentAuthUserId != null)
                      ElevatedButton.icon(
                        icon: Icon(
                          isFollowingUser ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFollowingUser ? 'UNFOLLOW' : 'FOLLOW',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowingUser ? Colors.grey.shade600 : profilePrimaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isProcessingFollowAction ? null : () {
                          context.read<UserInteractionCubit>().toggleFollow();
                        },
                      ),
                    if (isProcessingFollowAction && !isOwnProfile)
                       const Padding(padding: EdgeInsets.only(top: 8.0), child: Center(child: SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2.5)))),
                    
                    const SizedBox(height: 25),
                    Text('User\'s Posts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text('Posts by ${userProfile.username ?? "this user"} will appear here.', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Profile not available."));
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, int count, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Додаємо трохи padding для тап-зони
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.compact().format(count),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: profileTextBlack),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                if (onTap != null) // Іконка тільки якщо є onTap
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade500)
              ],
            ),
          ],
        ),
      ),
    );
  }
}