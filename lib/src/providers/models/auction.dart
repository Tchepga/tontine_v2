import 'member.dart';
import 'enum/currency.dart';
import 'enum/auction_status.dart';

class Auction {
  final int id;
  final double amount;
  final Currency currency;
  final DateTime startDate;
  final DateTime endDate;
  final AuctionStatus status;
  final Member? winner;
  final double? winningBid;
  final List<AuctionBid> bids;
  final String? description;
  final DateTime creationDate;
  final Member createdBy;

  Auction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.winner,
    this.winningBid,
    required this.bids,
    this.description,
    required this.creationDate,
    required this.createdBy,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      currency: currencyFromString(json['currency']['name']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: auctionStatusFromString(json['status']),
      winner: json['winner'] != null ? Member.fromJson(json['winner']) : null,
      winningBid: json['winningBid'] != null
          ? (json['winningBid'] as num).toDouble()
          : null,
      bids: (json['bids'] as List<dynamic>?)
              ?.map((bid) => AuctionBid.fromJson(bid))
              .toList() ??
          [],
      description: json['description'],
      creationDate: DateTime.parse(json['creationDate']),
      createdBy: Member.fromJson(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': {'name': currency.name},
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.value,
      'winner': winner?.toJson(),
      'winningBid': winningBid,
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'description': description,
      'creationDate': creationDate.toIso8601String(),
      'createdBy': createdBy.toJson(),
    };
  }

  bool get isActive => status == AuctionStatus.ACTIVE;
  bool get isCompleted => status == AuctionStatus.COMPLETED;
  bool get isCancelled => status == AuctionStatus.CANCELLED;

  int get bidCount => bids.length;
  double get highestBid => bids.isNotEmpty
      ? bids.map((b) => b.amount).reduce((a, b) => a > b ? a : b)
      : 0.0;

  bool get hasBids => bids.isNotEmpty;
  bool get canBid => isActive && DateTime.now().isBefore(endDate);
}

class AuctionBid {
  final int id;
  final double amount;
  final Member bidder;
  final DateTime bidDate;
  final bool isWinning;

  AuctionBid({
    required this.id,
    required this.amount,
    required this.bidder,
    required this.bidDate,
    required this.isWinning,
  });

  factory AuctionBid.fromJson(Map<String, dynamic> json) {
    return AuctionBid(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      bidder: Member.fromJson(json['bidder']),
      bidDate: DateTime.parse(json['bidDate']),
      isWinning: json['isWinning'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'bidder': bidder.toJson(),
      'bidDate': bidDate.toIso8601String(),
      'isWinning': isWinning,
    };
  }
}
