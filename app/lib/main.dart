import 'package:flutter/material.dart';
import 'screens/asha_vimarsh_screen.dart';
import 'screens/login_screen.dart';

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
      
      // Set login as the initial screen
      initialRoute: '/login',
      
      // Define your routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/asha_vimarsh_screen': (context) => const AshaVirmarshScreen(),
      },
      
      // Fallback for undefined routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}