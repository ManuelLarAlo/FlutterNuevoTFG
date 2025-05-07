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
                    final _formKey = GlobalKey<FormState>();
                    String email = '';
                    String password = '';
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder( // Necesario para modificar valores dentro del diálogo
                          builder: (context, setState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              backgroundColor: const Color(0xFFF5F5DC),
                              title: const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Correo electrónico',
                                        prefixIcon: const Icon(Icons.email),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) => value!.contains('@') ? null : 'Correo no válido',
                                      onSaved: (value) => email = value!,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        prefixIcon: const Icon(Icons.lock),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                                      onSaved: (value) => password = value!,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar', style: TextStyle(color: Colors.brown)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown[700],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Email: $email\nPassword: $password')),
                                      );
                                      //TODO: logica real de autenticación
                                    }
                                  },
                                  child: const Text('Entrar', style: TextStyle(color: Color(0xFFF5F5DC))),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
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
