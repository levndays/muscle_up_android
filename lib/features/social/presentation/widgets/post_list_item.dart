// lib/features/social/presentation/widgets/post_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/vote_type.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/post_interaction_cubit.dart';
import '../screens/post_detail_screen.dart';
import 'dart:developer' as developer;

import 'post_card_content_widget.dart';
import '../screens/view_user_profile_screen.dart';
import '../screens/create_post_screen.dart';
import '../../../../widgets/fullscreen_image_viewer.dart'; // NEW

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return BlocConsumer<PostInteractionCubit, PostInteractionState>(
      listener: (context, state) {
        if (state is PostInteractionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
          );
        } else if (state is PostDeletedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post "${state.postId}" deleted.'), backgroundColor: Colors.orangeAccent),
          );
        }
      },
      buildWhen: (previous, current) {
        if (current is PostDeleting || current is PostUpdating) return false;
        return true;
      },
      builder: (context, state) {
        Post currentPost;
        VoteType? currentUserVote;

        if (state is PostInteractionInitial) currentPost = state.post;
        else if (state is PostUpdated) currentPost = state.post;
        else if (state is PostCommentsLoaded) currentPost = state.post;
        else if (state is PostInteractionLoading) currentPost = state.post;
        else if (state is PostInteractionFailure && state.post != null) currentPost = state.post!;
        else {
            final cubitInitialState = context.read<PostInteractionCubit>().state;
            if (cubitInitialState is PostInteractionInitial) currentPost = cubitInitialState.post;
            else if (cubitInitialState is PostUpdated) currentPost = cubitInitialState.post;
            else if (cubitInitialState is PostCommentsLoaded) currentPost = cubitInitialState.post;
            else if (cubitInitialState is PostInteractionLoading) currentPost = cubitInitialState.post;
            else if (cubitInitialState is PostInteractionFailure && cubitInitialState.post != null) currentPost = cubitInitialState.post!;
            else {
              developer.log('PostListItem: Critical - Could not determine post from state: $state', name: 'PostListItem');
              return Card( margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), child: const Padding( padding: EdgeInsets.all(16.0), child: Text("Error loading post content.")));
            }
        }
        
        if (state is PostUpdated) currentUserVote = state.currentUserVote;
        if (state is PostCommentsLoaded) currentUserVote = state.currentUserVote;


        final timeAgo = DateFormat.yMMMd(loc.localeName).add_jm().format(currentPost.timestamp.toDate());
        final currentAuthUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
        final bool isAuthorOfPost = currentAuthUserId == currentPost.userId;
        final bool isLikedByCurrentUser = currentAuthUserId != null && currentPost.likedBy.contains(currentAuthUserId);
        final bool isDetailedView = false;

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
                      GestureDetector(
                        onTap: () {
                          if (currentPost.userId != currentAuthUserId) {
                            Navigator.of(context).push(ViewUserProfileScreen.route(currentPost.userId));
                          } else {
                            if (currentPost.authorProfilePicUrl != null && currentPost.authorProfilePicUrl!.isNotEmpty) {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(currentPost.authorProfilePicUrl!), heroTag: "post_avatar_${currentPost.id}")));
                            }
                          }
                        },
                        child: Hero(
                          tag: "post_avatar_${currentPost.id}",
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: currentPost.authorProfilePicUrl != null && currentPost.authorProfilePicUrl!.isNotEmpty
                                ? NetworkImage(currentPost.authorProfilePicUrl!)
                                : null,
                            child: currentPost.authorProfilePicUrl == null || currentPost.authorProfilePicUrl!.isEmpty
                                ? Icon(Icons.person, size: 20, color: theme.colorScheme.primary)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             GestureDetector(
                              onTap: () {
                                if (currentPost.userId != currentAuthUserId) {
                                  Navigator.of(context).push(ViewUserProfileScreen.route(currentPost.userId));
                                }
                              },
                              child: Text(
                                currentPost.authorUsername,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      if (isAuthorOfPost)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                          tooltip: loc.postDetailMenuTooltipOptions,
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              await Navigator.of(context).push<bool>(
                                CreatePostScreen.route(postToEdit: currentPost),
                              );
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(loc.postDetailDeleteConfirmTitle),
                                  content: Text(loc.postDetailDeleteConfirmMessage),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.postDetailDeleteConfirmButtonCancel)),
                                    TextButton(
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: Text(loc.postDetailDeleteConfirmButtonDelete),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                context.read<PostInteractionCubit>().deletePost();
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (currentPost.type == PostType.standard)
                              PopupMenuItem<String>(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(loc.postDetailMenuEditPost))),
                            PopupMenuItem<String>(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline, color: Colors.redAccent), title: Text(loc.postDetailMenuDeletePost, style: const TextStyle(color: Colors.redAccent)))),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (currentPost.textContent.isNotEmpty && currentPost.type == PostType.standard)
                    Text(
                      currentPost.textContent,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                       maxLines: isDetailedView ? null : 5,
                       overflow: isDetailedView ? null : TextOverflow.ellipsis,
                    ),
                  if (currentPost.textContent.isNotEmpty && (currentPost.type == PostType.routineShare || currentPost.type == PostType.recordClaim))
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text(
                         currentPost.textContent,
                         style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                         maxLines: isDetailedView ? null : 3,
                         overflow: isDetailedView ? null : TextOverflow.ellipsis,
                       ),
                     ),
                  if (currentPost.mediaUrl != null && currentPost.mediaUrl!.isNotEmpty && currentPost.type == PostType.standard) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(currentPost.mediaUrl!), heroTag: "post_media_${currentPost.id}")));
                      },
                      child: Hero(
                        tag: "post_media_${currentPost.id}",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              currentPost.mediaUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                              },
                              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                            ),
                          ),
                        ),
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
                        icon: Icon(isLikedByCurrentUser ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined, color: isLikedByCurrentUser ? theme.colorScheme.primary : Colors.grey.shade700, size: 20),
                        label: Text(currentPost.likesCount.toString(), style: TextStyle(color: isLikedByCurrentUser ? theme.colorScheme.primary : Colors.grey.shade700, fontSize: 14, fontWeight: isLikedByCurrentUser ? FontWeight.bold : FontWeight.normal)),
                        onPressed: () => context.read<PostInteractionCubit>().toggleLike(),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(0,0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: Icon(currentPost.isCommentsEnabled ? Icons.chat_bubble_outline : Icons.chat_bubble_outline_rounded, color: Colors.grey.shade700, size: 20),
                        label: Text(currentPost.commentsCount.toString(), style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                        onPressed: () {
                           Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(postId: currentPost.id, initialPost: currentPost),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(0,0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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