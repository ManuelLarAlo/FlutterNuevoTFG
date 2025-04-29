import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[800],
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen decorativa
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'barber_illustration.png', 
                    height: 200,
                  ),
                ),
                const SizedBox(height: 30),

                // Título
                Text(
                  'Clan Barber Club',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bienvenido a tu barbería de confianza',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[800],
                  ),
                ),

                const SizedBox(height: 50),

                // Botón login
                ElevatedButton(
                  onPressed: () {
                    // TODO: login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Iniciar sesión', style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC))),
                ),
                const SizedBox(height: 20),

                // Botón registro
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown[700],
                    side: const BorderSide(color: Colors.brown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Registrarse', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.brown[800],
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '© 2025 Clan Barber Club',
            style: TextStyle(color: Color(0xFFF5F5DC)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
