import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<String>> obtenerTramosOcupados(DateTime fecha, ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('citas')
        .where('fecha', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('fecha', isLessThan: endOfDay.toIso8601String())
        .get();

    // Extraemos los tramos horarios ocupados
    final tramosOcupados = snapshot.docs
        .map((doc) => (doc.data()['tramoHorario'] as String))
        .toList();

    return tramosOcupados;
  }

  static String formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Desconocida';
    try {
      final fecha = DateTime.parse(fechaIso);
      return DateFormat('MM-dd-yyyy').format(fecha);
    } catch (e) {
      return 'Formato inválido';
    }
  }


  Future<void> guardarUsuario({
    required String nombre,
    required String apellidos,
    required String telefono,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");
    await _db.collection('users').doc(user.uid).set({
      'nombre': nombre,
      'apellidos': apellidos,
      'email': user.email,
      'telefono': telefono,
    });
  }

  Future<void> agregarCita({
    required String nombreServicio,
    required double precio,
    required String tramoHorario,
    required DateTime fecha,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('citas')
        .add({
      'nombreServicio': nombreServicio,
      'precio': precio,
      'tramoHorario': tramoHorario,
      'userId': user.uid,
      'fecha': fecha.toIso8601String(),
    });
  }

  Future<void> eliminarCita(String citaId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('citas')
        .doc(citaId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> obtenerCitasUsuario() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('citas')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}
