import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Menu.dart';
import 'Casino.dart';
import 'Favoritos.dart';
import 'Carrito.dart';
import 'Pedidos.dart';
import 'ProductoCliente.dart';
import '../general/Login.dart';

class CatalogoClientePage extends StatefulWidget {
  final int idUsuario;
  final int idCasino;
  bool esFavorito = false; // Define esta variable en tu StatefulWidget

  CatalogoClientePage({required this.idUsuario, required this.idCasino});

  @override
  _CatalogoClientePageState createState() => _CatalogoClientePageState();
}

class _CatalogoClientePageState extends State<CatalogoClientePage> {
  late Future<List<dynamic>> _productosFuture;
  late Future<List<dynamic>> _categoriasFuture;
  late Map<String, dynamic> _userData = {};
  String _nombreCasino = '';
  String _selectedCategory = "";
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productosFuture = _fetchProductos();
    _categoriasFuture = _fetchCategorias();
    _nombreCasino =
        (widget.idCasino == 1) ? 'Casino Las Araucarias' : 'Casino Los Notros';
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _userData =
          {}; // Puedes establecer _userData como null mientras esperas los datos
    });
    try {
      final userData = await _fetchUsuario();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      throw Exception('Failed to load producto');
    }
  }

  Future<Map<String, dynamic>> _fetchUsuario() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<bool> _isProductoEnFavoritos(int productoId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}/favoritos'),
    );

    if (response.statusCode == 200) {
      final favoritos = json.decode(response.body)['favoritos'];
      return favoritos.contains(productoId);
    } else {
      throw Exception('Failed to check if product is in favorites');
    }
  }

  Future<void> _agregarProductoAFavoritos(int productoId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}/favoritos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productoId': productoId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product to favorites');
    }
  }

  Future<void> _eliminarProductoDeFavoritos(int productoId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}/favoritos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productoId': productoId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove product from favorites');
    }
  }

  Future<List<dynamic>> _fetchProductos() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/producto/casino/${widget.idCasino}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productos = data['productos'];
      return productos;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<int>> _fetchFavoritosUsuario() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/usuario/${widget.idUsuario}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> favoritos = data['usuario']['favoritos'];
      return favoritos
          .cast<int>(); // Convertir los elementos de la lista a enteros
    } else {
      throw Exception('Failed to load user favorites');
    }
  }

  Future<List<dynamic>> _fetchCategorias() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/categoria/'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> categorias = data['categoria'];
      return categorias;
    } else {
      throw Exception('Failed to load categories');
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Fondo_General.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text(
                  _nombreCasino,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(
                        () {}); // Actualizar la interfaz cuando se cambie el texto de búsqueda
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    filled: true,
                    fillColor: Colors.white, // Color de fondo blanco
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Bordes redondeados
                      borderSide: BorderSide.none, // Sin bordes alrededor
                    ),
                    prefixIcon:
                        Icon(Icons.search), // Icono de lupa a la izquierda
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16), // Ajuste del contenido
                  ),
                ),
                SizedBox(height: 10),
                FutureBuilder(
                  future: _categoriasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      List<dynamic> categorias = snapshot.data as List<dynamic>;
                      return Wrap(
                        spacing: 8.0,
                        children: [
                          FilterChip(
                            label: Text(
                              'Todos',
                              style: TextStyle(
                                color: _selectedCategory.isEmpty
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.black,
                              ),
                            ),
                            selected: _selectedCategory.isEmpty,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = "";
                              });
                            },
                            selectedColor: _selectedCategory.isEmpty
                                ? Color.fromRGBO(226, 203, 255, 1)
                                : Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
                          ...categorias.map((categoria) {
                            return FilterChip(
                              label: Text(
                                categoria['des_categoria'],
                                style: TextStyle(
                                  color: _selectedCategory ==
                                          categoria['id_categoria'].toString()
                                      ? const Color.fromARGB(255, 0, 0,
                                          0) // Color del texto cuando la categoría está seleccionada
                                      : Colors
                                          .black, // Color del texto cuando la categoría no está seleccionada
                                ),
                              ),
                              selected: _selectedCategory ==
                                  categoria['id_categoria'].toString(),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory =
                                      categoria['id_categoria'].toString();
                                });
                              },
                              selectedColor: Color.fromRGBO(226, 203, 255,
                                  1), // Color del círculo cuando la categoría está seleccionada
                              backgroundColor: Colors
                                  .transparent, // Hace que el fondo del chip sea transparente para que solo se vea el círculo
                            );
                          }).toList(),
                        ],
                      );
                    }
                  },
                ),
                Expanded(
                  child: FutureBuilder(
                    future: _productosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        List<dynamic> productos =
                            snapshot.data as List<dynamic>;
                        if (_searchController.text.isNotEmpty) {
                          productos = productos
                              .where(
                                (producto) => producto['nom_producto']
                                    .toLowerCase()
                                    .contains(
                                      _searchController.text.toLowerCase(),
                                    ),
                              )
                              .toList();
                        }
                        if (_selectedCategory.isNotEmpty) {
                          productos = productos
                              .where((producto) =>
                                  producto['id_categoria'].toString() ==
                                  _selectedCategory)
                              .toList();
                        }
                        return ListView.builder(
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final producto = productos[index];
                            return _buildProductoCard(producto);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(Map<String, dynamic> producto) {
    return FutureBuilder(
      future: Future.wait([_categoriasFuture, _fetchFavoritosUsuario()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<dynamic> categorias = snapshot.data![0] as List<dynamic>;
          List<int> favoritos = snapshot.data![1] as List<int>;

          String categoria = "No hay categoría";
          var categoriaEncontrada = categorias.firstWhere(
            (cat) => cat['id_categoria'] == producto['id_categoria'],
            orElse: () => null,
          );
          if (categoriaEncontrada != null) {
            categoria = categoriaEncontrada['des_categoria'];
          }

          bool esFavorito = favoritos.contains(producto['id_producto']);

          return GestureDetector(
            onTap: () {
              // Redireccionar a la página ProductoCliente
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductoClientePage(
                    idUsuario: widget.idUsuario,
                    idProducto: producto['id_producto'],
                    idCasino: widget.idUsuario,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 10),
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
                                    20, // Modifica el tamaño del nombre del producto
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              categoria,
                              style: TextStyle(
                                fontSize:
                                    16, // Modifica el tamaño de la categoría
                                color: categoria == "No hay categoría"
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '\$${producto['precio']}',
                              style: TextStyle(
                                fontSize: 20, // Modifica el tamaño del precio
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 75,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      esFavorito
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.purple,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (esFavorito) {
                                          // Si es favorito, eliminar de favoritos
                                          await _eliminarProductoDeFavoritos(
                                              producto['id_producto']);
                                          setState(() {
                                            esFavorito =
                                                false; // Actualizar el estado
                                          });
                                        } else {
                                          // Si no es favorito, agregar a favoritos
                                          await _agregarProductoAFavoritos(
                                              producto['id_producto']);
                                          setState(() {
                                            esFavorito =
                                                true; // Actualizar el estado
                                          });
                                        }
                                      } catch (e) {
                                        // Manejar errores aquí
                                        print('Error: $e');
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                    width: 20), // Separación entre los botones
                                Container(
                                  width: 75, // Ancho deseado para los botones
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.purple, // Color morado
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.shopping_cart,
                                        color: Colors.white),
                                    onPressed: () async {
                                      // Lógica para añadir al carrito

                                      // Verificar si hay un pedido no pagado para el usuario
                                      final pedidoResponse = await http.get(
                                          Uri.parse(
                                              'http://10.0.2.2:3000/pedido/usuario/${widget.idUsuario}/no_pagados'));
                                      if (pedidoResponse.statusCode == 200) {
                                        // Obtener los pedidos no pagados
                                        final pedidosData = json.decode(
                                            pedidoResponse.body)['pedidos'];

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
                                              'productos': [
                                                producto['id_producto']
                                              ],
                                              'cantidades': [1]
                                            }),
                                          );

                                          if (agregarProductoResponse
                                                  .statusCode ==
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
                                          final nuevoPedidoResponse =
                                              await http.post(
                                            nuevoPedidoUrl,
                                            headers: {
                                              'Content-Type': 'application/json'
                                            },
                                            body: jsonEncode({
                                              'id_usuario': widget.idUsuario,
                                              'productos': [
                                                producto['id_producto']
                                              ],
                                              'cantidades': [1],
                                              'id_casino': widget
                                                  .idCasino // Asegúrate de definir id_casino
                                            }),
                                          );

                                          if (nuevoPedidoResponse.statusCode ==
                                              201) {
                                            // Analizar la respuesta JSON para obtener los datos del pedido creado
                                            final nuevoPedidoData = json.decode(
                                                nuevoPedidoResponse
                                                    .body)['pedido'];

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
      },
    );
  }
}
