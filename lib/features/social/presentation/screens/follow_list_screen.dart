// lib/features/social/presentation/screens/follow_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/follow_list_cubit.dart';
import '../widgets/follow_list_item_widget.dart';
import 'dart:developer' as developer;

class FollowListScreen extends StatefulWidget {
  final String userIdToList; // ID користувача, чий список ми переглядаємо
  final FollowListType listType; // Тип списку: followers або following

  const FollowListScreen({
    super.key,
    required this.userIdToList,
    required this.listType,
  });

  static Route route({required String userId, required FollowListType type}) {
    return MaterialPageRoute(
      builder: (_) => FollowListScreen(userIdToList: userId, listType: type),
    );
  }

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) { // Завантажувати, коли до кінця списку < 200px
      context.read<FollowListCubit>().fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.listType == FollowListType.followers ? 'Followers' : 'Following';

    return BlocProvider(
      create: (context) => FollowListCubit(
        RepositoryProvider.of<UserProfileRepository>(context),
        widget.userIdToList,
        widget.listType,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: BlocBuilder<FollowListCubit, FollowListState>(
          builder: (context, state) {
            if (state is FollowListInitial || (state is FollowListLoading && state.isInitialLoad)) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FollowListError) {
              return Center(
                 child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<FollowListCubit>().fetchInitialList(),
                        child: const Text('Try Again'),
                      )
                    ],
                  ),
                )
              );
            }
            if (state is FollowListLoaded || (state is FollowListLoading && !state.isInitialLoad)) {
              final profiles = (state is FollowListLoaded) ? state.profiles : (state as FollowListLoading).currentProfiles;
              final hasMore = (state is FollowListLoaded) ? state.hasMore : true; // Assume hasMore while loading more

              if (profiles.isEmpty && !(state is FollowListLoading && !state.isInitialLoad)) {
                return Center(
                  child: Text(
                    widget.listType == FollowListType.followers
                        ? 'This user has no followers yet.'
                        : 'This user is not following anyone yet.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<FollowListCubit>().fetchInitialList(),
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: profiles.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == profiles.length && hasMore) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2.5)));
                    }
                    if (index >= profiles.length) return const SizedBox.shrink();
                    return FollowListItemWidget(userProfile: profiles[index]);
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                ),
              );
            }
            return const Center(child: Text("Something went wrong."));
          },
        ),
      ),
    );
  }
}