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

import 'post_card_content_widget.dart';
import '../screens/view_user_profile_screen.dart';
import '../screens/create_post_screen.dart'; // NEW: Для навігації на редагування

class PostListItem extends StatelessWidget {
  final Post post;

  const PostListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Надаємо PostInteractionCubit для кожного елемента списку,
    // щоб керувати станом саме цього поста (лайки, коментарі, видалення, редагування).
    return BlocProvider(
      key: ValueKey(post.id), // Унікальний ключ для кожного кубіта
      create: (context) => PostInteractionCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        post.id,
        post, // Передаємо початковий стан поста
      ),
      child: _PostListItemContent(),
    );
  }
}

class _PostListItemContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Слухаємо зміни стану конкретного поста
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
          // Тут не потрібно нічого робити для оновлення UI стрічки,
          // оскільки основний Cubit стрічки (ExploreFeedCubit або UserPostsFeedCubit)
          // має слухати загальний потік постів і автоматично оновиться.
          // Якщо цей PostListItem є частиною екрану, де він єдиний (наприклад, PostDetailScreen, хоча це малоймовірно),
          // то потрібно було б закрити екран.
        }
      },
      buildWhen: (previous, current) {
        // Перебудовувати тільки якщо це не просто зміна коментарів (якщо вони не відображаються тут)
        // або якщо це не тимчасовий стан завантаження/видалення, який не змінює дані самого поста.
        if (current is PostDeleting || current is PostUpdating) return false; // Не перебудовувати під час цих дій
        return true;
      },
      builder: (context, state) {
        Post currentPost;
        VoteType? currentUserVote;

        // Визначаємо поточний пост для відображення
        if (state is PostInteractionInitial) currentPost = state.post;
        else if (state is PostUpdated) currentPost = state.post;
        else if (state is PostCommentsLoaded) currentPost = state.post;
        else if (state is PostInteractionLoading) currentPost = state.post;
        else if (state is PostInteractionFailure && state.post != null) currentPost = state.post!;
        else { // Якщо стан непередбачений або пост недоступний, отримуємо його з контексту Cubit напряму
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
        
        // Визначаємо currentUserVote зі стану, якщо він є
        if (state is PostUpdated) currentUserVote = state.currentUserVote;
        if (state is PostCommentsLoaded) currentUserVote = state.currentUserVote;


        final timeAgo = DateFormat.yMMMd('en_US').add_jm().format(currentPost.timestamp.toDate());
        final currentAuthUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
        final bool isAuthorOfPost = currentAuthUserId == currentPost.userId;
        final bool isLikedByCurrentUser = currentAuthUserId != null && currentPost.likedBy.contains(currentAuthUserId);
        final bool isDetailedView = false; // Для PostCardContentWidget

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
                          }
                        },
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
                      if (isAuthorOfPost) // NEW: Кнопка меню для автора
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                          tooltip: "Post options",
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              final bool? result = await Navigator.of(context).push<bool>(
                                CreatePostScreen.route(postToEdit: currentPost),
                              );
                              if (result == true && context.mounted) {
                                // Оновлення не потрібне тут, бо PostInteractionCubit слухає стрім
                                // context.read<PostInteractionCubit>()._subscribeToPostUpdates(); // Можна викликати для примусового оновлення, але не обов'язково
                              }
                            } else if (value == 'delete') {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Post?'),
                                  content: Text('Are you sure you want to delete this post? This action cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    TextButton(
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Delete'),
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
                            if (currentPost.type == PostType.standard) // Редагувати можна тільки стандартні пости (поки що)
                              const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit Post'))),
                            const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.redAccent), title: Text('Delete Post', style: TextStyle(color: Colors.redAccent)))),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (currentPost.textContent.isNotEmpty && currentPost.type == PostType.standard)
                    Text(
                      currentPost.textContent,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.4),
                       maxLines: isDetailedView ? null : 5, // У списку обмежуємо
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
                    ClipRRect(
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
                  ],
                  PostCardContentWidget( // Відображення специфічного контенту для routineShare/recordClaim
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