import 'package:flutter/material.dart';
import 'package:ufroeats_app/ventanas/general/Login.dart'; // Importa el archivo que contiene la pantalla de inicio de sesión

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ocultar la etiqueta de "debug"
      title: 'Mi Aplicación',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home:
          LoginPage(), // Define la pantalla de inicio de sesión como la pantalla principal
    );
  }
}
