import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CatalogoClientes.dart'; // Importar la página de catálogo de cliente
import 'Menu.dart'; // Importa el widget de menú inferior personalizado
import 'Carrito.dart';
import 'Favoritos.dart';
import 'Pedidos.dart';
import '../general/Login.dart';

class CasinoPage extends StatefulWidget {
  final int idUsuario;

  CasinoPage({required this.idUsuario});

  @override
  _CasinoPageState createState() => _CasinoPageState();
}

class _CasinoPageState extends State<CasinoPage> {
  late Future<Map<String, dynamic>?> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _fetchUserInfo();
  }

  Future<Map<String, dynamic>?> _fetchUserInfo() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Fondo_Casino.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder(
                future: _userInfoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return Text('Error: Failed to load user information');
                  } else {
                    final usuario = snapshot.data!['usuario'];
                    final nombreUsuario = usuario['nom_usuario'];
                    return Column(
                      children: [
                        SizedBox(height: 130),
                        Text(
                          'Hola $nombreUsuario :)',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 60),
                        Text(
                          '¿En qué casino deseas pedir?',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildCasinoCard(
                          'Casino Las Araucaria',
                          'assets/araucarias.jpeg', // Ruta de la imagen del casino 1
                          1, // ID del primer casino
                        ),
                        SizedBox(height: 20),
                        _buildCasinoCard(
                          'Casino Los Notros',
                          'assets/notros.jpeg', // Ruta de la imagen del casino 2
                          2, // ID del segundo casino
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Establece el índice seleccionado
        onTap: (index) {
          // Maneja la navegación del menú inferior aquí
          // Maneja la navegación del menú inferior aquí
          switch (index) {
            case 0:
              // No hace nada si ya estamos en la página de inicio (CasinoPage)
              break;
            case 1:
              // Navega a la página de carrito
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CarritoPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 2:
              // Navega a la página de pedidos (anteriormente UsuarioPage)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PedidosPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 3:
              // Navega a la página de favoritos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritosPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildCasinoCard(String casinoName, String imagePath, int idCasino) {
    Color customPurpleColor = Color.fromRGBO(226, 203, 255, 1);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CatalogoClientePage(
              idUsuario: widget.idUsuario,
              idCasino: idCasino,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.95, // Ancho de la tarjeta ajustado al 90% del ancho de la pantalla
        height: MediaQuery.of(context).size.height *
            0.13, // Altura de la tarjeta ajustada al 13% del alto de la pantalla
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width *
                  0.45, // Ancho de la imagen ajustado al 40% del ancho de la tarjeta
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: Image.asset(
                  imagePath, // Ruta de la imagen del casino
                  fit: BoxFit
                      .cover, // La imagen se ajusta al tamaño de la tarjeta
                ),
              ),
            ),
            SizedBox(width: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        casinoName,
                        style: TextStyle(fontSize: 25, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: customPurpleColor, // Usar el color personalizado
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CatalogoClientePage(
                                idUsuario: widget.idUsuario,
                                idCasino: idCasino,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20)
          ],
        ),
      ),
    );
  }
}
