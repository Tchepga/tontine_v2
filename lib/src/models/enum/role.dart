enum Role {
  PRESIDENT,
  ACCOUNT_MANAGER,
  OFFICE_MANAGER,
  TONTINARD,
  SECRETARY,
}

Role fromStringToRole(String role) {
  return Role.values.firstWhere((r) => r.toString().split('.').last == role);
}
