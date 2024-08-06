class ClassModel {
  final String id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      name: data['classname'] ?? 'Unknown Class',
    );
  }
}
