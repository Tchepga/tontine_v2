import 'enum/currency.dart';
import 'member.dart';

class MemberShare {
  final int memberId;
  final String? memberName;
  final double share;
  final Member? member;

  MemberShare({
    required this.memberId,
    this.memberName,
    required this.share,
    this.member,
  });

  factory MemberShare.fromJson(Map<String, dynamic> json) {
    Member? member;
    if (json['member'] is Map) {
      member = Member.fromJson(
        Map<String, dynamic>.from(json['member'] as Map),
      );
    }

    final rawId = json['memberId'] ??
        json['member_id'] ??
        member?.id ??
        (json['member'] is num ? json['member'] : null);
    final memberId = rawId is int
        ? rawId
        : rawId is num
            ? rawId.toInt()
            : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final name = json['memberName']?.toString() ??
        json['member_name']?.toString() ??
        _memberDisplayName(member);

    final shareRaw = json['share'] ??
        json['shareAmount'] ??
        json['share_amount'] ??
        json['amount'] ??
        json['part'];
    final share = shareRaw is num
        ? shareRaw.toDouble()
        : double.tryParse(shareRaw?.toString() ?? '') ?? 0;

    return MemberShare(
      memberId: memberId,
      memberName: name,
      share: share,
      member: member,
    );
  }

  String get displayName {
    if (memberName != null && memberName!.trim().isNotEmpty) {
      return memberName!.trim();
    }
    return _memberDisplayName(member) ?? 'Membre #$memberId';
  }
}

String? _memberDisplayName(Member? member) {
  if (member == null) return null;
  final full =
      '${member.firstname ?? ''} ${member.lastname ?? ''}'.trim();
  if (full.isNotEmpty) return full;
  return member.user?.username;
}

class ClosureSummary {
  final double remainingBalance;
  final Currency currency;
  final List<MemberShare> memberShares;

  ClosureSummary({
    required this.remainingBalance,
    required this.currency,
    this.memberShares = const [],
  });

  factory ClosureSummary.fromJson(Map<String, dynamic> json) {
    final balanceRaw = json['remainingBalance'] ??
        json['remaining_balance'] ??
        json['reliquat'] ??
        json['balance'];
    final remainingBalance = balanceRaw is num
        ? balanceRaw.toDouble()
        : double.tryParse(balanceRaw?.toString() ?? '') ?? 0;

    final currencyRaw = json['currency'];
    final currency = currencyRaw != null
        ? Currency.values.firstWhere(
            (c) =>
                c.toString().split('.').last.toUpperCase() ==
                currencyRaw.toString().split('.').last.toUpperCase(),
            orElse: () => Currency.EUR,
          )
        : Currency.EUR;

    final sharesRaw = json['memberShares'] ??
        json['member_shares'] ??
        json['shares'] ??
        json['members'];
    final memberShares = sharesRaw is List
        ? sharesRaw
            .map((e) => MemberShare.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList()
        : <MemberShare>[];

    return ClosureSummary(
      remainingBalance: remainingBalance,
      currency: currency,
      memberShares: memberShares,
    );
  }
}
