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
import '../widgets/post_card_content_widget.dart';
import '../../../../core/domain/entities/vote_type.dart';
import 'dart:developer' as developer;
import 'create_post_screen.dart';
import 'view_user_profile_screen.dart';
import '../../../../widgets/fullscreen_image_viewer.dart'; // NEW

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
    if (state is PostDeleting) return state.postToDelete;
    if (state is PostUpdating) return state.postToUpdate;
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
              Post? appBarPost = _extractPostFromState(state);
              if (appBarPost != null) titleText = appBarPost.authorUsername;
              return Text(titleText);
            },
          ),
          actions: [
            BlocBuilder<PostInteractionCubit, PostInteractionState>(
              builder: (context, state) {
                Post? post = _extractPostFromState(state);
                if (post != null && post.userId == currentAuthUserId) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: "Post Options",
                    onSelected: (String value) async {
                       if (value == 'edit_comments') {
                        context.read<PostInteractionCubit>().toggleCommentsEnabled();
                      } else if (value == 'edit_post') {
                         await Navigator.of(context).push<bool>(
                           CreatePostScreen.route(postToEdit: post),
                         );
                      } else if (value == 'delete_post') {
                         final confirmed = await showDialog<bool>(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text('Delete Post?'),
                             content: const Text('Are you sure you want to delete this post? This action cannot be undone and will remove all associated comments and media.'),
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
                       if (post.type == PostType.standard)
                        const PopupMenuItem<String>(
                          value: 'edit_post',
                          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit Post')),
                        ),
                      PopupMenuItem<String>(
                        value: 'edit_comments',
                        child: ListTile(
                          leading: Icon(post.isCommentsEnabled ? Icons.comment_outlined : Icons.comments_disabled_outlined),
                          title: Text(post.isCommentsEnabled ? 'Disable Comments' : 'Enable Comments'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete_post',
                        child: ListTile(leading: Icon(Icons.delete_forever_outlined, color: Colors.redAccent), title: Text('Delete Post', style: TextStyle(color: Colors.redAccent))),
                      ),
                    ],
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
            } else if (state is PostDeletedSuccessfully) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post "${state.postId}" has been deleted.'), backgroundColor: Colors.orangeAccent, duration: const Duration(seconds: 3)),
                );
                Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            final cubit = context.read<PostInteractionCubit>();
            Post? post = _extractPostFromState(state);
            List<Comment> comments = [];
            bool isLoadingPostDetails = state is PostInteractionLoading && state.post.id == widget.postId;
            bool isLoadingComments = false;
            VoteType? currentUserVote; 

            if (state is PostCommentsLoaded) {
              comments = state.comments;
              currentUserVote = state.currentUserVote;
            } else if (state is PostUpdated) {
              currentUserVote = state.currentUserVote;
              if (cubit.state is PostCommentsLoaded) {
              } else if (post != null && (state is! PostInteractionFailure) && (state is! PostInteractionLoading)) {
                isLoadingComments = true;
              }
            } else if (post != null && (state is! PostInteractionFailure) && (state is! PostCommentsLoaded) && (state is! PostInteractionLoading)) {
              isLoadingComments = true;
            }

            if (post == null && isLoadingPostDetails) {
              return const Center(child: CircularProgressIndicator());
            }
            if (post == null) {
              if (state is PostInteractionFailure && state.post == null) {
                 return const Center(child: Text("Post not found or could not be loaded."));
              }
              return const Center(child: Text("Loading post details..."));
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
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(ViewUserProfileScreen.route(post.userId));
                                },
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (post.authorProfilePicUrl != null && post.authorProfilePicUrl!.isNotEmpty) {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(post.authorProfilePicUrl!), heroTag: "post_avatar_${post.id}")));
                                        }
                                      },
                                      child: Hero(
                                        tag: "post_avatar_${post.id}",
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundImage: post.authorProfilePicUrl != null && post.authorProfilePicUrl!.isNotEmpty
                                              ? NetworkImage(post.authorProfilePicUrl!) : null,
                                          child: post.authorProfilePicUrl == null || post.authorProfilePicUrl!.isEmpty
                                              ? const Icon(Icons.person, size: 22) : null,
                                        ),
                                      ),
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
                              ),
                              const SizedBox(height: 16),
                              if(post.textContent.isNotEmpty) 
                                Text(post.textContent, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.5, height: 1.45)),
                              
                              PostCardContentWidget(
                                post: post,
                                currentUserVote: currentUserVote,
                                isDetailedView: true, 
                              ),
                              
                              if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty && post.type == PostType.standard) ...[ 
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(post.mediaUrl!), heroTag: "post_media_${post.id}")));
                                  },
                                  child: Hero(
                                    tag: "post_media_${post.id}",
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9, 
                                        child: Image.network(
                                          post.mediaUrl!, 
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                                          },
                                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                                        )
                                      ),
                                    ),
                                  ),
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
                      if (!post.isCommentsEnabled && !isLoadingComments)
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
                if (post.isCommentsEnabled && currentAuthUserId != null)
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