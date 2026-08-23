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
  final double sharePercent;
  final double shareAmount;

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
    this.sharePercent = 0,
    this.shareAmount = 0,
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
      sharePercent: (json['sharePercent'] as num?)?.toDouble() ?? 0,
      shareAmount: (json['shareAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  String get fullName => '$firstname $lastname'.trim();

  String get displayName {
    final name = fullName;
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return 'Membre #$memberId';
  }
}
