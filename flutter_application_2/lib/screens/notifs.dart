import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/buscar.dart';
import 'package:flutter_application_2/screens/medicamentos.dart';
import 'package:flutter_application_2/screens/perfil.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              // Navegar al carrito
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateHeader('01 enero, 2025'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            image: 'assets/Ketorolaco-10mg-10c-1-Frontal.webp', // Reemplaza con tu imagen
            title: 'Promoción ítem',
            icon: Icons.local_offer,
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            image: 'assets/promo2.png',
            title: 'Promoción ítem',
            icon: Icons.local_offer,
          ),
          const SizedBox(height: 24),
          _buildDateHeader('01 ene, 2025'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            image: 'assets/stock.png',
            title: 'Llegó stock',
            icon: Icons.inventory_2,
          ),
          const SizedBox(height: 24),
          _buildDateHeader('01 ene, 2025'),
          const SizedBox(height: 12),
          _buildTextNotificationCard(
            'Promociones invierno. Descubre productos en descuento',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, 2),
    );
  }

  Widget _buildDateHeader(String date) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        date,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String image,
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(icon, color: Colors.grey[400], size: 30);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextNotificationCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      currentIndex: currentIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        _buildCustomNavItem(Icons.search, 'Buscar', currentIndex == 0),
        _buildCustomNavItem(Icons.home_outlined, 'Inicio', currentIndex == 1),
        _buildCustomNavItem(Icons.notifications_outlined, 'Notificaciones', currentIndex == 2),
        _buildCustomNavItem(Icons.person, 'Perfil', currentIndex == 3),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        
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
            // Ya estamos en notificaciones
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            );
            break;
        }
      },
    );
  }

  BottomNavigationBarItem _buildCustomNavItem(IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}