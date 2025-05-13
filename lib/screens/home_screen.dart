import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_screen.dart'; // Asegúrate de importar tu pantalla de reservas

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isMenuOpen = false;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    throw 'No user logged in';
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
            const Placeholder(fallbackWidth: 40, fallbackHeight: 40),
            const SizedBox(width: 10),
            const Text('Clan Barber Club', style: TextStyle(fontSize: 20)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.settings),
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
          // 📋 Lista de citas
          user == null
              ? const Center(child: Text('Usuario no autenticado'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
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
                                Text('Fecha: ${data['fecha'] ?? 'Desconocida'}'),
                                Text('Precio: ${data['precio'] ?? 'N/A'}€'),
                                Text('Horario: ${data['tramoHorario'] ?? 'N/A'}'),
                              ],
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

          // Menú lateral
          if (_isMenuOpen)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                color: const Color(0xFFF5F5DC),
                width: 250,
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
                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre: ${userData['nombre'] ?? "No disponible"}', style: const TextStyle(fontSize: 16)),
                          Text('Correo: ${userData['email'] ?? "No disponible"}', style: const TextStyle(fontSize: 16)),
                          Text('Número: ${userData['telefono'] ?? "No disponible"}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(context, '/');
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
            // ElevatedButton ubicado en la parte inferior derecha
            Positioned(
              bottom: 20,
              right: 16,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700], // Color de fondo del botón
                  minimumSize: const Size(200, 60), // Tamaño personalizado del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingScreen()),
                  );
                },
                child: const Text(
                  'Pedir cita',
                  style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC)), // Estilo del texto
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
