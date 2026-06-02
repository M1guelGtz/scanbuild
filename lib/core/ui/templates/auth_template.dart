import 'package:flutter/material.dart';

import '../organisms/brand_header.dart';

/// Reusable page skeleton for the authentication-related screens: brand
/// header on top, a scrollable form area below, both inside SafeArea.
/// The actual page content (form fields, buttons, footer link) is provided
/// by the caller through [child] so each page composes its own organisms
/// without duplicating the surrounding layout.
class AuthTemplate extends StatelessWidget {
  final Widget child;

  /// Padding around the whole scrollable area.
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
