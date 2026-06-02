import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/di/auth_module.dart';
import '../../../auth/presentation/view_models/home_view_model.dart';
import '../../di/projects_module.dart';
import '../../domain/entities/project.dart';
import '../view_models/dashboard_view_model.dart';

/// Dashboard intentionally rebuilt with the simplest widget tree possible
/// to dodge Flutter 3.44 rendering glitches we hit with Stack/Material/
/// CustomPaint combinations. Visually keeps the prototype layout:
/// fecha + saludo + avatar · KPIs · sección PROYECTOS · cards · FAB.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsModule = context.read<ProjectsModule>();
    final authModule = context.read<AuthModule>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => projectsModule.dashboardViewModelFactory(
            tryRestoreSession: authModule.tryRestoreSessionUseCase,
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => authModule.homeViewModelFactory(),
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().load();
    });
  }

  Future<void> _onLogout() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final homeVm = context.read<HomeViewModel>();
    try {
      await homeVm.signOut();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sesión local cerrada.')),
      );
    }
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }

  Future<void> _onAddProject() async {
    final created = await Navigator.of(context).pushNamed(Routes.addProject);
    if (created == true && mounted) {
      await context.read<DashboardViewModel>().load();
    }
  }

  Future<void> _onTapProject(String id) async {
    await Navigator.of(context).pushNamed(Routes.projectDetail, arguments: id);
    if (mounted) {
      await context.read<DashboardViewModel>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            // Surface backend errors via SnackBar without overlaying widgets.
            if (vm.state.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final msg = vm.state.errorMessage;
                if (msg == null || !mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
                vm.clearError();
              });
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(vm),
                  const SizedBox(height: 20),
                  _kpiRow(vm),
                  const SizedBox(height: 24),
                  _sectionTitle(),
                  const SizedBox(height: 12),
                  _projectsBody(vm),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddProject,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- Header ----------

  Widget _header(DashboardViewModel vm) {
    final name = vm.user?.name ?? 'usuario';
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(now),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_greeting(now)}, ${_firstName(name)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _onLogout,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _initials(name),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- KPI cards ----------

  Widget _kpiRow(DashboardViewModel vm) {
    return Row(
      children: [
        Expanded(child: _kpi(vm.state.activeCount.toString(), 'ACTIVOS')),
        const SizedBox(width: 10),
        Expanded(child: _kpi(vm.state.quotedCount.toString(), 'EN COTIZACIÓN')),
      ],
    );
  }

  Widget _kpi(String value, String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Section title ----------

  Widget _sectionTitle() {
    return const Row(
      children: [
        Text(
          'PROYECTOS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.label,
          ),
        ),
        Spacer(),
        Text(
          'Ver todos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ---------- Projects list ----------

  Widget _projectsBody(DashboardViewModel vm) {
    if (vm.state.isLoading && vm.state.projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.state.projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.folder_open, size: 40, color: AppColors.textSecondary),
            SizedBox(height: 10),
            Text(
              'Aún no tienes proyectos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Toca el botón + para crear el primero.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final p in vm.state.projects) ...[
          _projectCard(p),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _projectCard(Project p) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTapProject(p.id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumbnail(p.workType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _metaLine(p),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusPill(p.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  p.workType.cardLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  p.totalBudget == null ? '—' : '\$ ${p.totalBudget}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(WorkType type) {
    final IconData icon;
    switch (type) {
      case WorkType.floor:    icon = Icons.view_in_ar_outlined; break;
      case WorkType.wall:     icon = Icons.view_quilt_outlined; break;
      case WorkType.ceiling:  icon = Icons.roofing_outlined; break;
      case WorkType.combined: icon = Icons.dashboard_customize_outlined; break;
    }
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1623),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 26, color: const Color(0xFF6C8BFF)),
    );
  }

  Widget _statusPill(ProjectStatus s) {
    final Color color;
    switch (s) {
      case ProjectStatus.measured:   color = const Color(0xFFE08A2A); break;
      case ProjectStatus.quoted:     color = const Color(0xFF2F6FED); break;
      case ProjectStatus.inProgress: color = const Color(0xFF1F9E5A); break;
      case ProjectStatus.completed:  color = const Color(0xFF6B7280); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }

  String _metaLine(Project p) {
    final parts = <String>[];
    if (p.location != null) parts.add(p.location!);
    if (p.area != null) parts.add('${p.area} m²');
    parts.add(_relative(p.updatedAt));
    return parts.join('  ·  ');
  }

  // ---------- Helpers ----------

  static const _months = ['ENE','FEB','MAR','ABR','MAY','JUN','JUL','AGO','SEP','OCT','NOV','DIC'];
  static const _weekdays = ['LUNES','MARTES','MIÉRCOLES','JUEVES','VIERNES','SÁBADO','DOMINGO'];

  String _formatDate(DateTime d) {
    final m = (d.month >= 1 && d.month <= 12) ? _months[d.month - 1] : '';
    final w = (d.weekday >= 1 && d.weekday <= 7) ? _weekdays[d.weekday - 1] : '';
    return '${d.day} $m  ·  $w';
  }

  String _greeting(DateTime d) {
    final h = d.hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _firstName(String full) {
    final trimmed = full.trim();
    if (trimmed.isEmpty) return 'Bienvenido';
    return trimmed.split(' ').first;
  }

  String _initials(String full) {
    final parts = full.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _relative(DateTime updatedAt) {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 30) return 'hace ${diff.inDays} días';
    final months = diff.inDays ~/ 30;
    return 'hace $months ${months == 1 ? "mes" : "meses"}';
  }
}
