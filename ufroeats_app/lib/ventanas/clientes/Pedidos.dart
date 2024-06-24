import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'Casino.dart';
import 'Favoritos.dart';
import 'Carrito.dart';
import 'Menu.dart';
import '../general/Login.dart';

class PedidosPage extends StatefulWidget {
  final int idUsuario;

  PedidosPage({required this.idUsuario});

  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Map<String, dynamic>> _pedidos = []; // Inicializa la lista vacía
  bool _isLoading = true; // Variable para manejar el estado de carga
  Map<int, String> _productNames =
      {}; // Mapa para almacenar nombres de productos

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  Future<void> _fetchPedidos() async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/pedido/usuario/${widget.idUsuario}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> pedidos =
          List<Map<String, dynamic>>.from(data['pedidos']);

      // Fetch product names
      for (var pedido in pedidos) {
        for (var idProducto in pedido['productos']) {
          if (!_productNames.containsKey(idProducto)) {
            await _fetchProductName(idProducto);
          }
        }
      }

      setState(() {
        _pedidos = pedidos;
        _isLoading = false; // Termina el estado de carga
      });
    } else {
      throw Exception('Failed to load pedidos');
    }
  }

  Future<void> _fetchProductName(int idProducto) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/producto/$idProducto'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String productName = data['producto']['nom_producto'];

      setState(() {
        _productNames[idProducto] = productName;
      });
    } else {
      throw Exception('Failed to load product name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extiende el cuerpo detrás de la AppBar
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_General.png', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Contenido principal
          Column(
            children: [
              SizedBox(height: 50), // Espacio para evitar la barra de estado
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pedidos por Retirar                   ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Espacio para evitar la barra de estado
              Expanded(
                child:
                    _isLoading // Muestra un indicador de carga si está cargando
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _pedidos.length,
                            itemBuilder: (context, index) {
                              final idPedido = _pedidos[index]['id_pedido'];
                              final productos = (_pedidos[index]['productos']
                                      as List<dynamic>)
                                  .map((e) => e as int)
                                  .toList();
                              final cantidades = (_pedidos[index]['cantidades']
                                      as List<dynamic>)
                                  .map((e) => e as int)
                                  .toList();
                              final total = _pedidos[index]['total'];

                              return Card(
                                margin: EdgeInsets.all(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // QR code on the left
                                      Expanded(
                                        flex: 1,
                                        child: QrImageView(
                                          data: idPedido.toString(),
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      // Order details on the right
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('ID de Pedido: $idPedido',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Productos:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                productos.length,
                                                (index) => Text(
                                                    '${_productNames[productos[index]] ?? 'Cargando...'} - Cantidad: ${cantidades[index]}'),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text('Total: $total',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
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
    );
  }
}
