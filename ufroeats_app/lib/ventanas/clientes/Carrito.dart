import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Menu.dart';
import 'Casino.dart';
import 'Favoritos.dart';
import 'Pedidos.dart';
import 'Pagar.dart';
import '../general/Login.dart';

class CarritoPage extends StatefulWidget {
  final int idUsuario;

  CarritoPage({required this.idUsuario});

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  List<Map<String, dynamic>> pedidos = [];
  int totalPedido = 0;
  int idd = 0;
  @override
  void initState() {
    super.initState();
    _fetchPedidosNoPagados();
  }

  Future<void> _fetchPedidosNoPagados() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:3000/pedido/usuario/${widget.idUsuario}/no_pagados'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<Map<String, dynamic>> pedidosData =
          List<Map<String, dynamic>>.from(data['pedidos']);

      if (pedidosData.isNotEmpty) {
        setState(() {
          pedidos = pedidosData;
          totalPedido = pedidosData[0]['total']; // Total del primer pedido
          idd = pedidosData[0]['id_pedido'];
        });
      } else {
        setState(() {
          pedidos = [];
          totalPedido = 0; // No hay pedidos, el total es 0
        });
      }
    } else {
      throw Exception('Failed to load pedidos');
    }
  }

  Future<Map<String, dynamic>> _fetchPedido(int idPedido) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/pedido/$idPedido'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['pedido'];
    } else {
      throw Exception('Failed to load pedido $idPedido');
    }
  }

  Future<Map<String, dynamic>> _fetchProducto(int idProducto) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/producto/$idProducto'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['producto'];
    } else {
      throw Exception('Failed to load producto $idProducto');
    }
  }

  Future<void> _agregarProducto(int idPedido, int idProducto) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/pedido/$idPedido/agregar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productos': [idProducto],
        'cantidades': [1],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product to pedido');
    }
  }

  Future<void> _disminuirProducto(int idPedido, int idProducto) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/pedido/$idPedido/disminuir'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_producto': idProducto,
        'cantidad': 1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to decrease product quantity in pedido');
    }
  }

  Future<void> _eliminarProducto(int idPedido, int idProducto) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/pedido/$idPedido/eliminar/$idProducto'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove product from pedido');
    }
  }

  Widget _buildProductoCard(
      Map<String, dynamic> producto, Map<String, dynamic> pedido) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4, // Opacidad
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        height: 150.0, // Ajusta la altura de la tarjeta
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                'http://10.0.2.2:3000/uploads/${producto['imagen']}',
                fit: BoxFit.cover,
                height: 150.0, // Ajusta la altura de la imagen
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    producto['nom_producto'],
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Precio: \$${producto['precio']}',
                    style: TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 22.0),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue, // Fondo celeste
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.remove,
                              color: Colors.white), // Icono blanco
                          onPressed: () async {
                            await _disminuirProducto(
                              pedido['id_pedido'],
                              producto['id_producto'],
                            );
                            _fetchPedidosNoPagados();
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Colors.lightBlue[50], // Fondo celeste muy claro
                          borderRadius:
                              BorderRadius.circular(8.0), // Bordes redondeados
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '${pedido['cantidades'][(pedido['productos'] as List).indexOf(producto['id_producto'])]}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22.0), // Texto negro
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue, // Fondo celeste
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add,
                              color: Colors.white), // Icono blanco
                          onPressed: () async {
                            await _agregarProducto(
                              pedido['id_pedido'],
                              producto['id_producto'],
                            );
                            _fetchPedidosNoPagados();
                          },
                        ),
                      ),
                      SizedBox(width: 35),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red, // Fondo rojo
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete,
                              color: const Color.fromARGB(
                                  255, 255, 255, 255)), // Icono blanco
                          onPressed: () async {
                            await _eliminarProducto(
                              pedido['id_pedido'],
                              producto['id_producto'],
                            );
                            _fetchPedidosNoPagados();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
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
      body: Stack(
        children: [
          // Fondo con imagen
          Image.asset(
            'assets/Fondo_General.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Contenido de la página
          Center(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: _fetchPedido(pedidos[index]['id_pedido']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            final pedido =
                                snapshot.data as Map<String, dynamic>;
                            return Column(
                              children: [
                                SizedBox(height: 30),
                                Text(
                                  'Carrito',
                                  textAlign: TextAlign
                                      .left, // Alineación a la izquierda
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Negrita
                                    fontSize:
                                        30.0, // Tamaño de fuente más grande
                                  ),
                                ),
                                SizedBox(height: 30),
                                FutureBuilder(
                                  future: Future.wait(
                                    (pedido['productos'] as List<dynamic>)
                                        .map((idProducto) =>
                                            _fetchProducto(idProducto))
                                        .toList(),
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else {
                                      final productos = snapshot.data
                                          as List<Map<String, dynamic>>;
                                      return Column(
                                        children: productos.map((producto) {
                                          return _buildProductoCard(
                                              producto, pedido);
                                        }).toList(),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                // Aquí se muestra el total del pedido y el botón para pagar
                Container(
                  padding: EdgeInsets.all(16.0),
                  height: 200.0, // Altura más grande
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 255, 255, 255), // Color morado
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '    Total del Pedido:                        \$${totalPedido.toString()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0, // Letra más grande
                          color: Colors.black, // Color blanco
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PagarPage(
                                idUsuario: widget.idUsuario,
                                idPedido: idd,
                                totalPedido: totalPedido,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0), // Ajuste de altura y ancho
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Bordes redondeados
                          ),
                          primary: Colors.purple, // Color del botón
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons
                                .credit_card), // Icono de tarjeta de crédito
                            SizedBox(
                                width:
                                    8.0), // Espaciado entre el icono y el texto
                            Text(
                              'Pagar',
                              style: TextStyle(
                                fontSize: 18.0, // Letra más grande
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
