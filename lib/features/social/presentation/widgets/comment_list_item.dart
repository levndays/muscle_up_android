// lib/features/social/presentation/widgets/comment_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import 'package:muscle_up/l10n/app_localizations.dart';
import '../../../../core/domain/entities/comment.dart';
import '../cubit/post_interaction_cubit.dart';
import 'dart:developer' as developer;
import '../screens/view_user_profile_screen.dart';
import '../../../../widgets/fullscreen_image_viewer.dart';

class CommentListItem extends StatelessWidget {
  final Comment comment;

  const CommentListItem({super.key, required this.comment});

  void _showEditCommentDialog(BuildContext context, PostInteractionCubit cubit) {
    final TextEditingController textController = TextEditingController(text: comment.text);
    final formKey = GlobalKey<FormState>();
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.commentListItemEditDialogTitle),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: loc.commentListItemEditDialogHint,
              ),
               validator: (value) => value == null || value.trim().isEmpty ? loc.addExerciseDialogSetsErrorEmpty : null,
            ),
          ),
          actions: [
            TextButton(
              child: Text(loc.commentListItemDialogButtonCancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(loc.commentListItemDialogButtonSave),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                    cubit.updateComment(comment.id, textController.text.trim());
                    Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCommentDialog(BuildContext context, PostInteractionCubit cubit) {
    final loc = AppLocalizations.of(context)!;
     showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.commentListItemDeleteDialogTitle),
          content: Text(loc.commentListItemDeleteDialogMessage),
          actions: [
            TextButton(
              child: Text(loc.commentListItemDialogButtonCancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(loc.commentListItemDialogButtonDelete),
              onPressed: () {
                 cubit.deleteComment(comment.id);
                 Navigator.of(dialogContext).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.commentListItemSnackbarDeleted), backgroundColor: Colors.orangeAccent, duration: const Duration(seconds: 2))
                 );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final timeAgo = DateFormat.yMMMd().add_jm().format(comment.timestamp.toDate());
    final currentUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
    final bool isAuthor = currentUserId == comment.userId;
    final cubit = context.read<PostInteractionCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.authorProfilePicUrl != null && comment.authorProfilePicUrl!.isNotEmpty) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImageViewer(imageProvider: NetworkImage(comment.authorProfilePicUrl!), heroTag: "comment_avatar_${comment.id}")));
              }
            },
            child: Hero(
              tag: "comment_avatar_${comment.id}",
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                backgroundImage: comment.authorProfilePicUrl != null && comment.authorProfilePicUrl!.isNotEmpty
                    ? NetworkImage(comment.authorProfilePicUrl!)
                    : null,
                child: comment.authorProfilePicUrl == null || comment.authorProfilePicUrl!.isEmpty
                    ? Icon(Icons.person_outline, size: 18, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(ViewUserProfileScreen.route(comment.userId));
                      },
                      child: Text(
                        comment.authorUsername,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    const Spacer(),
                    if (isAuthor)
                      SizedBox(
                        width: 30, height: 30,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                          padding: EdgeInsets.zero,
                          tooltip: loc.commentListItemMenuEdit, // Re-using, consider a specific one
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(leading: const Icon(Icons.edit_outlined, size: 20), title: Text(loc.commentListItemMenuEdit, style: const TextStyle(fontSize: 14)), dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(leading: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), title: Text(loc.commentListItemMenuDelete, style: const TextStyle(fontSize: 14, color: Colors.redAccent)), dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
                            ),
                          ],
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _showEditCommentDialog(context, cubit);
                            } else if (value == 'delete') {
                              _showDeleteCommentDialog(context, cubit);
                            }
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.5, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}