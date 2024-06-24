import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Casino.dart';
import 'Pedidos.dart';
import 'Carrito.dart';
import 'Menu.dart';
import '../general/Login.dart';

class FavoritosPage extends StatefulWidget {
  final int idUsuario;

  FavoritosPage({required this.idUsuario});

  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<Map<String, dynamic>> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritos();
  }

  Future<void> _fetchFavoritos() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<int> favoritos = List<int>.from(data['usuario']['favoritos']);

      List<Map<String, dynamic>> favoritosData = [];
      for (int idProducto in favoritos) {
        final productoResponse = await http
            .get(Uri.parse('http://10.0.2.2:3000/producto/$idProducto'));
        if (productoResponse.statusCode == 200) {
          final Map<String, dynamic> productoData =
              json.decode(productoResponse.body);
          favoritosData.add(productoData['producto']);
        }
      }

      setState(() {
        _favoritos = favoritosData;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load favoritos');
    }
  }

  Future<void> _eliminarProductoDeFavoritos(int idProducto) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}/favoritos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productoId': idProducto}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _favoritos
            .removeWhere((producto) => producto['id_producto'] == idProducto);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto eliminado de favoritos'),
        ),
      );
    } else {
      throw Exception('Failed to delete favorite product');
    }
  }

  Widget _buildProductoCard(Map<String, dynamic> producto) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 10, horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.blue[50], // Fondo azul claro
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen a la izquierda ocupando el 40% del ancho
              Expanded(
                flex: 4, // Modifica el tamaño de la imagen
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Image.network(
                    'http://10.0.2.2:3000/uploads/${producto['imagen']}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 150, // Tamaño fijo de la imagen
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Contenido del producto en el otro 60% del ancho
              Expanded(
                flex: 5, // Modifica el tamaño del contenido
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        producto['nom_producto'],
                        style: TextStyle(
                          fontSize:
                              23, // Modifica el tamaño del nombre del producto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '\$${producto['precio']}',
                        style: TextStyle(
                          fontSize: 25, // Modifica el tamaño del precio
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () async {
                                await _eliminarProductoDeFavoritos(
                                    producto['id_producto']);
                              },
                            ),
                          ),
                          SizedBox(width: 35),
                          Container(
                            width: 80,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 156, 39, 176),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () async {
                                // Lógica para añadir al carrito

                                // Verificar si hay un pedido no pagado para el usuario
                                final pedidoResponse = await http.get(Uri.parse(
                                    'http://10.0.2.2:3000/pedido/usuario/${widget.idUsuario}/no_pagados'));
                                if (pedidoResponse.statusCode == 200) {
                                  // Obtener los pedidos no pagados
                                  final pedidosData = json
                                      .decode(pedidoResponse.body)['pedidos'];

                                  if (pedidosData.isNotEmpty) {
                                    // Si hay pedidos no pagados, tomar el primero (asumiendo que solo debe haber uno)
                                    final pedidoId =
                                        pedidosData[0]['id_pedido'];

                                    // Agregar el producto al pedido existente
                                    final agregarProductoUrl = Uri.parse(
                                        'http://10.0.2.2:3000/pedido/$pedidoId/agregar');
                                    final agregarProductoResponse =
                                        await http.put(
                                      agregarProductoUrl,
                                      headers: {
                                        'Content-Type': 'application/json'
                                      },
                                      body: jsonEncode({
                                        'productos': [producto['id_producto']],
                                        'cantidades': [1]
                                      }),
                                    );

                                    if (agregarProductoResponse.statusCode ==
                                        200) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Producto agregado al carrito',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                      // Producto agregado exitosamente al pedido existente
                                      // Aquí puedes agregar cualquier lógica adicional
                                    } else {
                                      throw Exception(
                                          'Failed to add product to existing order');
                                    }
                                  } else {
                                    // No existe un pedido no pagado, crear un nuevo pedido
                                    final nuevoPedidoUrl = Uri.parse(
                                        'http://10.0.2.2:3000/pedido/');
                                    final nuevoPedidoResponse = await http.post(
                                      nuevoPedidoUrl,
                                      headers: {
                                        'Content-Type': 'application/json'
                                      },
                                      body: jsonEncode({
                                        'id_usuario': widget.idUsuario,
                                        'productos': [producto['id_producto']],
                                        'cantidades': [1],
                                        'id_casino':
                                            1 // Asegúrate de definir id_casino
                                      }),
                                    );

                                    if (nuevoPedidoResponse.statusCode == 201) {
                                      // Analizar la respuesta JSON para obtener los datos del pedido creado
                                      final nuevoPedidoData = json.decode(
                                          nuevoPedidoResponse.body)['pedido'];

                                      if (nuevoPedidoData != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Producto agregado al carrito',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        // El pedido se creó correctamente, puedes agregar lógica adicional aquí si es necesario
                                      } else {
                                        // La respuesta no contiene los datos esperados del nuevo pedido
                                        throw Exception(
                                            'Error: Response data is missing for new order');
                                      }
                                    } else {
                                      // El servidor respondió con un código de estado diferente a 200
                                      throw Exception(
                                          'Failed to create new order: ${nuevoPedidoResponse.statusCode}');
                                    }
                                  }
                                } else {
                                  throw Exception(
                                      'Failed to fetch unpaid orders for user');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Fondo de la pantalla
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/Fondo_General.png'), // Cambia la ruta por la imagen que quieras usar como fondo
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Contenido de la pantalla
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 60, 0, 0),
                      child: Row(
                        children: [
                          Text(
                            "Mis Favoritos",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.favorite, color: Colors.red, size: 40),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _favoritos.length,
                        itemBuilder: (context, index) {
                          return _buildProductoCard(_favoritos[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3, // Establece el índice seleccionado
        onTap: (index) {
          // Maneja la navegación del menú inferior aquí
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CasinoPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CarritoPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PedidosPage(idUsuario: widget.idUsuario),
                ),
              );
              break;
            case 3:
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
}
