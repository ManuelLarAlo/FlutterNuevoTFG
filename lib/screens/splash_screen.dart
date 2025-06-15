import 'package:clan_barber_club_andujar/screens/admin_screen.dart';
import 'package:clan_barber_club_andujar/screens/home_screen.dart';
import 'package:clan_barber_club_andujar/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;
  
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {  
        setState(() {
          _opacity = 1;
        });
      }
    });

    // Lógica para decidir a qué pantalla ir después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      Widget destino;

      if (user == null) {
        destino = const WelcomeScreen();
      } else if (user.email == 'manuellaraalos@gmail.com') {
        destino = const AdminScreen();
      } else {
        destino = const HomeScreen();
      }

      // Redirigir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destino),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(30),
                child: const Icon(Icons.cut, size: 80, color: Color(0xFFF5F5DC)),
              ),
              const SizedBox(height: 30),
              const Text(
                'Clan Barber Club Andújar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFFF5F5DC),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
