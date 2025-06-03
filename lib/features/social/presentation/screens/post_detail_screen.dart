// lib/features/social/presentation/screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/comment.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/post_interaction_cubit.dart';
import '../widgets/comment_list_item.dart';
import 'dart:developer' as developer;

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final Post initialPost;

  const PostDetailScreen({super.key, required this.postId, required this.initialPost});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();


  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment(BuildContext context, PostInteractionCubit cubit) {
    if (_commentController.text.trim().isEmpty) return;
    cubit.addComment(_commentController.text.trim());
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  Post? _extractPostFromState(PostInteractionState state) {
    if (state is PostInteractionInitial) return state.post;
    if (state is PostUpdated) return state.post;
    if (state is PostCommentsLoaded) return state.post;
    if (state is PostInteractionLoading) return state.post;
    if (state is PostInteractionFailure) return state.post;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAuthUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;

    return BlocProvider(
      create: (context) => PostInteractionCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        widget.postId,
        widget.initialPost,
      )..fetchComments(),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<PostInteractionCubit, PostInteractionState>(
            builder: (context, state) {
              String titleText = "Post";
              // Використовуємо _extractPostFromState для отримання поста
              Post? appBarPost = _extractPostFromState(state);
              if (appBarPost != null) titleText = appBarPost.authorUsername;
              return Text(titleText);
            },
          ),
          actions: [
            BlocBuilder<PostInteractionCubit, PostInteractionState>(
              builder: (context, state) {
                // Використовуємо _extractPostFromState для отримання поста
                Post? post = _extractPostFromState(state);
                if (post != null && post.userId == currentAuthUserId) {
                  return IconButton(
                    icon: Icon(
                      post.isCommentsEnabled ? Icons.comment_outlined : Icons.comments_disabled_outlined,
                      color: post.isCommentsEnabled ? theme.colorScheme.primary : Colors.grey,
                    ),
                    tooltip: post.isCommentsEnabled ? 'Disable Comments' : 'Enable Comments',
                    onPressed: () {
                      context.read<PostInteractionCubit>().toggleCommentsEnabled();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<PostInteractionCubit, PostInteractionState>(
          listener: (context, state) {
            if (state is PostInteractionFailure && state.post == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
              Navigator.of(context).pop();
            } else if (state is PostInteractionFailure) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<PostInteractionCubit>();
            // Використовуємо _extractPostFromState для отримання поста
            Post? post = _extractPostFromState(state);
            List<Comment> comments = [];
            bool isLoadingPostDetails = state is PostInteractionLoading;
            bool isLoadingComments = false;

            if (state is PostCommentsLoaded) {
              comments = state.comments;
            } else if (post != null && state is! PostInteractionFailure && state is! PostCommentsLoaded){
              isLoadingComments = true;
            }

            if (post == null && isLoadingPostDetails) {
              return const Center(child: CircularProgressIndicator());
            }
            if (post == null) {
              // Якщо ми тут і стан не Failure з post == null (що обробляється в listener),
              // то це може бути початковий момент до завантаження.
              // Або якщо _extractPostFromState повернув null для непередбаченого стану.
              if (state is PostInteractionFailure && state.post == null) {
                 return const Center(child: Text("Post not found or could not be loaded."));
              }
               return const Center(child: CircularProgressIndicator()); // Або інша заглушка
            }
            
            final bool isLikedByCurrentUser = currentAuthUserId != null && post.likedBy.contains(currentAuthUserId);

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundImage: post.authorProfilePicUrl != null && post.authorProfilePicUrl!.isNotEmpty
                                        ? NetworkImage(post.authorProfilePicUrl!) : null,
                                    child: post.authorProfilePicUrl == null || post.authorProfilePicUrl!.isEmpty
                                        ? const Icon(Icons.person, size: 22) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.authorUsername, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        Text(DateFormat.yMMMMd('en_US').add_jm().format(post.timestamp.toDate()), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(post.textContent, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.5, height: 1.45)),
                              if (post.mediaUrl != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(aspectRatio: 16 / 9, child: Image.network(post.mediaUrl!, fit: BoxFit.cover)),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Divider(height: 1, color: Colors.grey.shade300),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(isLikedByCurrentUser ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined, color: isLikedByCurrentUser ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color),
                                      label: Text('${post.likesCount} Like${post.likesCount == 1 ? "" : "s"}', style: TextStyle(color: isLikedByCurrentUser ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color)),
                                      onPressed: () => cubit.toggleLike(),
                                    ),
                                    TextButton.icon(
                                      icon: Icon(Icons.chat_bubble_outline, color: theme.textTheme.bodyMedium?.color),
                                      label: Text('${post.commentsCount} Comment${post.commentsCount == 1 ? "" : "s"}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                      onPressed: post.isCommentsEnabled ? () => _commentFocusNode.requestFocus() : null,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: Colors.grey.shade300),
                              if (post.isCommentsEnabled) const SizedBox(height: 16),
                              if (post.isCommentsEnabled) Text("Comments", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      if (isLoadingComments && comments.isEmpty)
                        const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                      if (!post.isCommentsEnabled && !isLoadingComments) // Прибираємо comments.isEmpty, щоб показувати завжди, якщо вимкнено
                         SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                            child: Center(child: Text("Comments are disabled for this post.", style: TextStyle(color: Colors.grey.shade600))),
                          ),
                        ),
                      if (post.isCommentsEnabled && comments.isEmpty && !isLoadingComments)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
                            child: Center(child: Text("No comments yet. Be the first!", style: TextStyle(color: Colors.grey.shade600))),
                          ),
                        ),
                      if (comments.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => CommentListItem(comment: comments[index]),
                            childCount: comments.length,
                          ),
                        ),
                       SliverToBoxAdapter(child: SizedBox(height: (post.isCommentsEnabled && currentAuthUserId != null) ? 100 : 20)),
                    ],
                  ),
                ),
                if (post.isCommentsEnabled && currentAuthUserId != null) // Показуємо поле вводу тільки якщо коментарі увімкнені та користувач авторизований
                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -3))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (text) => _submitComment(context, cubit),
                              minLines: 1,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _submitComment(context, cubit),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.send, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}