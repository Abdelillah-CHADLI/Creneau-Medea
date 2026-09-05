import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40, this.heroTag});

  final double size;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * .22),
      child: Image.asset(
        'assets/images/app_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'شعار Créneau Médéa',
      ),
    );
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}

class BrandLogoTile extends StatelessWidget {
  const BrandLogoTile({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(size * .09),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(size * .24),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x140F172A),
          blurRadius: 24,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: BrandLogo(size: size, heroTag: 'app-logo'),
  );
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showLogo;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: leading ?? (showLogo ? const BrandLogo(size: 38) : null),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        SizedBox(
          width: 48,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: trailing,
          ),
        ),
      ],
    ),
  );
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = AppColors.card,
    this.borderColor = AppColors.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
    final interactive = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: content,
            ),
          );
    return margin == null
        ? interactive
        : Padding(padding: margin!, child: interactive);
  }
}

enum AppStatusTone { success, warning, danger, info, neutral }

class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.tone = AppStatusTone.neutral,
  });

  final String label;
  final IconData? icon;
  final AppStatusTone tone;

  Color get _foreground => switch (tone) {
    AppStatusTone.success => AppColors.primary,
    AppStatusTone.warning => AppColors.warning,
    AppStatusTone.danger => AppColors.tertiary,
    AppStatusTone.info => AppColors.info,
    AppStatusTone.neutral => AppColors.neutralMuted,
  };

  Color get _background => switch (tone) {
    AppStatusTone.success => AppColors.primarySurface,
    AppStatusTone.warning => AppColors.warningSurface,
    AppStatusTone.danger => AppColors.tertiarySurface,
    AppStatusTone.info => AppColors.infoSurface,
    AppStatusTone.neutral => AppColors.neutralSurface,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: _background,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _foreground.withAlpha(40)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: _foreground),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class SquadMeter extends StatelessWidget {
  const SquadMeter({
    super.key,
    required this.confirmed,
    required this.capacity,
    this.compact = false,
  });

  final int confirmed;
  final int capacity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final safeCapacity = capacity.clamp(1, 13);
    final safeConfirmed = confirmed.clamp(0, safeCapacity);
    return Semantics(
      label: '$safeConfirmed من $safeCapacity لاعبين مؤكدين',
      child: Row(
        children: List.generate(
          safeCapacity,
          (index) => Expanded(
            child: Container(
              height: compact ? 5 : 7,
              margin: EdgeInsetsDirectional.only(
                end: index == safeCapacity - 1 ? 0 : 3,
              ),
              decoration: BoxDecoration(
                color: index < safeConfirmed
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null)
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      // ignore: use_null_aware_elements
      if (action != null) action!,
    ],
  );
}

class AppConstrainedContent extends StatelessWidget {
  const AppConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 760,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
