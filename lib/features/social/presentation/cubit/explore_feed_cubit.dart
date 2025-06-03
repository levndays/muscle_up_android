// lib/features/social/presentation/cubit/explore_feed_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/repositories/post_repository.dart';
import 'dart:developer' as developer;

part 'explore_feed_state.dart';

class ExploreFeedCubit extends Cubit<ExploreFeedState> {
  final PostRepository _postRepository;
  StreamSubscription<List<Post>>? _postsSubscription;

  ExploreFeedCubit(this._postRepository) : super(ExploreFeedInitial()) {
    fetchPosts();
  }

  void fetchPosts() {
    emit(ExploreFeedLoading());
    _postsSubscription?.cancel();
    _postsSubscription = _postRepository.getAllPostsStream().listen(
      (posts) {
        emit(ExploreFeedLoaded(posts));
        developer.log('ExploreFeedCubit: Loaded ${posts.length} posts.', name: 'ExploreFeedCubit');
      },
      onError: (error, stackTrace) {
        developer.log('ExploreFeedCubit: Error fetching posts: $error', name: 'ExploreFeedCubit', error: error, stackTrace: stackTrace);
        emit(ExploreFeedError(error.toString().replaceFirst("Exception: ", "")));
      },
    );
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    developer.log('ExploreFeedCubit closed.', name: 'ExploreFeedCubit');
    return super.close();
  }
}