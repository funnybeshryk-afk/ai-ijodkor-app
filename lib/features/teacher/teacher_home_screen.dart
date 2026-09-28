import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../widgets/home_placeholder.dart';

/// Used by teachers and admins. Stage 4 will replace this stub.
class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => HomePlaceholder(
    title: context.l10n.teacherHomeTitle,
    icon: Icons.co_present_outlined,
  );
}
