import 'package:clan_barber_club_andujar/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ClanBarberApp());
}

class ClanBarberApp extends StatelessWidget {
  const ClanBarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Clan Barber Club Andújar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.brown),
        home:
            const SplashScreen(), // La primera pantalla que se muestra es la SplashScreen
        routes: appRoutes);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Escucha los cambios de estado de autenticación
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child:
                    CircularProgressIndicator()), // Mientras esperamos, mostramos un indicador de carga
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen(); // Si el usuario está autenticado, muestra la pantalla principal
        }

        return const WelcomeScreen(); // Si no hay usuario autenticado, muestra la pantalla de bienvenida
      },
    );
  }
}
