// lib/features/social/presentation/cubit/follow_list_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import 'dart:developer' as developer;

part 'follow_list_state.dart';

class FollowListCubit extends Cubit<FollowListState> {
  final UserProfileRepository _userProfileRepository;
  final String _userIdToList; // User whose list we are fetching
  final FollowListType _listType;
  
  bool _isFetching = false;
  String? _lastFetchedDocumentId; // For pagination
  final int _limit = 20;

  FollowListCubit(
    this._userProfileRepository,
    this._userIdToList,
    this._listType,
  ) : super(FollowListInitial()) {
    fetchInitialList();
  }

  Future<void> fetchInitialList() async {
    if (_isFetching) return;
    _isFetching = true;
    emit(const FollowListLoading(isInitialLoad: true));
    _lastFetchedDocumentId = null; // Reset for initial load
    try {
      List<UserProfile> profiles;
      if (_listType == FollowListType.followers) {
        profiles = await _userProfileRepository.getFollowersList(_userIdToList, limit: _limit);
      } else {
        profiles = await _userProfileRepository.getFollowingList(_userIdToList, limit: _limit);
      }
      _lastFetchedDocumentId = profiles.isNotEmpty ? profiles.last.uid : null;
      emit(FollowListLoaded(profiles, hasMore: profiles.length >= _limit));
      developer.log("FollowListCubit: Initial list fetched. Type: ${_listType.name}, Count: ${profiles.length}", name: "FollowListCubit");
    } catch (e, s) {
      developer.log("Error fetching initial follow list: $e", name: "FollowListCubit", error: e, stackTrace: s);
      emit(FollowListError(e.toString().replaceFirst("Exception: ", "")));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchMore() async {
    if (_isFetching || !(state is FollowListLoaded && (state as FollowListLoaded).hasMore)) {
      return;
    }
    _isFetching = true;
    
    final currentState = state as FollowListLoaded;
    emit(FollowListLoading(currentProfiles: currentState.profiles, isInitialLoad: false));

    try {
      List<UserProfile> newProfiles;
      if (_listType == FollowListType.followers) {
        newProfiles = await _userProfileRepository.getFollowersList(
          _userIdToList,
          lastFetchedUserId: _lastFetchedDocumentId,
          limit: _limit,
        );
      } else {
        newProfiles = await _userProfileRepository.getFollowingList(
          _userIdToList,
          lastFetchedUserId: _lastFetchedDocumentId,
          limit: _limit,
        );
      }
      _lastFetchedDocumentId = newProfiles.isNotEmpty ? newProfiles.last.uid : null;
      final combinedProfiles = List<UserProfile>.from(currentState.profiles)..addAll(newProfiles);
      emit(FollowListLoaded(combinedProfiles, hasMore: newProfiles.length >= _limit));
       developer.log("FollowListCubit: Fetched more. Type: ${_listType.name}, New Count: ${newProfiles.length}, Total: ${combinedProfiles.length}", name: "FollowListCubit");
    } catch (e,s) {
      developer.log("Error fetching more follow list: $e", name: "FollowListCubit", error: e, stackTrace: s);
      emit(FollowListError(e.toString().replaceFirst("Exception: ", ""))); // Consider keeping old data on error for better UX
      // emit(FollowListLoaded(currentState.profiles, hasMore: currentState.hasMore)); // Or revert to previous loaded state
    } finally {
      _isFetching = false;
    }
  }
}