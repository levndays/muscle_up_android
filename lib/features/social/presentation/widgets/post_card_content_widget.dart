// lib/features/social/presentation/widgets/post_card_content_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../../core/domain/entities/post.dart';
import '../../../../core/domain/entities/vote_type.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import '../cubit/post_interaction_cubit.dart';
import 'vote_progress_bar_widget.dart';
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart'; // Import AppLocalizations

// NEW COLORS FOR RECORD CLAIM
const Color recordClaimBaseBlue = Color(0xFF067BC2);
const Color recordClaimLighterBlue = Color(0xFF4FA8D8);
const Color recordClaimDarkerBlue = Color(0xFF045C9B);

const Color recordVerifyColor = Color(0xFF0A8754);
const Color recordDisputeColor = Color(0xFFEF2917);


class PostCardContentWidget extends StatelessWidget {
  final Post post;
  final VoteType? currentUserVote;
  final bool isDetailedView;

  const PostCardContentWidget({
    super.key,
    required this.post,
    this.currentUserVote,
    this.isDetailedView = false,
  });

  Future<void> _addRoutineToMyRoutines(BuildContext context, Map<String, dynamic> routineSnapshot) async {
    final loc = AppLocalizations.of(context)!;
    final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.postCardRoutineSnackbarLoginToAdd), backgroundColor: Colors.red),
      );
      return;
    }
    final originalRoutineUserId = routineSnapshot['userId'];
    if (originalRoutineUserId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.postCardRoutineSnackbarAlreadyOwn), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      final routineRepository = RepositoryProvider.of<RoutineRepository>(context);
      await routineRepository.copyRoutineFromSnapshot(routineSnapshot, userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.postCardRoutineSnackbarAdded), backgroundColor: Colors.green),
        );
      }
    } catch (e, s) {
      developer.log('Error adding shared routine: $e', name: 'PostCardContentWidget', error: e, stackTrace: s);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.postCardRoutineSnackbarErrorAdd(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getRecordStatusText(RecordVerificationStatus? status, bool? isVerified, AppLocalizations loc) {
    if (isVerified == true) return loc.recordStatusVerified;
    if (isVerified == false) {
        if (status == RecordVerificationStatus.rejected) return loc.recordStatusRejected;
        if (status == RecordVerificationStatus.expired) return loc.recordStatusExpired;
    }
    if (status == RecordVerificationStatus.pending || status == null) return loc.recordStatusPending;
    if (status == RecordVerificationStatus.contested) return loc.recordStatusContested;
    return loc.recordStatusUnknown;
  }

  Color _getRecordStatusColor(RecordVerificationStatus? status, bool? isVerified, BuildContext context) {
    if (isVerified == true) return recordVerifyColor;
    if (isVerified == false) {
        if (status == RecordVerificationStatus.rejected) return recordDisputeColor;
        if (status == RecordVerificationStatus.expired) return recordDisputeColor.withOpacity(0.8);
    }
    switch (status) {
      case RecordVerificationStatus.pending: return Colors.yellow.shade700;
      case RecordVerificationStatus.verified: return recordVerifyColor;
      case RecordVerificationStatus.rejected: return recordDisputeColor;
      case RecordVerificationStatus.expired: return recordDisputeColor.withOpacity(0.8);
      case RecordVerificationStatus.contested: return Colors.orange.shade600;
      default: return Colors.yellow.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final currentAuthUserId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    final bool isAuthorOfPost = currentAuthUserId == post.userId;

    int verifyCount = 0;
    int disputeCount = 0;
    post.verificationVotes.forEach((_, voteStr) {
      if (voteStr == voteTypeToString(VoteType.verify)) verifyCount++;
      if (voteStr == voteTypeToString(VoteType.dispute)) disputeCount++;
    });

    final bool canVote = currentAuthUserId != null &&
                         !isAuthorOfPost &&
                         (post.recordVerificationStatus == RecordVerificationStatus.pending || post.recordVerificationStatus == null);


    if (post.type == PostType.routineShare && post.routineSnapshot != null) {
      final exerciseCount = (post.routineSnapshot!['exercises'] as List<dynamic>?)?.length ?? 0;
      final scheduledDaysString = (post.routineSnapshot!['scheduledDays'] as List<dynamic>?)?.join(', ').toUpperCase() ?? loc.postCardRoutineNoSchedule;

      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Container(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF7700), Color(0xFFFF0000)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text((post.routineSnapshot!['name'] as String?)?.toUpperCase() ?? 'UNNAMED ROUTINE', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, shadows: [const Shadow(color: Colors.black26, offset: Offset(1,1), blurRadius: 2)])),
              Text(loc.postCardRoutineShareTitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 6),
              Text(loc.postCardRoutineAuthorPrefix(post.authorUsername), style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(children: [
                    Text('$exerciseCount', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                    Text(exerciseCount == 1 ? loc.postCardRoutineExercisesLabel : loc.postCardRoutineExercisesLabelPlural, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(scheduledDaysString, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                    Text(loc.postCardRoutineScheduledDaysLabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              if (currentAuthUserId != null && !isAuthorOfPost)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addRoutineToMyRoutines(context, post.routineSnapshot!),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFED5D1A), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 3),
                    child: Text(loc.postCardRoutineButtonAddToList, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                  ),
                ),
              if (isAuthorOfPost) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(loc.postCardRoutineIsYours, style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, fontSize: 12))),
              if (!isAuthorOfPost && currentAuthUserId == null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(loc.postCardRoutineLoginToAdd, style: TextStyle(color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, fontSize: 12))),
              const SizedBox(height: 8), // Added padding at the bottom
            ],
          ),
        ),
      );
    } else if (post.type == PostType.recordClaim && post.recordDetails != null) {
      final String exerciseDisplayName = (post.recordDetails!['localizedExerciseNames'] is Map
          ? (Map<String, String>.from(post.recordDetails!['localizedExerciseNames'])[loc.localeName.split('_').first] ??
             Map<String, String>.from(post.recordDetails!['localizedExerciseNames'])['en'] ??
             post.recordDetails!['exerciseName'])
          : post.recordDetails!['exerciseName']) ?? loc.postCardRecordExerciseNameFallback;

      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [recordClaimLighterBlue, recordClaimBaseBlue, recordClaimDarkerBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: recordClaimBaseBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(exerciseDisplayName.toUpperCase(), style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, height: 1.1)),
                  Text(loc.postCardRecordClaimTitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, letterSpacing: 1)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(loc.postCardRoutineAuthorPrefix(post.authorUsername), style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getRecordStatusColor(post.recordVerificationStatus, post.isRecordVerified, context).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRecordStatusText(post.recordVerificationStatus, post.isRecordVerified, loc),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                    ),
                  ),
                ]),
              ]),
              const SizedBox(height: 12),
              Text(
                loc.postCardRecordRepsKgFormat(
                    post.recordDetails!['reps']?.toString() ?? loc.postCardRecordRepsFallback,
                    (post.recordDetails!['weightKg'] as num?)?.toStringAsFixed(1) ?? loc.postCardRecordWeightFallback
                ),
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)
              ),
              const SizedBox(height: 10),
              VoteProgressBarWidget(
                verifyCount: verifyCount,
                disputeCount: disputeCount,
                height: 22,
                verifyColor: recordVerifyColor,
                disputeColor: recordDisputeColor,
                backgroundColor: Colors.black.withOpacity(0.3),
                centerTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, shadows: [Shadow(color: Colors.black87, blurRadius: 2, offset: Offset(0,1))])
              ),
              if (post.recordDetails!['videoUrl'] != null && (post.recordDetails!['videoUrl'] as String).isNotEmpty)
                Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () { /* TODO: Launch URL */ }, icon: const Icon(Icons.play_circle_outline, color: Colors.white70, size: 20), label: Text(loc.postDetailButtonWatchProof, style: const TextStyle(color: Colors.white, fontSize: 13)), style: TextButton.styleFrom(padding: const EdgeInsets.only(left:0, top: 8, bottom: 4)))),
              if (isDetailedView && canVote)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(children: [
                    Expanded(child: ElevatedButton(onPressed: () => context.read<PostInteractionCubit>().castVote(VoteType.verify), style: ElevatedButton.styleFrom(backgroundColor: currentUserVote == VoteType.verify ? recordVerifyColor.withOpacity(0.7) : recordVerifyColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text(loc.postDetailButtonValidate, style: const TextStyle(fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () => context.read<PostInteractionCubit>().castVote(VoteType.dispute), style: ElevatedButton.styleFrom(backgroundColor: currentUserVote == VoteType.dispute ? recordDisputeColor.withOpacity(0.7) : recordDisputeColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: Text(loc.postDetailButtonDispute, style: const TextStyle(fontWeight: FontWeight.bold)))),
                  ]),
                )
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}