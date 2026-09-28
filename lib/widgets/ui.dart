import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Small building blocks shared by the screens. Everything here reads its
/// values from the theme tokens.

/// Dark secondary button (ink fill), 52 high — «Davom etish»,
/// «Darsni ko'rdim» in the mockups.
class InverseButton extends StatelessWidget {
  const InverseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.inverse,
        foregroundColor: colors.onInverse,
        minimumSize: const Size.fromHeight(AppSize.button),
        textStyle: AppText.button,
      ),
      onPressed: onPressed,
      child: _ButtonLabel(label: label, icon: icon, trailingIcon: trailingIcon),
    );
  }
}

/// Primary (amber) button with optional icons around the label.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.busy = false,
    this.height = AppSize.buttonTall,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool busy;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(minimumSize: Size.fromHeight(height)),
      onPressed: busy ? null : onPressed,
      child: busy
          ? SizedBox.square(
              dimension: AppSpace.s6,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: context.colors.ink,
              ),
            )
          : _ButtonLabel(label: label, icon: icon, trailingIcon: trailingIcon),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, this.icon, this.trailingIcon});

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSize.iconBtn),
          const SizedBox(width: AppSpace.s2),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpace.s2),
          Icon(trailingIcon, size: AppSize.iconBtn),
        ],
      ],
    );
  }
}

/// 44×44 rounded tile with an icon on a tinted fill.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, this.onCard = false});

  final IconData icon;

  /// White tile (for muted panels) instead of the brand tint.
  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppSize.iconTile,
      height: AppSize.iconTile,
      decoration: BoxDecoration(
        color: onCard ? colors.surfaceCard : colors.brandTint,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: colors.brandStrong, size: AppSize.icon),
    );
  }
}

/// Section title (Baloo 2) with an optional link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppText.heading.copyWith(color: context.colors.ink),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

/// Bordered white panel (radius-md) — the default container for lists.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.s4),
    this.onTap,
    this.color,
    this.borderColor,
    this.bordered = true,
    this.radius = AppRadius.md,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  /// false: a flat fill without an outline (muted panels).
  final bool bordered;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: bordered
          ? BorderSide(color: borderColor ?? colors.border, width: borderWidth)
          : BorderSide.none,
    );
    return Material(
      color: color ?? colors.surfaceCard,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Muted hint panel with an icon (mockup: login note, homework in review).
class NotePanel extends StatelessWidget {
  const NotePanel({
    super.key,
    required this.icon,
    required this.text,
    this.title,
    this.onTap,
    this.tile = false,
  });

  final IconData icon;
  final String? title;
  final String text;
  final VoidCallback? onTap;

  /// Show the icon in a white tile instead of bare.
  final bool tile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      color: colors.surfaceMuted,
      bordered: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.card,
      ),
      child: Row(
        crossAxisAlignment: tile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (tile)
            IconTile(icon: icon, onCard: true)
          else
            Icon(icon, size: AppSize.iconBtn, color: colors.brandStrong),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppText.bodyStrong.copyWith(color: colors.ink),
                  ),
                Text(
                  text,
                  style: AppText.caption.copyWith(
                    color: colors.inkSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded status pill: tinted fill, full-strength text.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.tileGap,
        vertical: AppSpace.s1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppText.chip.copyWith(
          color: Color.lerp(color, context.colors.ink, 0.25),
        ),
      ),
    );
  }
}

/// Thin progress bar on a muted track (radius-pill).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = AppSize.progressBar,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: color,
        backgroundColor: context.colors.surfaceMuted,
      ),
    );
  }
}

/// Static placeholder block for loading states.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = AppRadius.md,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.colors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A generic list-shaped loading skeleton.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.items = 4, this.itemHeight = 72});

  final int items;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.s5),
        children: [
          const SkeletonBox(height: AppSpace.s8, width: 180),
          const SizedBox(height: AppSpace.s4),
          for (var i = 0; i < items; i++) ...[
            SkeletonBox(height: itemHeight),
            const SizedBox(height: AppSpace.s3),
          ],
        ],
      ),
    );
  }
}
