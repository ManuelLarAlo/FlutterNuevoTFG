import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
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
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
