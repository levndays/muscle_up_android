// lib/features/social/presentation/screens/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import '../cubit/explore_feed_cubit.dart';
import '../widgets/post_list_item.dart';
import 'create_post_screen.dart'; // Для навігації
import 'dart:developer' as developer;

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreFeedCubit(
        RepositoryProvider.of<PostRepository>(context),
      ),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExploreFeedCubit, ExploreFeedState>(
        builder: (context, state) {
          if (state is ExploreFeedInitial || state is ExploreFeedLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExploreFeedLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.dynamic_feed_outlined, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                      const SizedBox(height: 16),
                      const Text(
                        'Nothing to explore yet.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Be the first to share something!',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                         textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ExploreFeedCubit>().fetchPosts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 70), // Відступ для FAB
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostListItem(post: post);
                },
              ),
            );
          } else if (state is ExploreFeedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error loading posts: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ExploreFeedCubit>().fetchPosts(),
                      child: const Text('Try Again'),
                    )
                  ],
                ),
              )
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(CreatePostScreen.route());
          if (result == true && context.mounted) {
            // Опціонально: оновити стрічку після створення посту,
            // хоча стрім має автоматично оновитися.
            // context.read<ExploreFeedCubit>().fetchPosts();
            developer.log("Returned from CreatePostScreen, post might have been created.", name: "ExploreScreenFAB");
          }
        },
        tooltip: 'Create Post',
        child: const Icon(Icons.add_comment_outlined),
      ),
    );
  }
}