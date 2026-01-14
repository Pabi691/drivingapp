class Instructor {
  final String id;
  final String name;
  final String email;
  final String mobile;

  Instructor({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
    );
  }
}
