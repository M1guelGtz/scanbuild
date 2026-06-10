/// Single source of truth for named routes. Prevents typos in
/// Navigator.pushNamed calls scattered across the app.
class Routes {
  Routes._();

  static const String integrityGate = '/';
  static const String blocked = '/blocked';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';

  // Projects feature
  static const String projects = '/projects';
  static const String addProject = '/projects/new';
  static const String editProject = '/projects/edit';
  static const String projectDetail = '/projects/detail';

  // Seguridad: configuración del borrado remoto de emergencia.
  static const String keywordConfig = '/security/keyword';
}
