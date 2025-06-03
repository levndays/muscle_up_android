// lib/features/social/presentation/cubit/create_post_state.dart
part of 'create_post_cubit.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object> get props => [];
}

class CreatePostInitial extends CreatePostState {}

class CreatePostLoading extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {
  final Post createdPost;
  const CreatePostSuccess(this.createdPost);

  @override
  List<Object> get props => [createdPost];
}

class CreatePostFailure extends CreatePostState {
  final String error;
  const CreatePostFailure(this.error);

  @override
  List<Object> get props => [error];
}