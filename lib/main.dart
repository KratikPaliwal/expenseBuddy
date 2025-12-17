import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'auth/auth_wrapper.dart';
import 'currency/currency_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ExpenseBuddyApp());
}

class ExpenseBuddyApp extends StatelessWidget {
  const ExpenseBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrencyProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ExpenseBuddy',
        theme: ThemeData(
          useMaterial3: true,

          iconTheme: const IconThemeData(
            color: Colors.black,
            size: 24,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          ),
        ),

        home: const AuthWrapper(),
      ),
    );
  }
}
