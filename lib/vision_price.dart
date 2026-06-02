import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/api_config.dart';
import 'core/network/api_client.dart';
import 'core/routing/routes.dart';
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

/// App-level composition root. Owns long-lived singletons (the two ApiClients
/// + AuthModule + ProjectsModule) and exposes them down the tree via
/// Provider so every page can pull what it needs without global state.
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
        theme: AppTheme.light(),
        themeMode: ThemeMode.system,
        darkTheme: AppTheme.dark(),
        initialRoute: Routes.integrityGate,
        routes: {
          Routes.integrityGate: (_) => const IntegrityGatePage(),
          Routes.blocked: (_) => const BlockedPage(),
          Routes.login: (_) => const LoginPage(),
          Routes.forgot: (_) => const ForgotPasswordPage(),
          Routes.register: (_) => const RegisterPage(),

          // Projects feature
          Routes.projects: (_) => const DashboardPage(),
          Routes.addProject: (_) => const AddProjectPage(),
          Routes.editProject: (_) => const EditProjectPage(),
          Routes.projectDetail: (_) => const ProjectDetailPage(),
        },
      ),
    );
  }
}
