class LecturerModel {
  final String id;
  final String name;

  LecturerModel({required this.id, required this.name});

  factory LecturerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LecturerModel(
      id: id,
      name: data['username'] ?? 'Unknown Lecturer',
    );
  }
}
