import 'package:flutter/material.dart';
import 'package:clan_barber_club_andujar/services/database_service.dart';

class BookingScreenAdmin extends StatefulWidget {
  final DateTime? fechaPredefinida;
  final String? horarioPredefinido;

  const BookingScreenAdmin(
      {super.key, this.fechaPredefinida, this.horarioPredefinido});

  @override
  BookingScreenAdminState createState() => BookingScreenAdminState();
}

class BookingScreenAdminState extends State<BookingScreenAdmin> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  String servicio = '';
  double precio = 0;
  String? horario;
  DateTime fecha = DateTime.now();

  String nombreCliente = '';
  String telefonoCliente = '';

  @override
  void initState() {
    super.initState();
    fecha = widget.fechaPredefinida ?? DateTime.now();
    horario = widget.horarioPredefinido;
  }

  final List<String> tramosDisponibles = [
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

  Future<bool> isDiaLleno(DateTime dia) async {
    final tramosOcupados = await _db.obtenerTramosOcupados(dia);
    return tramosDisponibles.every((tramo) => tramosOcupados.contains(tramo));
  }

  final Map<String, double> serviciosConPrecio = {
    'Corte de pelo': 10.0,
    'Corte y barba': 15.0,
    'Arreglo de barba': 8.0,
    'Tinte': 12.0,
    'Diseño personalizado': 20.0,
  };

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.brown),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        title: const Text('Pedir cita',
            style: TextStyle(color: Color(0xFFF5F5DC))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5DC)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.brown),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: servicio.isNotEmpty ? servicio : null,
                items: serviciosConPrecio.keys.map((serv) {
                  return DropdownMenuItem<String>(
                    value: serv,
                    child: Text(serv),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    servicio = newValue!;
                    precio = serviciosConPrecio[servicio]!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Selecciona un servicio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Precio (€)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                initialValue: precio != 0 ? precio.toStringAsFixed(2) : '',
                readOnly: true,
                enabled: false,
                key: ValueKey(precio), // Fuerza a reconstruir con nuevo precio
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del cliente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.brown),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce el nombre del cliente';
                  }
                  return null;
                },
                onSaved: (value) => nombreCliente = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono del cliente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.brown),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce el teléfono del cliente';
                  }
                  return null;
                },
                onSaved: (value) => telefonoCliente = value!.trim(),
              ),
              const SizedBox(height: 16),
              const Text('Selecciona una fecha',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fecha.day}/${fecha.month}/${fecha.year}',
                      style: const TextStyle(fontSize: 16, color: Colors.brown),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.brown),
                      onPressed: () async {
                        // Ajustar initialDate para que no sea fin de semana
                        DateTime initialDateToShow = fecha;
                        if (initialDateToShow.weekday == DateTime.saturday) {
                          initialDateToShow = initialDateToShow
                              .add(const Duration(days: 2)); // lunes
                        } else if (initialDateToShow.weekday ==
                            DateTime.sunday) {
                          initialDateToShow = initialDateToShow
                              .add(const Duration(days: 1)); // lunes
                        }

                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: initialDateToShow,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                          selectableDayPredicate: (day) {
                            // Desactivar sábados y domingos
                            return day.weekday != DateTime.saturday &&
                                day.weekday != DateTime.sunday;
                          },
                        );

                        if (picked != null && picked != fecha) {
                          setState(() {
                            fecha = picked;
                            horario = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tramos disponibles', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              FutureBuilder<List<String>>(
                future: _db.obtenerTramosOcupados(fecha),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final tramosOcupados = snapshot.data ?? [];

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tramosDisponibles.map((tramo) {
                      final estaOcupado = tramosOcupados.contains(tramo);
                      final estaSeleccionado = horario == tramo;

                      return ChoiceChip(
                        label: Text(tramo),
                        selected: estaSeleccionado,
                        onSelected: estaOcupado
                            ? null
                            : (selected) {
                                setState(() {
                                  horario = selected ? tramo : null;
                                });
                              },
                        selectedColor: Colors.green[400],
                        disabledColor: Colors.red[300],
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: estaOcupado
                              ? Colors.white
                              : estaSeleccionado
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (horario == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Selecciona un tramo horario')),
                        );
                        return;
                      }

                      _formKey.currentState!.save();

                      try {
                        await _db.agregarCita(
                            nombreServicio: servicio,
                            precio: precio,
                            tramoHorario: horario!,
                            fecha: fecha,
                            nombreCliente: nombreCliente,
                            telefonoCliente: telefonoCliente);

                        if (context.mounted) {
                          final addToCalendar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cita guardada'),
                              content: const Text(
                                  '¿Quieres añadir un recordatorio en Google Calendar?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sí'),
                                ),
                              ],
                            ),
                          );

                          if (addToCalendar == true) {
                            await _db.abrirGoogleCalendar(
                              titulo: servicio,
                              fecha: fecha,
                              tramoHorario: horario!,
                            );
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cita agregada')),
                            );
                            Navigator.pop(context);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Guardar cita',
                      style: TextStyle(fontSize: 18, color: Color(0xFFF5F5DC))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
