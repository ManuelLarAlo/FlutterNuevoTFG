import 'package:clan_barber_club_andujar/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isMenuOpen = false;

  final TextEditingController _telefonoController = TextEditingController();
  bool _isEditingTelefono = false;
  bool _isSavingTelefono = false;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    throw 'No user logged in';
  }

    Future<void> _updateTelefono(String telefono) async {
    if (user == null) return;

    final telefonoSinEspacios = telefono.replaceAll(' ', '');
    final esValido = RegExp(r'^\d{9,}$').hasMatch(telefonoSinEspacios);

    if (!esValido) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El teléfono debe tener al menos 9 dígitos y solo números')),
        );
      }
      return;
    }

    setState(() {
      _isSavingTelefono = true;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'telefono': telefono,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teléfono actualizado')),
        );
      }
      setState(() {
        _isEditingTelefono = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar teléfono: $e')),
        );
      }
    } finally {
      setState(() {
        _isSavingTelefono = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[800],
        title: Row(
          children: [
            Image.asset(
              'assets/barber_illustration.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            const Text('Clan Barber Club', style: TextStyle(fontSize: 20, color: Color(0xFFF5F5DC))),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFFF5F5DC)),
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                });
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Lista de citas
          user == null
              ? const Center(child: Text('Usuario no autenticado'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('citas')
                      .where('userId', isEqualTo: user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay citas registradas',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    final appointments = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final data = appointments[index].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today, color: Colors.brown),
                            title: Text('Servicio: ${data['nombreServicio'] ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fecha: ${DatabaseService.formatearFecha(data['fecha'])}'),
                                Text('Precio: ${data['precio'] ?? 'N/A'}€'),
                                Text('Horario: ${data['tramoHorario'] ?? 'N/A'}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('¿Eliminar cita?'),
                                    content: const Text('¿Estás seguro de que deseas eliminar esta cita?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final citaId = appointments[index].id;
                                  final dbService = DatabaseService();

                                  try {
                                    await dbService.eliminarCita(citaId);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Cita eliminada')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al eliminar la cita: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

          // Fondo oscuro para el menú
          if (_isMenuOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isMenuOpen = false;
                });
              },
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

          // Menú lateral animado
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            right: _isMenuOpen ? 0 : -250,
            child: Container(
              width: 250,
              color: const Color(0xFFF5F5DC),
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<DocumentSnapshot>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    if (!snapshot.data!.exists) {
                      return const Text('No hay datos disponibles para este usuario.');
                    }
                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    if (!_isEditingTelefono) {
                      _telefonoController.text = userData['telefono'] ?? '';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre: ${userData['nombre'] ?? "No disponible"}', style: const TextStyle(fontSize: 16)),
                        Text('Correo: ${userData['email'] ?? "No disponible"}', style: const TextStyle(fontSize: 16)),
                                                // Campo teléfono editable
                        Row(
                          children: [
                            const Text('Número: ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: TextField(
                                controller: _telefonoController,
                                enabled: _isEditingTelefono && !_isSavingTelefono,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _isEditingTelefono
                                ? _isSavingTelefono
                                    ? const CircularProgressIndicator()
                                    : IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () {
                                          String nuevoTelefono = _telefonoController.text.trim();
                                          _updateTelefono(nuevoTelefono);
                                        },
                                      )
                                : IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.brown),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingTelefono = true;
                                      });
                                    },
                                  ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Cerrar sesión', style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC))),
                        ),
                      ],
                    );
                  } else {
                    return const Text('No hay datos del usuario');
                  }
                },
              ),
            ),
          ),

          // Botón para pedir cita
          Positioned(
            bottom: 20,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (_telefonoController.text.trim().isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Número de teléfono requerido'),
                      content: const Text(
                          'Por favor, configure su número de teléfono en el menú antes de pedir una cita.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  return; // No navegamos a BookingScreen
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingScreen()),
                );
              },
              child: const Text(
                'Pedir cita',
                style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC)),
              ),
            ),
          ),
        ],
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
