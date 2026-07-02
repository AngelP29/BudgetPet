import 'package:flutter/material.dart';
import 'screens/LoginScreen.dart';
void main() {
  runApp(const BudgetPetApp());
}

class BudgetPetApp extends StatelessWidget {
  const BudgetPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetPet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

