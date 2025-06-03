// lib/features/social/presentation/widgets/post_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/vote_type.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/post_interaction_cubit.dart';
import '../screens/post_detail_screen.dart';
import 'dart:developer' as developer;

// НЕ ПОТРІБНІ ТУТ, бо логіка в PostCardContentWidget
// import '../../../../core/domain/entities/routine.dart';
// import '../../../../core/domain/repositories/routine_repository.dart';
// import '../../../social/presentation/screens/create_post_screen.dart';
// import 'vote_progress_bar_widget.dart';
import 'post_card_content_widget.dart'; // <-- НОВИЙ ІМПОРТ

class PostListItem extends StatelessWidget {
  final Post post;

  const PostListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(post.id),
      create: (context) => PostInteractionCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        post.id,
        post,
      ),
      child: _PostListItemContent(),
    );
  }
}

class _PostListItemContent extends StatelessWidget {
  // _addRoutineToMyRoutines тепер знаходиться в PostCardContentWidget
  // Якщо він потрібен лише там, його можна видалити звідси.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PostInteractionCubit, PostInteractionState>(
      builder: (context, state) {
        Post currentPost;
        VoteType? currentUserVote;

        if (state is PostInteractionInitial) {
          currentPost = state.post;
          currentUserVote = null;
        } else if (state is PostUpdated) {
          currentPost = state.post;
          currentUserVote = state.currentUserVote;
        } else if (state is PostCommentsLoaded) {
          currentPost = state.post;
          currentUserVote = state.currentUserVote;
        } else if (state is PostInteractionLoading) {
          currentPost = state.post;
           currentUserVote = null;
        } else if (state is PostInteractionFailure && state.post != null) {
           currentPost = state.post!;
           currentUserVote = null;
        } else {
          final initialPostFromCubitState = context.read<PostInteractionCubit>().state;
          if (initialPostFromCubitState is PostInteractionInitial) {
             currentPost = initialPostFromCubitState.post;
             currentUserVote = null;
          } else {
             developer.log('PostListItem: Unexpected state or post not available: $state', name: 'PostListItem');
             return Card(
               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
               child: const Padding(
                 padding: EdgeInsets.all(16.0),
                 child: Text("Error loading post content."),
               ),
             );
          }
        }

        final timeAgo = DateFormat.yMMMd('en_US').add_jm().format(currentPost.timestamp.toDate());
        final currentAuthUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
        final bool isLikedByCurrentUser = currentAuthUserId != null && currentPost.likedBy.contains(currentAuthUserId);
        final bool isDetailedView = false; // В PostListItem це завжди не детальний перегляд

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostDetailScreen(postId: currentPost.id, initialPost: currentPost),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: currentPost.authorProfilePicUrl != null && currentPost.authorProfilePicUrl!.isNotEmpty
                            ? NetworkImage(currentPost.authorProfilePicUrl!)
                            : null,
                        child: currentPost.authorProfilePicUrl == null || currentPost.authorProfilePicUrl!.isEmpty
                            ? Icon(Icons.person, size: 20, color: theme.colorScheme.primary)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPost.authorUsername,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (currentPost.textContent.isNotEmpty && currentPost.type == PostType.standard)
                    Text(
                      currentPost.textContent,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                       maxLines: 5,
                       overflow: TextOverflow.ellipsis,
                    ),
                  if (currentPost.textContent.isNotEmpty && (currentPost.type == PostType.routineShare || currentPost.type == PostType.recordClaim))
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text(
                         currentPost.textContent,
                         style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                         maxLines: 3, // Менше рядків для прев'ю у стрічці
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                  if (currentPost.mediaUrl != null && currentPost.type == PostType.standard) ...[ // Медіа тільки для стандартного поста у списку
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(currentPost.mediaUrl!, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                  PostCardContentWidget(
                    post: currentPost,
                    currentUserVote: currentUserVote,
                    isDetailedView: isDetailedView,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          isLikedByCurrentUser ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                          color: isLikedByCurrentUser ? theme.colorScheme.primary : Colors.grey.shade700,
                          size: 20,
                        ),
                        label: Text(
                          currentPost.likesCount.toString(),
                          style: TextStyle(
                            color: isLikedByCurrentUser ? theme.colorScheme.primary : Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: isLikedByCurrentUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onPressed: () {
                          context.read<PostInteractionCubit>().toggleLike();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0,0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: Icon(
                          currentPost.isCommentsEnabled ? Icons.chat_bubble_outline : Icons.chat_bubble_outline_rounded,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                        label: Text(
                          currentPost.commentsCount.toString(),
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                        onPressed: () {
                           Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(postId: currentPost.id, initialPost: currentPost),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(0,0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}