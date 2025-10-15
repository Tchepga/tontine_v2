enum AuctionStatus {
  ACTIVE,
  COMPLETED,
  CANCELLED,
}

extension AuctionStatusExtension on AuctionStatus {
  String get displayName {
    switch (this) {
      case AuctionStatus.ACTIVE:
        return 'En cours';
      case AuctionStatus.COMPLETED:
        return 'Terminée';
      case AuctionStatus.CANCELLED:
        return 'Annulée';
    }
  }

  String get value {
    switch (this) {
      case AuctionStatus.ACTIVE:
        return 'ACTIVE';
      case AuctionStatus.COMPLETED:
        return 'COMPLETED';
      case AuctionStatus.CANCELLED:
        return 'CANCELLED';
    }
  }
}

AuctionStatus auctionStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'ACTIVE':
      return AuctionStatus.ACTIVE;
    case 'COMPLETED':
      return AuctionStatus.COMPLETED;
    case 'CANCELLED':
      return AuctionStatus.CANCELLED;
    default:
      return AuctionStatus.ACTIVE;
  }
}
