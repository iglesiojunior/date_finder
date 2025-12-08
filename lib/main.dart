import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart'; // Importe o pacote
import 'views/login_page.dart';
import 'views/reset_password_page.dart'; // Importe a tela de reset

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>(); // Chave para navegação
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // O Stream já entrega o link inicial automaticamente quando você começa a ouvir
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      debugPrint('Erro no Deep Link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // O formato esperado é: datefinder://reset-password?token=XYZ
    if (uri.host == 'reset-password') {
      final String? token = uri.queryParameters['token'];
      
      if (token != null) {
        // Navega para a tela de Reset enviando o token
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(token: token),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Importante vincular a chave aqui
      title: 'Date Spot Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}