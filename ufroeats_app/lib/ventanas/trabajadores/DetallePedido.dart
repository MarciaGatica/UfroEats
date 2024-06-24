import 'package:flutter/material.dart';

class DetallePedido extends StatelessWidget {
  final int idUsuario;
  final String idPedido;

  DetallePedido({required this.idUsuario, required this.idPedido});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Pedido'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ID Usuario: $idUsuario'),
            Text('ID Pedido: $idPedido'),
          ],
        ),
      ),
    );
  }
}
