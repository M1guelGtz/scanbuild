import 'package:flutter/material.dart';

import '../organisms/brand_header.dart';

class AuthTemplate extends StatelessWidget {
  final Widget child;

  final EdgeInsets padding;

  const AuthTemplate({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
