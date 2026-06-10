import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/api_config.dart';
import 'core/config/inactivity_config.dart';
import 'core/network/api_client.dart';
import 'core/routing/routes.dart';
import 'core/session/inactivity_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/di/auth_module.dart';
import 'features/auth/presentation/pages/blocked_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/integrity_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/projects/di/projects_module.dart';
import 'features/projects/presentation/pages/add_project_page.dart';
import 'features/projects/presentation/pages/edit_project_page.dart';
import 'features/projects/presentation/pages/project_detail_page.dart';
import 'features/projects/presentation/pages/dashboard_page.dart';
import 'screens/keyword_config_screen.dart';


class VisionPriceApp extends StatefulWidget {
  const VisionPriceApp({super.key});

  @override
  State<VisionPriceApp> createState() => _VisionPriceAppState();
}

class _VisionPriceAppState extends State<VisionPriceApp> {
  late final ApiClient _authApiClient;
  late final ApiClient _projectsApiClient;
  late final AuthModule _authModule;
  late final ProjectsModule _projectsModule;

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _authApiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
    _projectsApiClient = ApiClient(baseUrl: ApiConfig.projectsBaseUrl);
    _authModule = AuthModule.create(apiClient: _authApiClient);
    _projectsModule = ProjectsModule.create(
      projectsApiClient: _projectsApiClient,
      tokenStorage: _authModule.tokenStorage,
    );
  }


  Future<void> _onIdleTimeout() async {
    final access = await _authModule.tokenStorage.readAccessToken();
    if (access == null) return; 

    await _authModule.expireSessionForInactivityUseCase(
      idleTimeout: InactivityConfig.timeout,
    );

    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.login,
      (_) => false,
    );
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada por inactividad.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthModule>.value(value: _authModule),
        Provider<ProjectsModule>.value(value: _projectsModule),
      ],
      child: MaterialApp(
        title: 'VisionPrice',
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messengerKey,
        theme: AppTheme.light(),
        themeMode: ThemeMode.system,
        darkTheme: AppTheme.dark(),
        builder: (context, child) => InactivityScope(
          timeout: InactivityConfig.timeout,
          onTimeout: _onIdleTimeout,
          child: child ?? const SizedBox.shrink(),
        ),
        // Para la DEMO del borrado remoto se arranca directamente en la pantalla
        // de configuración. Para volver al flujo normal de la app, elimina el
        // `onGenerateInitialRoutes` y pon `initialRoute: Routes.integrityGate`.
        //
        // OJO: `initialRoute` con barras ('/security/keyword') haría que Flutter
        // monte también la ruta intermedia '/' (IntegrityGatePage), que redirige
        // al login. Por eso forzamos una pila inicial con UNA sola pantalla.
        initialRoute: Routes.keywordConfig,
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(builder: (_) => const KeywordConfigScreen()),
        ],
        routes: {
          Routes.integrityGate: (_) => const IntegrityGatePage(),
          Routes.blocked: (_) => const BlockedPage(),
          Routes.login: (_) => const LoginPage(),
          Routes.forgot: (_) => const ForgotPasswordPage(),
          Routes.register: (_) => const RegisterPage(),

          Routes.projects: (_) => const DashboardPage(),
          Routes.addProject: (_) => const AddProjectPage(),
          Routes.editProject: (_) => const EditProjectPage(),
          Routes.projectDetail: (_) => const ProjectDetailPage(),

          // Seguridad: pantalla del borrado remoto de emergencia.
          Routes.keywordConfig: (_) => const KeywordConfigScreen(),
        },
      ),
    );
  }
}
