import 'package:flutter/material.dart';
import 'screens/asha_vimarsh_screen.dart';

void main() {
  runApp(const AshaVirmarshApp());
}

class AshaVirmarshApp extends StatelessWidget {
  const AshaVirmarshApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASHA Vimarsh',
      theme: ThemeData(
        primaryColor: const Color(0xFF695BCC),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AshaVirmarshScreen(),
    );
  }
}
