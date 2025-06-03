// lib/features/social/presentation/widgets/comment_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:intl/intl.dart';
import '../../../../core/domain/entities/comment.dart';
import '../cubit/post_interaction_cubit.dart'; // Для виклику delete/update
import 'dart:developer' as developer;

class CommentListItem extends StatelessWidget {
  final Comment comment;

  const CommentListItem({super.key, required this.comment});

  void _showEditCommentDialog(BuildContext context, PostInteractionCubit cubit) {
    final TextEditingController textController = TextEditingController(text: comment.text);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              maxLines: null, // Дозволяє багаторядкове введення
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Your comment...',
              ),
               validator: (value) => value == null || value.trim().isEmpty ? 'Comment cannot be empty' : null,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
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
     showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Comment?'),
          content: const Text('Are you sure you want to delete this comment? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                 cubit.deleteComment(comment.id);
                 Navigator.of(dialogContext).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment deleted.'), backgroundColor: Colors.orangeAccent, duration: Duration(seconds: 2))
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
    final timeAgo = DateFormat.yMMMd().add_jm().format(comment.timestamp.toDate());
    final currentUserId = RepositoryProvider.of<fb_auth.FirebaseAuth>(context).currentUser?.uid;
    final bool isAuthor = currentUserId == comment.userId;
    final cubit = context.read<PostInteractionCubit>(); // Отримуємо кубіт з контексту

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            backgroundImage: comment.authorProfilePicUrl != null && comment.authorProfilePicUrl!.isNotEmpty
                ? NetworkImage(comment.authorProfilePicUrl!)
                : null,
            child: comment.authorProfilePicUrl == null || comment.authorProfilePicUrl!.isEmpty
                ? Icon(Icons.person_outline, size: 18, color: Theme.of(context).colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorUsername,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    const Spacer(),
                    if (isAuthor)
                      SizedBox( // Обмежуємо розмір кнопки меню
                        width: 30, height: 30,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                          padding: EdgeInsets.zero,
                          tooltip: "Comment options",
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(leading: Icon(Icons.edit_outlined, size: 20), title: Text('Edit', style: TextStyle(fontSize: 14)), dense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(leading: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), title: Text('Delete', style: TextStyle(fontSize: 14, color: Colors.redAccent)), dense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8)),
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