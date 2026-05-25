import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'constants/colors.dart';

import 'package:provider/provider.dart';
import 'providers/worker_provider.dart';
import 'providers/service_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: const AdminLandPropApp(),
    ),
  );
}

class AdminLandPropApp extends StatelessWidget {
  const AdminLandPropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdminLandProp Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const MainScreen(),
    );
  }
}
