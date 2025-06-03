// lib/core/domain/entities/vote_type.dart
enum VoteType {
  verify,
  dispute,
}

// Helper to convert VoteType to string for Firestore
String voteTypeToString(VoteType voteType) => voteType.name;

// Helper to convert string from Firestore back to VoteType
VoteType? stringToVoteType(String? voteString) {
  if (voteString == null) return null;
  try {
    return VoteType.values.byName(voteString);
  } catch (_) {
    return null;
  }
}