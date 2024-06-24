import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
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
          icon: Icon(Icons.storefront),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.power_settings_new), // Icono de salir
          label: 'Salir',
        ),
      ],
    );
  }
}
