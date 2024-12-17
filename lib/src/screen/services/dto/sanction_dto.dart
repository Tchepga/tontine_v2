enum TypeSanction {
  FINANCIAL,
  SUSPENSION,
  WARNING,
  EXCLUSION
}

class CreateSanctionDto {
  final TypeSanction type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int memberId;

  CreateSanctionDto({
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    required this.memberId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'description': description,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'memberId': memberId,
    };
  }
} 