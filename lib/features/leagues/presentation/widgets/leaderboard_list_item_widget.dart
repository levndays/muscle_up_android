// lib/features/leagues/presentation/widgets/leaderboard_list_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../social/presentation/screens/view_user_profile_screen.dart';
import '../../../../widgets/fullscreen_image_viewer.dart'; // NEW

class LeaderboardListItemWidget extends StatelessWidget {
  final UserProfile userProfile;
  final int rank;
  final String? currentUserId;

  const LeaderboardListItemWidget({
    super.key,
    required this.userProfile,
    required this.rank,
    this.currentUserId,
  });

  Widget _buildRankIndicator(BuildContext context, int rank) {
    if (rank == 1) {
      return const _MedalWidget(color: Color(0xFFFFD700), icon: Icons.emoji_events, rank: '1');
    } else if (rank == 2) {
      return const _MedalWidget(color: Color(0xFFC0C0C0), icon: Icons.emoji_events, rank: '2');
    } else if (rank == 3) {
      return const _MedalWidget(color: Color(0xFFCD7F32), icon: Icons.emoji_events, rank: '3');
    } else {
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = userProfile.uid == currentUserId;
    final NumberFormat xpFormatter = NumberFormat("#,###", "en_US");


    return Card(
      elevation: isCurrentUser ? 4 : 1.5,
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentUser ? Theme.of(context).colorScheme.primary.withOpacity(0.7) : Colors.white.withOpacity(0.15),
          width: isCurrentUser ? 1.5 : 0.8,
        ),
      ),
      color: Colors.white.withOpacity(isCurrentUser ? 0.12 : 0.07),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRankIndicator(context, rank),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(userProfile.profilePictureUrl!), heroTag: "leaderboard_avatar_${userProfile.uid}")));
                }
              },
              child: Hero(
                tag: "leaderboard_avatar_${userProfile.uid}",
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: userProfile.profilePictureUrl != null && userProfile.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(userProfile.profilePictureUrl!)
                      : null,
                  child: userProfile.profilePictureUrl == null || userProfile.profilePictureUrl!.isEmpty
                      ? Icon(Icons.person_outline, size: 20, color: Colors.white.withOpacity(0.8))
                      : null,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          userProfile.displayName ?? userProfile.username ?? 'Player',
          style: TextStyle(
            color: isCurrentUser ? Colors.amber.shade300 : Colors.white,
            fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: userProfile.username != null && userProfile.username!.isNotEmpty
            ? Text(
                '@${userProfile.username}',
                style: TextStyle(
                  color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${xpFormatter.format(userProfile.xp)} XP',
              style: TextStyle(
                color: isCurrentUser ? Colors.amber.shade400 : Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'IBMPlexMono'
              ),
            ),
             Text(
              'LVL ${userProfile.level}',
              style: TextStyle(
                color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.6),
                fontSize: 11,
                 fontFamily: 'IBMPlexMono'
              ),
            ),
          ],
        ),
        onTap: () {
          if (!isCurrentUser && currentUserId != null) {
            Navigator.of(context).push(ViewUserProfileScreen.route(userProfile.uid));
          }
        },
      ),
    );
  }
}

class _MedalWidget extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String rank;

  const _MedalWidget({
    required this.color,
    required this.icon,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, color: color, size: 32),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withOpacity(0.2), width: 0.5)
          ),
          alignment: Alignment.center,
          child: Text(
            rank,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}