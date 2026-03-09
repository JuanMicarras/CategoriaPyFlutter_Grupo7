import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importamos el tema (si lo tienes configurado en la carpeta core)
// import 'core/app_theme.dart';

// Importamos las Vistas
import 'features/auth/ui/views/login_page.dart';
import 'features/auth/ui/views/signup_page.dart';
// import 'features/home/ui/views/home_page.dart';   // Descomenta cuando la crees

// Importamos los Bindings
import 'features/auth/ui/bindings/auth_binding.dart';

void main() {
  runApp(const PeerSyncApp());
}

class PeerSyncApp extends StatelessWidget {
  const PeerSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos GetMaterialApp en lugar de MaterialApp. ¡Esto es innegociable!
    // Es lo que le da a GetX el control sobre el contexto, las rutas y los estados globales.
    return GetMaterialApp(
      title: 'PeerSync',
      debugShowCheckedModeBanner: false,
      
      // Si tienes tu archivo de tema en core/app_theme.dart, lo usas aquí:
      // theme: AppTheme.lightTheme, 
      
      // Definimos la ruta inicial
      initialRoute: '/login',
      
      // Definimos el árbol de rutas (GetPages)
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: AuthBinding(), 
          // El binding inyecta IAuthRepository y AuthController 
          // JUSTO ANTES de que la LoginPage se renderice.
        ),
        
        
        GetPage(
          name: '/signup',
          page: () => SignUpPage(),
          binding: AuthBinding(), 
        ),/*
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          // binding: HomeBinding(), // Aquí inyectaremos los casos de uso de los cursos/grupos luego
        ),
        */
      ],
    );
  }
}