import 'package:clan_barber_club_andujar/services/database_service.dart';
import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key}); 

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  String servicio = '';
  double precio = 0;
  String horario = '';
  DateTime fecha = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedir cita')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Servicio'),
              onSaved: (v) => servicio = v!,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
              onSaved: (v) => precio = double.parse(v!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Horario (08:30-09:00)'),
              onSaved: (v) => horario = v!,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    await _db.agregarCita(
                      nombreServicio: servicio,
                      precio: precio,
                      tramoHorario: horario,
                      fecha: fecha,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita agregada')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Guardar cita'),
            ),
          ],
        ),
      ),
    );
  }
}
