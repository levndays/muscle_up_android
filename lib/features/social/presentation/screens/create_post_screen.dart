// lib/features/social/presentation/screens/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/post.dart'; // Для PostType
import '../../../../core/domain/repositories/post_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/create_post_cubit.dart';
import 'dart:developer' as developer;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      builder: (_) => const CreatePostScreen(),
    );
  }

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _areCommentsEnabled = true; // За замовчуванням коментарі увімкнені

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePostCubit(
        RepositoryProvider.of<PostRepository>(context),
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          actions: [
            BlocBuilder<CreatePostCubit, CreatePostState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is CreatePostLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<CreatePostCubit>().submitPost(
                                  textContent: _textController.text,
                                  isCommentsEnabled: _areCommentsEnabled, // Передаємо значення
                                );
                          }
                        },
                  child: state is CreatePostLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<CreatePostCubit, CreatePostState>(
          listener: (context, state) {
            if (state is CreatePostSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post published successfully!'), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is CreatePostFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          // Дозволяємо порожній текст, якщо буде медіа (поки не реалізовано)
                          // if (_mediaFile == null) return 'Post content cannot be empty.';
                          return 'Post content cannot be empty.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Comments'),
                      subtitle: Text(_areCommentsEnabled ? 'Users can comment on this post' : 'Comments are disabled'),
                      value: _areCommentsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _areCommentsEnabled = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Тут буде місце для додавання медіа в майбутньому
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}