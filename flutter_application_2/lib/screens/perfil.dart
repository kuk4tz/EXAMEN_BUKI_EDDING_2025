import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/screens/buscar.dart';
import 'package:flutter_application_2/screens/medicamentos.dart';
import 'package:flutter_application_2/screens/notifs.dart';
import 'package:flutter_application_2/screens/recetas.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      // Cerrar sesión de Google y Firebase
      //await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navegar a la pantalla de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MedicamentosScreen()),
        (route) => false,
      );
    }
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.displayName ?? 'Usuario';
    }
    return 'Usuario';
  }

  String? _getUserPhotoUrl() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navegar al carrito
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Avatar del usuario
          Center(
            child: _getUserPhotoUrl() != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_getUserPhotoUrl()!),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D2D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Nombre de usuario
          Text(
            _getUserName(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 40),
          // Opciones del menú
          _buildMenuItem(
            context,
            'Información',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Información - Próximamente')),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Recetas',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecetasScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Historial de pedidos',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial - Próximamente')),
              );
            },
          ),
          _buildMenuItem(
            context,
            'Favoritos',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favoritos - Próximamente')),
              );
            },
          ),
          const Spacer(),
          // Botón de cerrar sesión
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      currentIndex: 3, // Perfil está seleccionado
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Notificaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BuscarScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MedicamentosScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
            );
            break;
          case 3:
            break;
        }
      },
    );
  }
}