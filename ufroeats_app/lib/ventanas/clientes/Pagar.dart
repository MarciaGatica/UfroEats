import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa la librería http

import 'Menu.dart';
import 'Casino.dart';
import 'Favoritos.dart';
import 'Carrito.dart';
import 'Pedidos.dart';
import '../general/Login.dart';

class PagarPage extends StatefulWidget {
  final int idUsuario;
  final int idPedido;
  final int totalPedido;

  PagarPage({
    required this.idUsuario,
    required this.idPedido,
    required this.totalPedido,
  });

  @override
  _PagarPageState createState() => _PagarPageState();
}

class _PagarPageState extends State<PagarPage> {
  String? _selectedPaymentMethod;
  TextEditingController _rutController = TextEditingController();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _dynamicKeyController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _rutController.addListener(_validateForm);
    _cardNumberController.addListener(_validateForm);
    _expiryDateController.addListener(_validateForm);
    _cvvController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _dynamicKeyController.addListener(_validateForm);
  }

  void _validateForm() {
    bool isValid = false;

    if (_selectedPaymentMethod == 'Credito' ||
        _selectedPaymentMethod == 'Debito') {
      isValid = _rutController.text.isNotEmpty &&
          _cardNumberController.text.isNotEmpty &&
          _expiryDateController.text.isNotEmpty &&
          _cvvController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    } else if (_selectedPaymentMethod == 'BAES') {
      isValid = _rutController.text.isNotEmpty &&
          _dynamicKeyController.text.isNotEmpty;
    }

    setState(() {
      _isButtonEnabled = isValid;
    });
  }

  Future<void> _realizarPago() async {
    final url =
        Uri.parse('http://10.0.2.2:3000/pedido/${widget.idPedido}/pagar');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
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
                    'Pago realizado con éxito',
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PedidosPage(idUsuario: widget.idUsuario),
          ),
        );
      } else {
        throw Exception('Error en la solicitud');
      }
    } catch (error) {
      print('Error: $error');
    }
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Stack(
            children: [
              // Fondo con imagen
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/Fondo_General.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Contenido del formulario
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.0),
                    Text(
                      'Portal de pagos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Bienvenid@',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Total a pagar: \$${widget.totalPedido.toString()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Container(
                          width: 40.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Seleccione Medio de Pago',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Container(),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.purple),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedPaymentMethod,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedPaymentMethod = newValue;
                                  _validateForm();
                                });
                              },
                              items: <String>[
                                'Credito',
                                'Debito',
                                'BAES',
                              ].map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    if (_selectedPaymentMethod == 'Credito' ||
                        _selectedPaymentMethod == 'Debito') ...[
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Ingrese RUT',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _rutController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'RUT',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Ingrese número de tarjeta',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Número de tarjeta',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Fecha de vencimiento y CVV',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryDateController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'MM/AA',
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'CVV',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Ingrese su clave',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Clave',
                        ),
                      ),
                    ],
                    if (_selectedPaymentMethod == 'BAES') ...[
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Ingrese RUT',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _rutController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'RUT',
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: [
                          Container(
                            width: 40.0,
                            child: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            'Ingrese la clave dinámica',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: _dynamicKeyController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Clave dinámica',
                        ),
                      ),
                    ],
                    SizedBox(height: 40.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _realizarPago : null,
                        style: ElevatedButton.styleFrom(
                          primary:
                              _isButtonEnabled ? Colors.purple : Colors.grey,
                          textStyle: TextStyle(fontSize: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Pagar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
