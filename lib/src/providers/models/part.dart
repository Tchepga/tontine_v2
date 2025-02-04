class Part {
  final int id;
  final int order;
  final DateTime? passageDate;
  final int memberId;
  final String memberName;
  final bool isPassed;
  final int tontineId;

  Part({
    required this.id,
    required this.order,
    this.passageDate,
    required this.memberId,
    required this.memberName,
    this.isPassed = false,
    required this.tontineId,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as int,
      order: json['order'] as int,
      passageDate: json['passageDate'] != null 
          ? DateTime.parse(json['passageDate'] as String)
          : null,
      memberId: json['memberId'] as int,
      memberName: json['memberName'] as String,
      isPassed: json['isPassed'] as bool? ?? false,
      tontineId: json['tontineId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      if (passageDate != null) 'passageDate': passageDate!.toIso8601String(),
      'memberId': memberId,
      'memberName': memberName,
      'isPassed': isPassed,
      'tontineId': tontineId,
    };
  }
} 