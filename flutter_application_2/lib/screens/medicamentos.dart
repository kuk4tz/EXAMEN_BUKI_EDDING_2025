import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/screens/buscar.dart';
import 'package:flutter_application_2/screens/perfil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_2/screens/notifs.dart';
import 'package:flutter_application_2/screens/detail_product.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MedicamentosScreen extends StatefulWidget {
  const MedicamentosScreen({super.key});

  @override
  State<MedicamentosScreen> createState() => _MedicamentosScreenState();
}

class _MedicamentosScreenState extends State<MedicamentosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  int _carouselIndex = 1;
  //int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();

  Future<String?> _uploadImage(XFile file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
    await ref.putFile(File(file.path)); // subir y no guardar variable sin usar
    return await ref.getDownloadURL();
  }

  void _addProduct(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(
          builder: (context, setStateDialog) => Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Agregar farmaco',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Preview imagen (si hay)
                  if (pickedImage != null)
                    SizedBox(
                      height: 140,
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(pickedImage!.path), fit: BoxFit.cover)),
                    ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text('Elegir foto'),
                        onPressed: () async {
                          final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
                          if (img != null) setStateDialog(() => pickedImage = img);
                        },
                      ),
                      const SizedBox(width: 12),
                      if (pickedImage != null)
                        TextButton(
                          onPressed: () => setStateDialog(() => pickedImage = null),
                          child: const Text('Quitar'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final description = descriptionController.text.trim();
                          final price = double.tryParse(priceController.text.trim());

                          if (title.isNotEmpty && description.isNotEmpty && price != null) {
                            String? imageUrl;
                            if (pickedImage != null) {
                              imageUrl = await _uploadImage(pickedImage!);
                            }

                            await FirebaseFirestore.instance.collection('farmaco').add({
                              'title': title,
                              'description': description,
                              'price': price,
                              'imageUrl': imageUrl ?? '',
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return; // evitar usar context si el State fue disposed
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado correctamente')));
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editProduct(BuildContext context, String docId, Map<String, dynamic> data) async {
    final titleController = TextEditingController(text: data['title']);
    final descriptionController = TextEditingController(text: data['description']);
    final priceController = TextEditingController(text: (data['price'] ?? '').toString());
    XFile? pickedImage;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(
          builder: (context, setStateDialog) => Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Editar farmaco',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // preview: nueva imagen o la existente
                  if (pickedImage != null)
                    SizedBox(height: 140, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(pickedImage!.path), fit: BoxFit.cover)))
                  else if ((data['imageUrl'] ?? '').toString().isNotEmpty)
                    SizedBox(height: 140, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(data['imageUrl'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)))),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo),
                        label: const Text('Cambiar foto'),
                        onPressed: () async {
                          final img = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
                          if (img != null) setStateDialog(() => pickedImage = img);
                        },
                      ),
                      const SizedBox(width: 12),
                      if (pickedImage != null)
                        TextButton(onPressed: () => setStateDialog(() => pickedImage = null), child: const Text('Quitar')),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final description = descriptionController.text.trim();
                          final price = double.tryParse(priceController.text.trim());

                          if (title.isNotEmpty && description.isNotEmpty && price != null) {
                            String imageUrl = (data['imageUrl'] ?? '').toString();
                            if (pickedImage != null) {
                              imageUrl = (await _uploadImage(pickedImage!)) ?? imageUrl;
                            }

                            await FirebaseFirestore.instance.collection('farmaco').doc(docId).update({
                              'title': title,
                              'description': description,
                              'price': price,
                              'imageUrl': imageUrl,
                            });

                            if (!mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('farmaco actualizado correctamente')));
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar farmaco'),
        content: const Text('¿Estás seguro de que quieres eliminar este farmaco?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('farmaco').doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('farmaco eliminado correctamente')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildCarousel(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tomar los primeros 5 medicamentos para el carousel
    final carouselDocs = docs.take(5).toList();
    final CarouselSliderController carouselController = CarouselSliderController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Destacados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                // Carousel con flechas
                Row(
                  children: [
                    // Flecha izquierda
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_left, size: 32),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => carouselController.previousPage(),
                    ),
                    // Carousel
                    Expanded(
                      child: CarouselSlider(
                        carouselController: carouselController,
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          viewportFraction: 0.5, // Mostrar 2 productos
                          onPageChanged: (index, reason) {
                            setState(() => _carouselIndex = index);
                          },
                        ),
                        items: carouselDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              final title = data['title'] ?? 'Sin título';
                              final description = data['description'] ?? 'Sin descripción';
                              final price = (data['price'] ?? 0).toDouble();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailProductScreen(
                                    title: title,
                                    description: description,
                                    price: price,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Imagen de fondo
                                    (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
                                        ? Image.network(
                                            data['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.broken_image, size: 48),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                          ),
                                    // Overlay oscuro
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Botón de favorito
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.favorite_border, color: Colors.red),
                                          iconSize: 20,
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${data['title']} agregado a favoritos')),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Contenido (título y precio)
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            data['title'] ?? 'Sin título',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${(data['price'] ?? 0).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
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
                        }).toList(),
                      ),
                    ),
                    // Flecha derecha
                    IconButton(
                      icon: const Icon(Icons.arrow_circle_right, size: 32),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => carouselController.nextPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Indicadores (dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    carouselDocs.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _carouselIndex == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _carouselIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Farmacos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar farmaco...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('farmaco').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar farmacos'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = (data['title'] ?? '').toString().toLowerCase();
            return title.contains(_searchText);
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Center(child: Text('No hay farmacos que coincidan'));
          }

          return ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredDocs.length + 1,
                  itemBuilder: (context, index) {
                    // Mostrar carousel en el medio
                    if (index == (filteredDocs.length / 2).ceil()) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildCarousel(docs),
                        ],
                      );
                    }

                    // Ajustar el índice después del carousel
                    final docIndex = index > (filteredDocs.length / 2).ceil() ? index - 1 : index;
                    final doc = filteredDocs[docIndex];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final title = data['title'] ?? 'Sin título';
                          final description = data['description'] ?? 'Sin descripción';
                          final price = (data['price'] ?? 0).toDouble();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailProductScreen(
                                title: title,
                                description: description,
                                price: price,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
                                  ? Image.network(
                                      data['imageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                    )
                                  : const Icon(Icons.image, size: 36, color: Colors.grey),
                            ),
                          ),
                          title: Text(
                            data['title'] ?? '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(data['description'] ?? ''),
                              const SizedBox(height: 4),
                              Text('\$${(data['price'] ?? 0).toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'editar') {
                                _editProduct(context, doc.id, data);
                              } else if (value == 'eliminar') {
                                _deleteProduct(context, doc.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'editar', child: Text('Editar')),
                              PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context)
    );
  }
}


Widget _buildBottomNavigationBar(BuildContext context) {
  // Aquí indicamos que en esta pantalla "Inicio" está seleccionado (index 1)
  const int selectedIndex = 1;

  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
    elevation: 8,
    currentIndex: selectedIndex,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    items: [
      _buildNavItem(Icons.search, 'Buscar', selectedIndex),
      _buildNavItem(Icons.home_outlined, 'Inicio', selectedIndex),
      _buildNavItem(Icons.notifications_outlined, 'Notificaciones', selectedIndex),
      _buildNavItem(Icons.person, 'Perfil', selectedIndex),
    ],
    onTap: (index) {
      switch (index) {
        case 0: // Buscar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BuscarScreen()),
          );
          break;
        case 1: // Inicio -> quedarse en Medicamentos (esta pantalla)
          return;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NotificacionesScreen()),
          );
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
//circulo que rodea el icono seleccionado bottom
BottomNavigationBarItem _buildNavItem(IconData icon, String label, int currentIndex) {
  final isSelected = (label == 'Buscar' && currentIndex == 1) ||
                     (label == 'Inicio' && currentIndex == 0) ||
                     (label == 'Notificaciones' && currentIndex == 2) ||
                     (label == 'Perfil' && currentIndex == 3);
  
  return BottomNavigationBarItem(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(  16)
            )
          : null,
      child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
    ),
    label: label,
  );
}

