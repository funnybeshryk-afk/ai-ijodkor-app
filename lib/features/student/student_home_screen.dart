import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../widgets/home_placeholder.dart';

/// Stage 2 will replace this stub.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => HomePlaceholder(
    title: context.l10n.studentHomeTitle,
    icon: Icons.school_outlined,
  );
}
