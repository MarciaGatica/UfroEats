// lib/models/usuario.dart
class Usuario {
  final int id;
  final String nombre;
  final String email;
  final bool isAdmin;
  final List<int> favoritos;

  Usuario(
      {required this.id,
      required this.nombre,
      required this.email,
      required this.isAdmin,
      required this.favoritos});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_usuario'],
      nombre: json['nom_usuario'],
      email: json['email'],
      isAdmin: json['isAdmin'],
      favoritos: List<int>.from(json['favoritos']),
    );
  }
}
