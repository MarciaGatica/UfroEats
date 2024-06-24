import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Registro.dart'; // Asegúrate de importar la página de registro
import '../trabajadores/CatalogoTrabajadore.dart'; // Importar la página de catálogo de trabajadores
import '../clientes/Casino.dart'; // Importar la página de casino

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/usuario/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'clave': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final bool isAdmin = responseData['usuario']['isAdmin'];
        final int userId = responseData['usuario']['id_usuario'];

        setState(() {
          _isLoading = false; // Ocultar el indicador de carga
        });

        if (isAdmin) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatalogoTrabajadoresPage(idUsuario: userId),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CasinoPage(idUsuario: userId),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false; // Ocultar el indicador de carga
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Error al iniciar sesión. Por favor, revisa tus credenciales.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Ocultar el indicador de carga
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error de Conexión'),
            content: Text(
                'No se pudo conectar con el servidor. Asegúrate de que el servidor esté en ejecución y accesible.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/Login_fondo.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 230),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 65, // Ajusta la altura del botón
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 29, 137, 187)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                18, // Ajusta el tamaño de la letra según tu preferencia
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 65, // Ajusta la altura del botón
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistroPage()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:
                              18, // Ajusta el tamaño de la letra según tu preferencia
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
