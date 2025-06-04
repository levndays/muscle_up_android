// lib/features/social/presentation/cubit/create_post_state.dart
part of 'create_post_cubit.dart';

abstract class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => []; // Додаємо ? для Object, оскільки post може бути null
}

class CreatePostInitial extends CreatePostState {
  final Post? postToEdit; // Додаємо, щоб знати, чи є пост для редагування
  const CreatePostInitial({this.postToEdit});
  @override
  List<Object?> get props => [postToEdit];
}

class CreatePostLoading extends CreatePostState {
   final String? loadingMessage; // Опціональне повідомлення
   const CreatePostLoading({this.loadingMessage});
   @override
   List<Object?> get props => [loadingMessage];
}

class CreatePostSuccess extends CreatePostState {
  final Post post; // Збережений або оновлений пост
  final bool isUpdate; // Прапорець, що вказує, чи було це оновлення
  const CreatePostSuccess(this.post, {this.isUpdate = false});

  @override
  List<Object?> get props => [post, isUpdate];
}

class CreatePostFailure extends CreatePostState {
  final String error;
  const CreatePostFailure(this.error);

  @override
  List<Object?> get props => [error];
}