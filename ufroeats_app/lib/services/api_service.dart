// lib/services/api_service.dart
/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:3000'; // Cambia 'PORT' por el puerto de tu API

  Future<Usuario?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'clave': password,
      }),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body)['usuario']);
    } else {
      return null;
    }
  }
}*/
