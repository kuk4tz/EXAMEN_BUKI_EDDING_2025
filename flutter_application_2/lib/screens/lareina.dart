import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/screens/recetas.dart'; // LoginScreen
import 'package:flutter_application_2/screens/medicamentos.dart'; // MedicamentosScreen

class LareinaScreen extends StatefulWidget {
  const LareinaScreen({super.key});

  @override
  State<LareinaScreen> createState() => _LareinaScreenState();
}

class _LareinaScreenState extends State<LareinaScreen> {
  double opacity = 0.0; // 

  @override
  void initState() {
    super.initState();

    // Inicia el fade-in wiii
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => opacity = 1.0);
    });

    //
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MedicamentosScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecetasScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logolareina.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Farmacia la Reina',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
