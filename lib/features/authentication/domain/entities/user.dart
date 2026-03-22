class User {
  final int id;
  final String fullName;
  final String? email;
  final String? picture;
  final String? tel;

  const User({
    required this.id,
    required this.fullName,
    this.email,
    this.picture,
    this.tel
 });
}