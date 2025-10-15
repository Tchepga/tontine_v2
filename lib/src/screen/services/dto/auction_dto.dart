import '../../../providers/models/enum/currency.dart';
import '../../../providers/models/enum/auction_status.dart';

class CreateAuctionDto {
  final double amount;
  final Currency currency;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final int tontineId;

  CreateAuctionDto({
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.tontineId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': {'name': currency.name},
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'tontineId': tontineId,
    };
  }
}

class UpdateAuctionDto {
  final double? amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final AuctionStatus? status;

  UpdateAuctionDto({
    this.amount,
    this.startDate,
    this.endDate,
    this.description,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (amount != null) data['amount'] = amount;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status!.value;

    return data;
  }
}

class CreateAuctionBidDto {
  final double amount;
  final int auctionId;
  final int memberId;

  CreateAuctionBidDto({
    required this.amount,
    required this.auctionId,
    required this.memberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'auctionId': auctionId,
      'memberId': memberId,
    };
  }
}

class AuctionFilterDto {
  final AuctionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final int? tontineId;

  AuctionFilterDto({
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.tontineId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (status != null) data['status'] = status!.value;
    if (startDate != null) data['startDate'] = startDate!.toIso8601String();
    if (endDate != null) data['endDate'] = endDate!.toIso8601String();
    if (minAmount != null) data['minAmount'] = minAmount;
    if (maxAmount != null) data['maxAmount'] = maxAmount;
    if (tontineId != null) data['tontineId'] = tontineId;

    return data;
  }
}
