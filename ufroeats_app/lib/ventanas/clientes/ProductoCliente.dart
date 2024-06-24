import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Menu.dart';
import 'Casino.dart';
import 'Favoritos.dart';
import 'Carrito.dart';
import 'Pedidos.dart';
import '../general/Login.dart';

class ProductoClientePage extends StatefulWidget {
  final int idUsuario;
  final int idProducto;
  final int idCasino;

  ProductoClientePage(
      {required this.idUsuario,
      required this.idProducto,
      required this.idCasino});

  @override
  _ProductoClientePageState createState() => _ProductoClientePageState();
}

class _ProductoClientePageState extends State<ProductoClientePage> {
  late Future<Map<String, dynamic>> productoFuture;
  late Future<Map<String, dynamic>> usuarioFuture;

  @override
  void initState() {
    super.initState();
    productoFuture = fetchProducto();
    usuarioFuture = fetchUsuario();
  }

  Future<Map<String, dynamic>> fetchProducto() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/producto/${widget.idProducto}'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['producto'];
    } else {
      throw Exception('Failed to load producto');
    }
  }

  Future<Map<String, dynamic>> fetchUsuario() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['usuario'];
    } else {
      throw Exception('Failed to load usuario');
    }
  }

  Future<void> toggleFavorite(bool isFavorite) async {
    final url =
        Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}/favoritos');
    final response = isFavorite
        ? await http.delete(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'productoId': widget.idProducto}),
          )
        : await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'productoId': widget.idProducto}),
          );

    if (response.statusCode == 200) {
      setState(() {
        if (isFavorite) {
          usuarioFuture =
              fetchUsuario(); // Refresh user data to reflect changes
        } else {
          usuarioFuture =
              fetchUsuario(); // Refresh user data to reflect changes
        }
      });
    } else {
      throw Exception('Failed to toggle favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: Future.wait([productoFuture, usuarioFuture]).then((result) => {
              'producto': result[0],
              'usuario': result[1],
            }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('No data found'),
            );
          } else {
            var producto = snapshot.data!['producto'];
            var usuario = snapshot.data!['usuario'];
            bool isFavorite = usuario['favoritos'].contains(widget.idProducto);

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Fondo_General.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Image.network(
                        'http://10.0.2.2:3000/uploads/${producto['imagen']}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, -3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          producto['nom_producto'],
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '\$${producto['precio']}',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Productos disponibles: ${producto['stock']}',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          producto['des_producto'],
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => toggleFavorite(isFavorite),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isFavorite ? Colors.red : Colors.white,
                                minimumSize:
                                    Size(80, 60), // tamaño mínimo del botón
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                side: BorderSide(
                                  color:
                                      isFavorite ? Colors.red : Colors.purple,
                                  width: 2, // grosor del borde
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.white : Colors.purple,
                                size: 32, // tamaño del ícono
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
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
                                        'productos': [widget.idProducto],
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
                                        'productos': [widget.idProducto],
                                        'cantidades': [1],
                                        'id_casino': widget
                                            .idCasino // Asegúrate de definir id_casino
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                minimumSize:
                                    Size(200, 60), // tamaño mínimo del botón
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 32, // tamaño del ícono
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'AGREGAR AL CARRITO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18, // tamaño del texto
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
