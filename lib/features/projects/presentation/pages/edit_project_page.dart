import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/atoms/numbered_step_label.dart';
import '../../../../core/ui/atoms/primary_button.dart';
import '../../../../core/ui/molecules/labeled_text_field.dart';
import '../../di/projects_module.dart';
import '../../domain/entities/project.dart';
import '../view_models/project_form_view_model.dart';
import '../widgets/city_picker.dart';
import '../widgets/work_type_choice_card.dart';

/// Edit version of the project form. Reuses the same atoms/molecules as
/// AddProjectPage but exposes more fields (cliente, área, presupuesto,
/// descripción, estado) ya que en edit sí pueden manipularse.
class EditProjectPage extends StatelessWidget {
  const EditProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ModalRoute.of(context)!.settings.arguments as Project;
    final module = context.read<ProjectsModule>();
    return ChangeNotifierProvider<ProjectFormViewModel>(
      create: (_) => module.projectFormViewModelFactory(editing: project),
      child: _EditProjectView(project: project),
    );
  }
}

class _EditProjectView extends StatefulWidget {
  final Project project;
  const _EditProjectView({required this.project});

  @override
  State<_EditProjectView> createState() => _EditProjectViewState();
}

class _EditProjectViewState extends State<_EditProjectView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.project.name);
  late final TextEditingController _city =
      TextEditingController(text: widget.project.location ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.project.description ?? '');
  late final TextEditingController _clientName =
      TextEditingController(text: widget.project.clientName ?? '');
  late final TextEditingController _area =
      TextEditingController(text: widget.project.area ?? '');
  late final TextEditingController _totalBudget =
      TextEditingController(text: widget.project.totalBudget ?? '');

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _description.dispose();
    _clientName.dispose();
    _area.dispose();
    _totalBudget.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ProjectFormViewModel>();
    final result = await vm.save(
      name: _name.text.trim(),
      description: _description.text.trim(),
      clientName: _clientName.text.trim(),
      location: _city.text.trim(),
      area: _area.text.trim(),
      totalBudget: _totalBudget.text.trim(),
    );
    if (!mounted) return;
    if (result != null) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectFormViewModel>(
      builder: (context, vm, _) {
        if (vm.state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg = vm.state.errorMessage;
            if (msg == null || !mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
            );
            vm.clearError();
          });
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            title: const Text(
              'Editar proyecto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NumberedStepLabel(step: 1, label: 'NOMBRE DEL PROYECTO'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _name,
                      enabled: !vm.state.isSubmitting,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresa un nombre';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    const NumberedStepLabel(step: 2, label: 'TIPO DE TRABAJO'),
                    const SizedBox(height: 10),
                    _workTypeGrid(vm),
                    const SizedBox(height: 22),
                    const NumberedStepLabel(step: 3, label: 'CIUDAD'),
                    const SizedBox(height: 10),
                    CityPicker(
                      controller: _city,
                      enabled: !vm.state.isSubmitting,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    LabeledTextField(
                      label: 'CLIENTE',
                      controller: _clientName,
                      enabled: !vm.state.isSubmitting,
                      hintText: 'Opcional',
                    ),
                    const SizedBox(height: 18),
                    LabeledTextField(
                      label: 'ÁREA (m²)',
                      controller: _area,
                      enabled: !vm.state.isSubmitting,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autocorrect: false,
                      validator: _decimalValidator,
                    ),
                    const SizedBox(height: 18),
                    LabeledTextField(
                      label: 'PRESUPUESTO TOTAL',
                      controller: _totalBudget,
                      enabled: !vm.state.isSubmitting,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autocorrect: false,
                      validator: _decimalValidator,
                    ),
                    const SizedBox(height: 18),
                    LabeledTextField(
                      label: 'DESCRIPCIÓN',
                      controller: _description,
                      enabled: !vm.state.isSubmitting,
                      hintText: 'Opcional',
                    ),
                    const SizedBox(height: 18),
                    _statusSelector(vm),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Guardar cambios',
                      trailingIcon: Icons.check,
                      loading: vm.state.isSubmitting,
                      onPressed: vm.state.isSubmitting ? null : _onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? _decimalValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v.trim())) {
      return 'Número con hasta 2 decimales';
    }
    return null;
  }

  Widget _workTypeGrid(ProjectFormViewModel vm) {
    final types = WorkType.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: types.length,
      itemBuilder: (context, i) {
        final t = types[i];
        return WorkTypeChoiceCard(
          workType: t,
          selected: vm.state.workType == t,
          onTap: vm.state.isSubmitting ? null : () => vm.setWorkType(t),
        );
      },
    );
  }

  Widget _statusSelector(ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ESTADO', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProjectStatus.values.map((s) {
            final selected = vm.state.status == s;
            return ChoiceChip(
              label: Text(s.label),
              selected: selected,
              onSelected:
                  vm.state.isSubmitting ? null : (_) => vm.setStatus(s),
            );
          }).toList(),
        ),
      ],
    );
  }
}
