import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/v_logo.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Inicio', 'Buscar', 'Historial', 'Perfil'];
  static const _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.history,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const VLogo(size: 26),
            const SizedBox(width: 10),
            const Text(
              'VisionPrice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              icon: const Icon(Icons.logout,
                  color: AppColors.textSecondary, size: 20),
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
      ),
      body: _TabPlaceholder(
        title: _titles[_index],
        icon: _icons[_index],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: List.generate(_titles.length, (i) {
          return NavigationDestination(
            icon: Icon(_icons[i], color: AppColors.textSecondary),
            selectedIcon: Icon(_icons[i], color: AppColors.primary),
            label: _titles[i],
          );
        }),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  const _TabPlaceholder({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Próximamente',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
