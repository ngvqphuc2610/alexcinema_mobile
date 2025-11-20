import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/dependency_injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/widgets/navbar_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _bootstrap();
}

Future<void> _bootstrap() async {
  await _loadEnv();
  await initDependencyInjection();
  runApp(const AlexCinemaApp());
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: 'lib/.env');
  } catch (error) {
    debugPrint('Failed to load env file: $error');
  }
}

class AlexCinemaApp extends StatelessWidget {
  const AlexCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => serviceLocator<AuthBloc>()..add(const AuthStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Alex Cinema',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const NavbarMainShell(),
      ),
    );
  }
}

ThemeData _buildTheme() {
  const seed = Color(0xFF6C63FF);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 1.2),
  );

  return ThemeData(
    useMaterial3: false,
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.grey.shade900,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: inputBorder(Colors.black12),
      enabledBorder: inputBorder(Colors.black26),
      focusedBorder: inputBorder(colorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
    ),
  );
}
