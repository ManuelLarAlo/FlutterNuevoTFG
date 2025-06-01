import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Obtiene los tramos horarios ocupados para un día dado (solo para el usuario actual)
  Future<List<String>> obtenerTramosOcupados(DateTime fecha) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('citas')
        
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final tramosOcupados = snapshot.docs
        .map((doc) => (doc.data()['tramoHorario'] as String))
        .toList();

    return tramosOcupados;
  }

  // Formatea fecha ISO a dd-MM-yyyy
  static String formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Desconocida';

    DateTime? fechaDate;

    if (fecha is Timestamp) {
      fechaDate = fecha.toDate();
    } else if (fecha is String) {
      try {
        fechaDate = DateTime.parse(fecha);
      } catch (e) {
        return 'Formato inválido';
      }
    } else if (fecha is DateTime) {
      fechaDate = fecha;
    } else {
      return 'Formato inválido';
    }

    return DateFormat('dd-MM-yyyy').format(fechaDate);
  }

  // Guarda datos básicos del usuario
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

  // Agrega una cita en colección raíz 'citas'
  Future<void> agregarCita({
    required String nombreServicio,
    required double precio,
    required String tramoHorario,
    required DateTime fecha,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");
    await _db.collection('citas').add({
      'nombreServicio': nombreServicio,
      'precio': precio,
      'tramoHorario': tramoHorario,
      'userId': user.uid,
      'fecha': Timestamp.fromDate(fecha),
    });
  }

  // Elimina una cita del usuario actual
  Future<void> eliminarCita(String citaId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");

    final citaRef = _db.collection('citas').doc(citaId);
    final citaSnapshot = await citaRef.get();

    if (!citaSnapshot.exists) {
      throw Exception("La cita no existe");
    }

    final data = citaSnapshot.data();
    if (data == null || data['userId'] != user.uid) {
      throw Exception("No tienes permiso para eliminar esta cita");
    }

    await citaRef.delete();
  }

  // Stream para obtener las citas del usuario actual
  Stream<List<Map<String, dynamic>>> obtenerCitasUsuario() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('citas')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              if (data['fecha'] is Timestamp) {
                data['fecha'] = (data['fecha'] as Timestamp).toDate();
              }
              return data;
            }).toList());
  }

  // Obtener citas de todos los usuarios en una fecha dada
  Future<List<Map<String, dynamic>>> obtenerCitasPorFecha(DateTime fecha) async {
    final startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('citas')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['fecha'] is Timestamp) {
        data['fecha'] = (data['fecha'] as Timestamp).toDate();
      }
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  // Elimina una cita (admin)
  Future<void> eliminarCitaAdmin(String citaId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No hay usuario autenticado");
    if (!isAdmin(user)) throw Exception("No tienes permisos de admin");

    await _db.collection('citas').doc(citaId).delete();
  }

  // Obtener citas de todos los usuarios para la semana de la fecha indicada
  Future<List<Map<String, dynamic>>> obtenerCitasPorSemana(DateTime fecha) async {
    final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
    final inicioSemana = fechaSinHora.subtract(Duration(days: fecha.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

    final snapshot = await _db
        .collection('citas')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioSemana))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(finSemana))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data['fecha'] is Timestamp) {
        data['fecha'] = (data['fecha'] as Timestamp).toDate();
      }
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  final Map<String, Map<String, dynamic>> usuariosCache = {};


  // Cambia de _cargarUsuarios a cargarUsuarios (pública)
  Future<void> cargarUsuarios(List<String> userIds) async {
    final idsPorCargar = userIds.where((id) => !usuariosCache.containsKey(id)).toList();
    if (idsPorCargar.isEmpty) return;

    final usuariosSnapshot = await FirebaseFirestore.instance
        .collection('users') // ojo que en tu código 'usuarios' y 'users' está inconsistente, usa 'users' si así guardas.
        .where(FieldPath.documentId, whereIn: idsPorCargar)
        .get();

    for (var doc in usuariosSnapshot.docs) {
      usuariosCache[doc.id] = doc.data();
    }
  }

  // Verifica si el usuario actual es admin
  bool isAdmin(User? user) {
    return user?.email == 'manuellaraalos@gmail.com';
  }
  
}
