import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/atoms/numbered_step_label.dart';
import '../../../../core/ui/atoms/primary_button.dart';
import '../../di/projects_module.dart';
import '../../domain/entities/project.dart';
import '../view_models/project_form_view_model.dart';
import '../Components/city_picker.dart';
import '../Components/prices_update_banner.dart';
import '../Components/work_type_choice_card.dart';

class AddProjectPage extends StatelessWidget {
  const AddProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final module = context.read<ProjectsModule>();
    return ChangeNotifierProvider<ProjectFormViewModel>(
      create: (_) => module.projectFormViewModelFactory(),
      child: const _AddProjectView(),
    );
  }
}

class _AddProjectView extends StatefulWidget {
  const _AddProjectView();

  @override
  State<_AddProjectView> createState() => _AddProjectViewState();
}

class _AddProjectViewState extends State<_AddProjectView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController(text: 'Tuxtla Gutiérrez');

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ProjectFormViewModel>();
    final result = await vm.save(
      name: _name.text.trim(),
      location: _city.text.trim(),
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topBar(),
                    const SizedBox(height: 18),
                    const NumberedStepLabel(step: 1, label: 'NOMBRE DEL PROYECTO'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _name,
                      enabled: !vm.state.isSubmitting,
                      decoration: const InputDecoration(
                        hintText: 'Baño principal · Casa Rodríguez',
                      ),
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
                    const SizedBox(height: 18),
                    PricesUpdateBanner(
                      city: _city.text.trim().isEmpty
                          ? 'tu ciudad'
                          : _city.text.trim(),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Comenzar escaneo',
                      trailingIcon: Icons.arrow_forward,
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

  Widget _topBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.border),
                ),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo proyecto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '03 CAMPOS  ·  TOMA UN MINUTO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
}
