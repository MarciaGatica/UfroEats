import 'package:flutter/material.dart';
import 'MenuTrabajador.dart'; // Importa el menú
import 'Qr.dart';
import 'CatalogoTrabajadore.dart';
import '../general/Login.dart';

class PedidosPage extends StatelessWidget {
  final int idUsuario;

  PedidosPage({
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      bottomNavigationBar: MenuTrabajador(
        currentIndex: 2,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CatalogoTrabajadoresPage(idUsuario: idUsuario),
                ),
              );
              break;
            case 2:
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
        child: Text('Página de Pedidos del Usuario $idUsuario'),
      ),
    );
  }
}
