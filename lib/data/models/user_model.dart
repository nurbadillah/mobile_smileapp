class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String roleCode;
  final String roleName;
  final int internalPositionId;
  final String internalPositionName;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleCode,
    required this.roleName,
    required this.internalPositionId,
    required this.internalPositionName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      roleCode: json['roleCode'] ?? '',
      roleName: json['roleName'] ?? '',
      internalPositionId: json['internalPositionId'] ?? 0,
      internalPositionName: json['internalPositionName'] ?? '',
    );
  }
}