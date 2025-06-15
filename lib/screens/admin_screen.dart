import 'package:clan_barber_club_andujar/screens/booking_screen_admin.dart';
import 'package:clan_barber_club_andujar/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:collection/collection.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isMenuOpen = false;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }
    throw 'No user logged in';
  }

  final DatabaseService _databaseService = DatabaseService();
  DateTime _currentWeekStart = DateTime.now();
  List<String> horarios = [
    "10:00 - 10:30",
    "10:30 - 11:00",
    "11:00 - 11:30",
    "11:30 - 12:00",
    "12:00 - 12:30",
    "12:30 - 13:00",
    "13:00 - 13:30",
    "13:30 - 14:00",
    "16:00 - 16:30",
    "16:30 - 17:00",
    "17:00 - 17:30",
    "17:30 - 18:00",
    "18:00 - 18:30",
    "18:30 - 19:00",
    "19:00 - 19:30",
    "19:30 - 20:00",
  ];
  Map<String, List<Map<String, dynamic>>> citasSemana = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadCitas();
  }

  void _loadCitas() async {
    final citas =
        await _databaseService.obtenerCitasPorSemana(_currentWeekStart);
    final mapa = <String, List<Map<String, dynamic>>>{};
    final userIdsSet = <String>{};
    for (var cita in citas) {
      final fecha = cita['fecha'] as DateTime;
      final key = DateFormat('yyyy-MM-dd').format(fecha);
      mapa.putIfAbsent(key, () => []).add(cita);
      userIdsSet.add(cita['userId'] as String);
    }
    await _databaseService.cargarUsuarios(userIdsSet.toList());
    setState(() => citasSemana = mapa);
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: offset * 7));
    });
    _loadCitas();
  }

  @override
  Widget build(BuildContext context) {
    final diasSemana = List.generate(
        7,
        (index) => _currentWeekStart
            .subtract(Duration(days: _currentWeekStart.weekday - 1 - index)));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
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
            const Text('Clan Barber Club',
                style: TextStyle(fontSize: 20, color: Color(0xFFF5F5DC))),
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
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700]),
                      onPressed: () => _changeWeek(-1),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFFF5F5DC)),
                    ),
                    Text(
                      'Semana del ${DateFormat('dd MMM', 'es_ES').format(diasSemana.first)} al ${DateFormat('dd MMM', 'es_ES').format(diasSemana.last)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700]),
                      onPressed: () => _changeWeek(1),
                      child: const Icon(Icons.arrow_forward,
                          color: Color(0xFFF5F5DC)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {
                              0: const FlexColumnWidth(
                                  2), // Horario columna un poco más ancha
                              // Para las demás columnas usa FlexColumnWidth para adaptar
                              for (int i = 1; i <= 7; i++)
                                i: const FlexColumnWidth(1),
                            },
                            border:
                                TableBorder.all(color: Colors.brown.shade200),
                            children: [
                              TableRow(
                                children: [
                                  const TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Horario",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...diasSemana.map((dia) => Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            DateFormat.E('es_ES').format(dia),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                              ...horarios.map((horario) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(horario),
                                    ),
                                    ...diasSemana.map((dia) {
                                      final fechaClave =
                                          DateFormat('yyyy-MM-dd').format(dia);
                                      final citaDelDia = citasSemana[fechaClave]
                                          ?.firstWhereOrNull(
                                        (cita) =>
                                            cita['tramoHorario'] == horario,
                                      );
                                      final tieneCita = citaDelDia != null &&
                                          citaDelDia.isNotEmpty;

                                      final esFinDeSemana =
                                          dia.weekday == DateTime.saturday ||
                                              dia.weekday == DateTime.sunday;

                                      final currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      String nombreCompleto = '';
                                      String correo = '';
                                      String telefono = '';
                                      if (citaDelDia != null) {
                                        final userId =
                                            citaDelDia['userId'] as String?;
                                        if (userId != null) {
                                          final usuario = _databaseService
                                              .usuariosCache[userId];

                                          if (currentUser != null &&
                                              userId == currentUser.uid) {
                                            nombreCompleto =
                                                citaDelDia['nombreCliente'] ??
                                                    'Admin';
                                            correo =
                                                'Correo admin no disponible';
                                            telefono =
                                                citaDelDia['telefonoCliente'] ??
                                                    'Sin teléfono';
                                          } else {
                                            nombreCompleto = usuario != null
                                                ? '${usuario['nombre']} ${usuario['apellidos']}'
                                                : 'Usuario desconocido';
                                            correo = usuario != null
                                                ? '${usuario['email']}'
                                                : 'Sin correo';
                                            telefono = usuario != null
                                                ? '${usuario['telefono']}'
                                                : 'Sin telefono';
                                          }
                                        } else {
                                          nombreCompleto =
                                              'Usuario no especificado';
                                        }
                                      }
                                      return GestureDetector(
                                        onTap: esFinDeSemana
                                            ? null
                                            : () async {
                                                if (tieneCita) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text(
                                                          "Detalles de la cita"),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              "Servicio: ${citaDelDia['nombreServicio']}"),
                                                          Text(
                                                              "Precio: ${citaDelDia['precio']} €"),
                                                          Text(
                                                              "Horario: ${citaDelDia['tramoHorario']}"),
                                                          Text(
                                                              "Usuario: $nombreCompleto"),
                                                          Text(
                                                              "Correo: $correo"),
                                                          Text(
                                                              "Teléfono: $telefono"),
                                                        ],
                                                      ),
                                                      actions: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          tooltip:
                                                              'Eliminar cita',
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Cierra el diálogo
                                                            try {
                                                              await _databaseService
                                                                  .eliminarCitaAdmin(
                                                                      citaDelDia[
                                                                              'id']
                                                                          as String);
                                                              if (context
                                                                  .mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Cita eliminada correctamente')),
                                                                );
                                                              }
                                                              _loadCitas(); // Recarga la lista de citas después de eliminar
                                                            } catch (e) {
                                                              if (context
                                                                  .mounted) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Error al eliminar cita: $e')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              "Cerrar"),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          BookingScreenAdmin(
                                                        fechaPredefinida: dia,
                                                        horarioPredefinido:
                                                            horario,
                                                      ),
                                                    ),
                                                  );
                                                  _loadCitas();
                                                }
                                              },
                                        child: Container(
                                          height: 40,
                                          color: esFinDeSemana
                                              ? Colors.grey[300]
                                              : tieneCita
                                                  ? Colors.green[300]
                                                  : Colors.transparent,
                                          child: Center(
                                            child: Text(
                                              tieneCita ? nombreCompleto : '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre: ${userData['nombre'] ?? "No disponible"}',
                            style: const TextStyle(fontSize: 16)),
                        Text('Correo: ${userData['email'] ?? "No disponible"}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            'Número: ${userData['telefono'] ?? "No disponible"}',
                            style: const TextStyle(fontSize: 16)),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Cerrar sesión',
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFFF5F5DC))),
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
