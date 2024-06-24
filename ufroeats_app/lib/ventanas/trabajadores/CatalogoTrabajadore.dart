import 'package:flutter/material.dart';
import 'MenuTrabajador.dart';
import 'Pedidos.dart';
import 'Qr.dart';
import '../general/Login.dart';

class CatalogoTrabajadoresPage extends StatelessWidget {
  final int idUsuario;

  CatalogoTrabajadoresPage({required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Trabajadores'),
      ),
      bottomNavigationBar: MenuTrabajador(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRPage(idUsuario: idUsuario),
                ),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PedidosPage(idUsuario: idUsuario),
                ),
              );
              break;

            case 3:
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
      body: Center(
        child: Text('ID de Usuario: $idUsuario'),
      ),
    );
  }
}
