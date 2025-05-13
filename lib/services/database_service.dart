import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
