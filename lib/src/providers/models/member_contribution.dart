/// Résumé des cotisations d'un membre dans une tontine.
class MemberContribution {
  final int memberId;
  final String firstname;
  final String lastname;
  final String username;
  final double totalApproved;
  final double totalPending;
  final double totalRejected;
  final int depositCount;
  final DateTime? lastDeposit;

  MemberContribution({
    required this.memberId,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.totalApproved,
    required this.totalPending,
    required this.totalRejected,
    required this.depositCount,
    this.lastDeposit,
  });

  factory MemberContribution.fromJson(Map<String, dynamic> json) {
    return MemberContribution(
      memberId: json['memberId'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      username: json['username'] ?? '',
      totalApproved: (json['totalApproved'] as num).toDouble(),
      totalPending: (json['totalPending'] as num).toDouble(),
      totalRejected: (json['totalRejected'] as num).toDouble(),
      depositCount: json['depositCount'] ?? 0,
      lastDeposit: json['lastDeposit'] != null
          ? DateTime.parse(json['lastDeposit'])
          : null,
    );
  }

  String get fullName => '$firstname $lastname'.trim();
}
