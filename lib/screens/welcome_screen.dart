import 'package:clan_barber_club_andujar/screens/admin_screen.dart';
import 'package:clan_barber_club_andujar/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clan_barber_club_andujar/services/auth_service.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();

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
                    'assets/barber_illustration.png',
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
                    final formKey = GlobalKey<FormState>();
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
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Correo electrónico',
                                          prefixIcon: const Icon(Icons.email),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) => value!.contains('@') ? null : 'Correo no válido',
                                        onSaved: (value) => email = value!,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: 300,
                                      child: TextFormField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          prefixIcon: const Icon(Icons.lock),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                                        onSaved: (value) => password = value!,
                                      ),
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
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                      try {
                                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                                          email: email,
                                          password: password,
                                        );

                                        if (!mounted) return;

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          Navigator.pop(context);

                                          // Revisa el correo del usuario logueado
                                          final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

                                          if (userEmail == 'manuellaraalos@gmail.com') {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => const AdminScreen()),
                                            );
                                          } else {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                                            );
                                          }
                                        });
                                      } catch (e) {
                                        if (!mounted) return;

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
                                          );
                                        });
                                      }
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
                const SizedBox(height: 20),

                //Botón de login con google
                ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: Color(0xFFF5F5DC)),
                  label: const Text('Iniciar sesión con Google', style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final user = await _authService.signInWithGoogle();

                    if (user != null) {
                      final userEmail = user.email ?? '';

                      if (!mounted) return;

                      if (userEmail == 'manuellaraalos@gmail.com') {
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminScreen()),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inicio de sesión con Google cancelado o fallido')),
                      );
                      }
                    }
                  },
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
