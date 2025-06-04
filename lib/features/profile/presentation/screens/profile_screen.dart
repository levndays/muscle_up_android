// FILE: lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/entities/achievement.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_posts_feed_cubit.dart';
import '../../../profile_setup/presentation/screens/profile_setup_screen.dart';
import '../../../../auth_gate.dart';
import '../../../social/presentation/screens/follow_list_screen.dart';
import '../../../social/presentation/cubit/follow_list_cubit.dart' show FollowListType;
import '../../../social/presentation/widgets/post_list_item.dart';

const Color profilePrimaryOrange = Color(0xFFED5D1A);
const Color profilePurple = Color(0xFFB700FF);
const Color profileBlue = Color(0xFF0077FF);
const Color profileTextBlack = Colors.black87;
const Color profileWeightIconBg = Color(0xFFFFC107);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
    if (currentUserId == null) {
      // This should ideally not happen if AuthGate is working correctly
      return const Scaffold(body: Center(child: Text("Error: User not logged in.")));
    }

    return MultiBlocProvider(
      providers: [
        // UserProfileCubit is already provided by AuthGate -> HomePage
        // We ensure UserPostsFeedCubit is initialized here for this screen context
        BlocProvider<UserPostsFeedCubit>(
          create: (context) => UserPostsFeedCubit(
            RepositoryProvider.of<PostRepository>(context),
            RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
          )..fetchUserPosts(currentUserId),
        ),
      ],
      child: const _ProfileScreenContent(),
    );
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  @override
  void initState() {
    super.initState();
    // Initial fetch for UserProfileCubit might be handled by HomePage or AuthGate.
    // If this screen can be the first screen after AuthGate that uses UserProfileCubit,
    // ensure it's fetched if not already loaded.
    final userState = context.read<UserProfileCubit>().state;
    final currentAuthUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
    if (currentAuthUserId != null) {
      if (userState is UserProfileInitial || (userState is UserProfileError && userState.message.contains("not found"))) {
        context.read<UserProfileCubit>().fetchUserProfile(currentAuthUserId);
      }
      // UserPostsFeedCubit is already fetching in its BlocProvider create method.
    }
  }

  static const Map<String, String> _fitnessGoalDisplayNames = {
    'lose_weight': 'Lose Weight',
    'gain_muscle': 'Gain Muscle',
    'improve_stamina': 'Improve Stamina',
    'general_fitness': 'General Fitness',
    'improve_strength': 'Improve Strength',
  };

  String _getDisplayName(String? storedValue, Map<String, String> mapping) {
    if (storedValue == null || storedValue.isEmpty) {
      return 'N/A';
    }
    return mapping[storedValue] ?? storedValue.replaceAll('_', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
        if (!context.mounted) return;
        // Clear navigation stack and go to AuthGate
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        developer.log("Error logging out: $e", name: "ProfileScreen");
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatNumberWithSpaces(int number) {
    final formatter = NumberFormat("#,###", "en_US");
    return formatter.format(number).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, userState) {
        if (userState is UserProfileLoading || userState is UserProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (userState is UserProfileError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading profile: ${userState.message}', textAlign: TextAlign.center),
          ));
        } else if (userState is UserProfileLoaded) {
          final userProfile = userState.userProfile;

          final int xpPerLevelBase = 200;
          int calculateTotalXpForLevelStart(int level) {
            if (level <= 1) return 0;
            int totalXp = 0;
            for (int i = 1; i < level; i++) {
              totalXp += (xpPerLevelBase + (i - 1) * 50);
            }
            return totalXp;
          }
          int currentLevelXpStart = calculateTotalXpForLevelStart(userProfile.level);
          int xpToNextLevelTotal = (xpPerLevelBase + (userProfile.level - 1) * 50);
          if (xpToNextLevelTotal <= 0) xpToNextLevelTotal = xpPerLevelBase;
          int currentXpOnBar = (userProfile.xp - currentLevelXpStart).clamp(0, xpToNextLevelTotal);
          
          String firstName = "User";
          String lastName = "";

          if (userProfile.displayName != null && userProfile.displayName!.trim().isNotEmpty) {
            final names = userProfile.displayName!.trim().split(' ');
            firstName = names.first;
            if (names.length > 1) {
              lastName = names.sublist(1).join(' ');
            }
          } else if (userProfile.username != null && userProfile.username!.trim().isNotEmpty) {
            firstName = userProfile.username!;
          } else if (userProfile.email != null && userProfile.email!.contains('@')) {
             firstName = userProfile.email!.split('@').first;
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
              final currentAuthUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
              if (currentAuthUserId != null) {
                context.read<UserProfileCubit>().fetchUserProfile(currentAuthUserId, forceRemote: true);
                context.read<UserPostsFeedCubit>().fetchUserPosts(currentAuthUserId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: profilePrimaryOrange,
                            child: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
                                ? ClipOval(child: Image.network(userProfile.profilePictureUrl!, fit: BoxFit.cover, width: 80, height: 80,
                                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.white)
                                  ))
                                : const Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            firstName.toUpperCase(),
                            style: theme.textTheme.headlineSmall?.copyWith(color: profileTextBlack, fontWeight: FontWeight.w900, height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            lastName.toUpperCase(),
                            style: theme.textTheme.headlineSmall?.copyWith(color: profilePrimaryOrange, fontWeight: FontWeight.w900, height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (userProfile.username != null && userProfile.username!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: profileBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '@${userProfile.username}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: profilePurple,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'LVL ${userProfile.level}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (xpToNextLevelTotal > 0)
                                  Text(
                                    '${currentXpOnBar} / ${xpToNextLevelTotal} XP',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildSocialStatRow(
                    context,
                    'FOLLOWERS',
                    _formatNumberWithSpaces(userProfile.followersCount),
                    () {
                      Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.followers));
                    }
                  ),
                  const SizedBox(height: 12),
                  _buildSocialStatRow(
                    context,
                    'FOLLOWING',
                    _formatNumberWithSpaces(userProfile.followingCount),
                     () {
                       Navigator.of(context).push(FollowListScreen.route(userId: userProfile.uid, type: FollowListType.following));
                     }
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, color: profilePrimaryOrange, size: 28),
                              const SizedBox(width: 5),
                              Text('${userProfile.longestStreak}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: profileTextBlack)),
                            ],
                          ),
                          Text('BEST STREAK', style: theme.textTheme.bodyMedium?.copyWith(color: profilePrimaryOrange, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: profileWeightIconBg,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: const Icon(Icons.monitor_weight_outlined, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userProfile.weightKg != null ? '${userProfile.weightKg?.toStringAsFixed(0)} KG' : '-- KG',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: profileTextBlack),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userProfile.fitnessGoal != null && userProfile.fitnessGoal!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text.rich(
                            TextSpan(children: [
                              const TextSpan(text: 'GOAL: ', style: TextStyle(color: profileTextBlack, fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: _getDisplayName(userProfile.fitnessGoal, _fitnessGoalDisplayNames).toUpperCase(),
                                  style: const TextStyle(color: profilePrimaryOrange, fontWeight: FontWeight.bold)
                              ),
                            ]),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (userProfile.lastWorkoutTimestamp != null)
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'LAST TRAINING: ', style: TextStyle(color: profilePrimaryOrange, fontWeight: FontWeight.bold)),
                          TextSpan(text: DateFormat('dd MMM yyyy').format(userProfile.lastWorkoutTimestamp!.toDate()).toUpperCase(), style: const TextStyle(color: profileTextBlack, fontWeight: FontWeight.bold)),
                        ]),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.center,
                    child: Text('REWARDS', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: profileTextBlack, fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  if (achievedRewardIdsEnum.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "No rewards unlocked yet. Keep training!",
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
                          return _buildRewardItem(context, achievement, true, null);
                        },
                      ),
                    ),
                  const SizedBox(height: 25),
                   Align(
                    alignment: Alignment.center,
                    child: Text('MY POSTS', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: profileTextBlack, fontSize: 18)),
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
                            child: Text('You haven\'t made any posts yet.', style: TextStyle(color: Colors.grey.shade600)),
                          );
                        }
                        // Using ListView.builder directly inside SingleChildScrollView is not recommended
                        // without proper constraints or shrinkWrap + NeverScrollableScrollPhysics.
                        return Column( // Wrap ListView.builder with Column to avoid infinite height
                          mainAxisSize: MainAxisSize.min,
                          children: postState.posts.map((post) => PostListItem(post: post)).toList(),
                        );
                      }
                      return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Text('Loading posts...'))); // Default for UserPostsFeedInitial
                    },
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProfileSetupScreen(userProfileToEdit: userProfile),
                          )).then((updated) {
                             if (updated == true && context.mounted) {
                                final currentAuthUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
                                if (currentAuthUserId != null) {
                                  context.read<UserProfileCubit>().fetchUserProfile(currentAuthUserId, forceRemote: true);
                                  context.read<UserPostsFeedCubit>().fetchUserPosts(currentAuthUserId);
                                }
                              }
                          });
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text('EDIT PROFILE', style: theme.textTheme.labelLarge?.copyWith(color: profilePrimaryOrange, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      TextButton(
                        onPressed: () => _logout(context),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('LOG OUT', style: theme.textTheme.labelLarge?.copyWith(color: profileTextBlack, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, color: profileTextBlack, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // For bottom padding inside SingleChildScrollView
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('An unexpected error occurred loading your profile.'));
      },
    );
  }

 Widget _buildSocialStatRow(BuildContext context, String label, String value, [VoidCallback? onTap]) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: profileTextBlack, fontSize: 16)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: profileBlue, fontWeight: FontWeight.w900, fontSize: 18)),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: profileBlue.withOpacity(0.7), size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(BuildContext context, Achievement achievement, bool isAchieved, String? conditionMessage) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: achievement.description,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: profilePurple.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
                 boxShadow: [
                  BoxShadow(
                    color: profilePurple.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              achievement.name,
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
    );
  }
}