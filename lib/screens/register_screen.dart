import 'package:clan_barber_club_andujar/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String lastName = '';
  String email = '';
  String password = '';
  String telefono = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), 
      appBar: AppBar(
        title: const Text('Crear cuenta', style: TextStyle(color: Color(0xFFF5F5DC))),
        backgroundColor: Colors.brown[800],
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Introduce tus datos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (value) => name = value!,
                  validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (value) => lastName = value!,
                  validator: (value) => value!.isEmpty ? 'Ingrese sus apellidos' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'Ej. +34 600 123 456',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (value) => telefono = value!,
                  validator: (value) => value!.isEmpty ? 'Ingrese su número de teléfono' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (value) => email = value!,
                  validator: (value) => value!.contains('@') ? null : 'Correo no válido',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (value) => password = value!,
                  validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      try {
                        final db = DatabaseService();

                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        await db.guardarUsuario(
                          nombre: name,
                          apellidos: lastName,
                          telefono: telefono,
                        );

                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cuenta creada correctamente')),
                          );
                          Navigator.pop(context);
                        });
                      } catch (e) {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al crear cuenta: ${e.toString()}')),
                          );
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Crear cuenta', style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC))),
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
