import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_2/screens/lareina.dart';
import 'package:flutter_application_2/screens/medicamentos.dart';
import 'package:flutter_application_2/screens/registro.dart';
import 'package:flutter_application_2/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDDk9VTude5snpiyYd_NntBL6-PjXrs44w",
        authDomain: "appkathy-b330d.firebaseapp.com",
        projectId: "appkathy-b330d",
        storageBucket: "appkathy-b330d.firebasestorage.app",
        messagingSenderId: "957602766605",
        appId: "1:957602766605:web:abc022d4fb5ec538079a44",
      ),
    );
  } on FirebaseException catch (e) {
    // Si la app ya estaba inicializada, ignora el error
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LareinaScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarFormulario();
  }

  Future<void> _verificarFormulario() async {
    final prefs = await SharedPreferences.getInstance();
    final formularioCompletado = prefs.getBool('formulario_completado') ?? false;

    // Esperar un momento para mostrar splash (opcional)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (formularioCompletado) {
        // Si ya completó el formulario, ir a medicamentos
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MedicamentosScreen()),
        );
      } else {
        // Si no ha completado el formulario, ir a registro
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RegistroScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _signOut(BuildContext context) async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();

    // Limpiar el registro del formulario
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('formulario_completado', false);

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegistroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}