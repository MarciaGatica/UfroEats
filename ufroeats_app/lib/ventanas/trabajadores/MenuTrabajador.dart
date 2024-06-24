import 'package:flutter/material.dart';

class MenuTrabajador extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  MenuTrabajador({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      iconSize: 35, // Tamaño de los iconos
      selectedItemColor: Colors.black, // Color de los iconos seleccionados
      unselectedItemColor:
          Colors.black.withOpacity(0.5), // Color de los iconos no seleccionados
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Escaner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront),
          label: 'Catalogo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_mall),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.power_settings_new), // Icono de salir
          label: 'Salir',
        ),
      ],
    );
  }
}
