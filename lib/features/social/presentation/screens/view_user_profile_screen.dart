// lib/features/social/presentation/screens/view_user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/post_repository.dart'; 
import '../cubit/user_interaction_cubit.dart';
import '../../../profile/presentation/cubit/user_posts_feed_cubit.dart'; 
import '../../../../core/domain/entities/achievement.dart'; 
import '../widgets/post_list_item.dart'; 
import 'dart:developer' as developer;
import 'follow_list_screen.dart';
import '../cubit/follow_list_cubit.dart' show FollowListType;
import 'package:muscle_up/l10n/app_localizations.dart';
import '../../../../widgets/fullscreen_image_viewer.dart'; // NEW
import '../../../profile/presentation/widgets/achievement_details_dialog.dart'; // NEW


const Color profilePrimaryOrange = Color(0xFFED5D1A);
const Color profileTextBlack = Colors.black87;
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserInteractionCubit>(
          create: (context) => UserInteractionCubit(
            RepositoryProvider.of<UserProfileRepository>(context),
            RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
            targetUserId,
          ),
        ),
        BlocProvider<UserPostsFeedCubit>(
          create: (context) => UserPostsFeedCubit(
            RepositoryProvider.of<PostRepository>(context),
            RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
          )..fetchUserPosts(targetUserId), 
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<UserInteractionCubit, UserInteractionState>(
            builder: (context, state) {
              if (state is UserInteractionProfileLoaded) {
                return Text(state.targetUserProfile.displayName ?? state.targetUserProfile.username ?? AppLocalizations.of(context)!.viewUserProfileAppBarTitleFallback);
              }
              return Text(AppLocalizations.of(context)!.viewUserProfileAppBarTitleFallback);
            },
          ),
        ),
        body: BlocConsumer<UserInteractionCubit, UserInteractionState>(
          listener: (context, state) {
            final loc = AppLocalizations.of(context)!;
            if (state is UserInteractionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.viewUserProfileErrorLoadProfile(state.message)), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final loc = AppLocalizations.of(context)!;
            if (state is UserInteractionInitial || (state is UserInteractionLoading && state.loadingMessage == "Loading profile...")) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserInteractionError && state.targetUserProfile == null) {
              return Center(child: Text(loc.viewUserProfileErrorLoadProfile(state.message)));
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
                return Center(child: Text(loc.viewUserProfileErrorProfileNotAvailable));
              }
             
              final theme = Theme.of(context);
              final bool isOwnProfile = currentAuthUserId == userProfile.uid;
              
              String firstName = loc.profileScreenNameFallbackUser;
              String lastName = "";
              if (userProfile.displayName != null && userProfile.displayName!.trim().isNotEmpty) {
                final names = userProfile.displayName!.trim().split(' ');
                firstName = names.first;
                if (names.length > 1) lastName = names.sublist(1).join(' ');
              } else if (userProfile.username != null && userProfile.username!.trim().isNotEmpty) {
                firstName = userProfile.username!;
              }


              final List<AchievementId> achievedRewardIdsEnum = userProfile.achievedRewardIds
                .map((idString) {
                  try {
                    return AchievementId.values.firstWhere((e) => e.name == idString);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<AchievementId>()
                .toList();

              return RefreshIndicator(
                onRefresh: () async {
                   context.read<UserInteractionCubit>().initializeProfileAndListen();
                   context.read<UserPostsFeedCubit>().fetchUserPosts(targetUserId);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty) {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(userProfile.profilePictureUrl!), heroTag: "profile_avatar_${userProfile.uid}")));
                              }
                            },
                            child: Hero(
                              tag: "profile_avatar_${userProfile.uid}",
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: profilePrimaryOrange,
                                backgroundImage: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
                                    ? NetworkImage(userProfile.profilePictureUrl!)
                                    : null,
                                child: userProfile.profilePictureUrl == null || userProfile.profilePictureUrl!.isEmpty
                                    ? const Icon(Icons.person, size: 45, color: Colors.white)
                                    : null,
                              ),
                            ),
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
                            loc.profileScreenStatLabelFollowers,
                            onTap: () {
                               Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.followers));
                            }
                          ),
                          _buildStatColumn(
                            context,
                            userProfile.followingCount,
                            loc.profileScreenStatLabelFollowing,
                            onTap: () {
                               Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.following));
                            }
                          ),
                          _buildStatColumn(context, userProfile.level, loc.viewUserProfileStatLabelLevel),
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
                            isFollowingUser ? loc.viewUserProfileButtonUnfollow : loc.viewUserProfileButtonFollow,
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
                      
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: Text(loc.profileScreenRewardsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: profileTextBlack, fontSize: 18)),
                      ),
                      const SizedBox(height: 10),
                      if (achievedRewardIdsEnum.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            loc.profileScreenNoRewards,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        SizedBox(
                          height: 115, 
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: achievedRewardIdsEnum.length,
                            itemBuilder: (ctx, index) {
                              final achievementId = achievedRewardIdsEnum[index];
                              final achievement = allAchievements[achievementId];
                              if (achievement == null) return const SizedBox.shrink();
                              return _buildRewardItem(context, achievement);
                            },
                          ),
                        ),

                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: Text(loc.viewUserProfilePostsTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: profileTextBlack, fontSize: 18)),
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<UserPostsFeedCubit, UserPostsFeedState>( 
                        builder: (context, postState) {
                          if (postState is UserPostsFeedLoading) { 
                            return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: CircularProgressIndicator()));
                          } else if (postState is UserPostsFeedError) { 
                            return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40.0), child: Text('Error loading posts: ${postState.message}')));
                          } else if (postState is UserPostsFeedLoaded) { 
                            if (postState.posts.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(loc.viewUserProfileNoPosts(userProfile.username ?? 'this user'), style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center,),
                              );
                            }
                            return Column( 
                              mainAxisSize: MainAxisSize.min,
                              children: postState.posts.map((post) => PostListItem(post: post)).toList(),
                            );
                          }
                          return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40.0), child: Text(loc.exerciseExplorerLoading))); 
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
            return Center(child: Text(loc.viewUserProfileErrorProfileNotAvailable));
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, int count, String label, {VoidCallback? onTap}) {
    final loc = AppLocalizations.of(context)!;
    String localizedLabel = label; 
    if (label.toUpperCase() == loc.profileScreenStatLabelFollowers.toUpperCase()) localizedLabel = loc.profileScreenStatLabelFollowers;
    if (label.toUpperCase() == loc.profileScreenStatLabelFollowing.toUpperCase()) localizedLabel = loc.profileScreenStatLabelFollowing;
    if (label.toUpperCase() == loc.viewUserProfileStatLabelLevel.toUpperCase()) localizedLabel = loc.viewUserProfileStatLabelLevel;


    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                  localizedLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade500)
              ],
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildRewardItem(BuildContext context, Achievement achievement) {
    // Reusing the same logic as in profile_screen, but now it's encapsulated here.
    final loc = AppLocalizations.of(context)!;
    String achievementName = achievement.name;
    String achievementDescription = achievement.description;
    if (achievement.isPersonalized) {
      achievementName = achievement.name.replaceAll('[Detail]', loc.recordStatusVerified.toLowerCase()); 
      achievementDescription = achievement.description.replaceAll('[Detail]', loc.recordStatusVerified.toLowerCase()); 
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AchievementDetailsDialog(achievement: achievement),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox( 
              width: 64,
              height: 64,
              child: Image.asset(
                achievement.emblemAssetPath,
                fit: BoxFit.contain, 
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.shield_outlined, color: Colors.grey, size: 30);
                },
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                achievementName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: profileTextBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}