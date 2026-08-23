class RestartTontineDto {
  final String? name;
  final bool? carryOverCash;

  RestartTontineDto({
    this.name,
    this.carryOverCash,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (carryOverCash != null) 'carryOverCash': carryOverCash,
    };
  }
}
