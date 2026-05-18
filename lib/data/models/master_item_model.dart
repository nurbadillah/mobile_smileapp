class MasterItemModel {
  final int id;
  final String name;
  final bool isActive;

  MasterItemModel({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory MasterItemModel.fromJson(
    Map<String, dynamic> json, {
    required String idKey,
    required String nameKey,
  }) {
    return MasterItemModel(
      id: json[idKey] ?? 0,
      name: json[nameKey] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}