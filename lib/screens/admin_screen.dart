import 'package:clan_barber_club_andujar/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  DateTime _selectedDate = DateTime.now();
  final DatabaseService _dbService = DatabaseService();
  bool _mostrarVistaSemanal = false;
  Set<DateTime> fechasConCitas = {};

  List<Map<String, dynamic>> _citas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final citas = _mostrarVistaSemanal
          ? await _dbService.obtenerCitasPorSemana(_selectedDate)
          : await _dbService.obtenerCitasPorFecha(_selectedDate);

      final userIds = citas
          .map((cita) => cita['userId'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      await _dbService.cargarUsuarios(userIds);

      final fechas = citas.map((cita) {
        final fechaData = cita['fecha'];
        DateTime fecha;
        if (fechaData is Timestamp) {
          fecha = fechaData.toDate();
        } else if (fechaData is DateTime) {
          fecha = fechaData;
        } else {
          fecha = DateTime.now();
        }
        return DateTime(fecha.year, fecha.month, fecha.day);
      }).toSet();

      setState(() {
        _citas = citas;
        fechasConCitas = fechas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Cuando cambies vista o fecha, recarga las citas:
  void _onToggleVista() {
    setState(() {
      _mostrarVistaSemanal = !_mostrarVistaSemanal;
    });
    _cargarCitas();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_mostrarVistaSemanal) {
      final monday =
          selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
      setState(() {
        _selectedDate = monday;
      });
    } else {
      setState(() {
        _selectedDate = selectedDay;
      });
    }
    _cargarCitas();
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
            const Text('Admin', style: TextStyle(fontSize: 20)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: Icon(_mostrarVistaSemanal
                              ? Icons.calendar_view_day
                              : Icons.calendar_view_week),
                          label: Text(
                              _mostrarVistaSemanal ? 'Vista diaria' : 'Vista semanal'),
                          onPressed: _onToggleVista,
                        ),
                      ],
                    ),
                    TableCalendar(
                      enabledDayPredicate: (day) =>
                          day.weekday != DateTime.saturday &&
                          day.weekday != DateTime.sunday,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      focusedDay: _selectedDate,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                      onDaySelected: _onDaySelected,
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          if (_mostrarVistaSemanal) {
                            final monday = _selectedDate
                                .subtract(Duration(days: _selectedDate.weekday - 1));
                            final sunday = monday.add(const Duration(days: 6));
                            if (!day.isBefore(monday) && !day.isAfter(sunday)) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.brown.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(6.0),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Citas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    // Aquí el listado o loading o error:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text('Error: $_error'))
                            : _citas.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay citas para esta fecha',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : _mostrarVistaSemanal
                                    ? SizedBox(
                                        height: 400, // Puedes ajustar esta altura si quieres
                                        child: _buildVistaSemanal(_citas),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _citas.length,
                                        itemBuilder: (context, index) =>
                                            _buildCitaTile(_citas[index]),
                                      ),
                  ],
                ),
              ),
            );
          },
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

  Widget _buildVistaSemanal(List<Map<String, dynamic>> citas) {
    final citasPorDia = <DateTime, List<Map<String, dynamic>>>{};
    for (final cita in citas) {
      final fechaData = cita['fecha'];
      DateTime fecha;
      if (fechaData is Timestamp) {
        fecha = fechaData.toDate();
      } else if (fechaData is DateTime) {
        fecha = fechaData;
      } else {
        fecha = DateTime.now();
      }
      final soloFecha = DateTime(fecha.year, fecha.month, fecha.day);
      citasPorDia.putIfAbsent(soloFecha, () => []).add(cita);
    }

    final diasOrdenados = citasPorDia.keys.toList()..sort();

    return ListView.builder(
      itemCount: diasOrdenados.length,
      itemBuilder: (context, index) {
        final dia = diasOrdenados[index];
        final citasDelDia = citasPorDia[dia]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dia.day}/${dia.month}/${dia.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...citasDelDia.map((cita) => _buildCitaTile(cita)),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildCitaTile(Map<String, dynamic> cita) {
    final userId = cita['userId'] as String?;
    final userData = userId != null ? _dbService.usuariosCache[userId] : null;

    final userNombre =
        userData != null ? userData['nombre'] ?? 'Desconocido' : 'Desconocido';
    final userEmail =
        userData != null ? userData['email'] ?? 'Sin email' : 'Sin email';
    final userApellidos = userData != null
        ? userData['apellidos'] ?? 'Sin apellidos'
        : 'Sin apellidos';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.calendar_today, color: Colors.brown),
        title: Text('Servicio: ${cita['nombreServicio'] ?? 'N/A'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario: $userNombre $userApellidos'),
            Text('Email: $userEmail'),
            Text('Horario: ${cita['tramoHorario'] ?? 'N/A'}'),
            Text('Precio: ${cita['precio'] ?? 'N/A'}€'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('¿Eliminar cita?'),
                content: const Text(
                    '¿Estás seguro de que deseas eliminar esta cita?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Eliminar',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              try {
                await FirebaseFirestore.instance
                    .collection('citas')
                    .doc(cita['id'])
                    .delete();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cita eliminada')),
                  );

                  setState(() {
                    // Quitar cita eliminada del listado local
                    _citas
                        .removeWhere((element) => element['id'] == cita['id']);

                    // También actualizar fechasConCitas por si la cita eliminada era la única en ese día
                    final fechas = _citas.map((c) {
                      final fechaData = c['fecha'];
                      DateTime fecha;
                      if (fechaData is Timestamp) {
                        fecha = fechaData.toDate();
                      } else if (fechaData is DateTime) {
                        fecha = fechaData;
                      } else {
                        fecha = DateTime.now();
                      }
                      return DateTime(fecha.year, fecha.month, fecha.day);
                    }).toSet();
                    fechasConCitas = fechas;
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> obtenerCitasConUsuarios() async {
    final citas = _mostrarVistaSemanal
        ? await _dbService.obtenerCitasPorSemana(_selectedDate)
        : await _dbService.obtenerCitasPorFecha(_selectedDate);

    final userIds = citas
        .map((cita) => cita['userId'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    await _dbService.cargarUsuarios(userIds);

    // Aquí está el problema:
    setState(() {
      fechasConCitas = citas.map((cita) {
        final fechaData = cita['fecha'];
        DateTime fecha;
        if (fechaData is Timestamp) {
          fecha = fechaData.toDate();
        } else if (fechaData is DateTime) {
          fecha = fechaData;
        } else {
          fecha = DateTime.now();
        }
        return DateTime(fecha.year, fecha.month, fecha.day);
      }).toSet();
    });

    return citas;
  }
}
