/// Values of `profiles.role`.
enum UserRole {
  student,
  parent,
  teacher,
  admin;

  static UserRole? tryParse(String? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }
    return null;
  }
}

/// Minimal subset of the `profiles` row the app needs so far.
class Profile {
  const Profile({required this.id, required this.role});

  final String id;

  /// `null` when the row has no role or an unknown one.
  final UserRole? role;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    role: UserRole.tryParse(json['role'] as String?),
  );
}
