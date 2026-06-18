import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../di/projects_module.dart';
import '../../domain/entities/project.dart';
import '../view_models/project_detail_view_model.dart';
import '../widgets/project_status_chip.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final module = context.read<ProjectsModule>();
    return ChangeNotifierProvider<ProjectDetailViewModel>(
      create: (_) => module.projectDetailViewModelFactory(id)..load(),
      child: const _ProjectDetailView(),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView();

  Future<void> _onEdit(BuildContext context, Project p) async {
    final updated = await Navigator.of(context).pushNamed(
      Routes.editProject,
      arguments: p,
    );
    if (updated == true && context.mounted) {
      await context.read<ProjectDetailViewModel>().load();
    }
  }

  Future<void> _onDelete(BuildContext context, ProjectDetailViewModel vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final deleted = await vm.delete();
    if (deleted && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectDetailViewModel>(
      builder: (context, vm, _) {
        if (vm.state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg = vm.state.errorMessage;
            if (msg == null || !context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
            );
            vm.clearError();
          });
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: const Text(
              'Detalle del proyecto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              if (vm.state.project != null)
                IconButton(
                  tooltip: 'Editar',
                  onPressed: vm.state.isDeleting
                      ? null
                      : () => _onEdit(context, vm.state.project!),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (vm.state.project != null)
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: vm.state.isDeleting ? null : () => _onDelete(context, vm),
                  icon: vm.state.isDeleting
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
            ],
          ),
          body: _body(vm),
        );
      },
    );
  }

  Widget _body(ProjectDetailViewModel vm) {
    if (vm.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final p = vm.state.project;
    if (p == null) {
      return const Center(
        child: Text(
          'No se encontró el proyecto',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ProjectStatusChip(p.status),
          ],
        ),
        const SizedBox(height: 12),
        _kv('Tipo de trabajo', p.workType.label),
        if (p.clientName != null) _kv('Cliente', p.clientName!),
        if (p.location != null) _kv('Ciudad', p.location!),
        if (p.area != null) _kv('Área', '${p.area} m²'),
        if (p.totalBudget != null) _kv('Presupuesto', '\$${p.totalBudget}'),
        const SizedBox(height: 12),
        if (p.description != null) ...[
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.label,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.description!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
