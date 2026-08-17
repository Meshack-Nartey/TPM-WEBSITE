import 'package:flutter/material.dart';

import '../theme/tpm_theme.dart';

/// The gold uppercase label that opens almost every section on both surfaces.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = TpmColors.goldDeep, this.size = 10.5});

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TpmText.eyebrow(color: color, size: size),
      );
}

/// Section opener used on the light surface: gold eyebrow over a serif title.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.titleSize = 27,
    this.onBack,
  });

  final String eyebrow;
  final String title;
  final double titleSize;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 3),
        Text(title, style: TpmText.display(titleSize, height: 1.1)),
      ],
    );

    if (onBack == null) return heading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleBackButton(onTap: onBack!),
        const SizedBox(width: 12),
        Flexible(child: heading),
      ],
    );
  }
}

/// Round back affordance. Indigo wash on light, hairline-on-black in the portal.
class CircleBackButton extends StatelessWidget {
  const CircleBackButton({
    super.key,
    required this.onTap,
    this.size = 34,
    this.dark = false,
    this.icon = Icons.chevron_left_rounded,
  });

  final VoidCallback onTap;
  final double size;
  final bool dark;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? TpmColors.nightSurface : TpmColors.tintIndigo,
      shape: dark
          ? CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.12)))
          : const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.62,
            color: dark ? TpmColors.portalGold : TpmColors.navy,
          ),
        ),
      ),
    );
  }
}

/// White card on the member surface.
class TpmCard extends StatelessWidget {
  const TpmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.onTap,
    this.color = TpmColors.surface,
    this.border,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color color;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadow ?? TpmShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return decorated;
  }
}

/// Near-black card with a hairline edge — the portal's equivalent of TpmCard.
class PortalCard extends StatelessWidget {
  const PortalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.onTap,
    this.color = TpmColors.nightSurface,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Rounded square holding an icon — the repeated "tile" motif on both surfaces.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 40,
    this.radius = 11,
    this.gradient,
    this.iconSize,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double radius;
  final Gradient? gradient;
  final double? iconSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(icon, color: foreground, size: iconSize ?? size * 0.45),
      );
}

/// Small rounded-full label. Used for tags, statuses and roles everywhere.
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    required this.foreground,
    required this.background,
    this.borderColor,
    this.icon,
    this.uppercase = true,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;
  final IconData? icon;
  final bool uppercase;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            uppercase ? label.toUpperCase() : label,
            style: TpmText.body(
              fontSize,
              color: foreground,
              weight: FontWeight.w700,
              letterSpacing: uppercase ? 1.2 : 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width primary action. Blue on the member surface, gold in the portal.
class TpmButton extends StatelessWidget {
  const TpmButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient = TpmColors.blueGradient,
    this.foreground = Colors.white,
    this.height = 52,
    this.radius = 14,
    this.fontSize = 14.5,
  });

  /// Gold-on-black portal variant.
  const TpmButton.gold({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 52,
    this.radius = 14,
    this.fontSize = 14.5,
  })  : gradient = TpmColors.portalGoldGradient,
        foreground = TpmColors.night;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient gradient;
  final Color foreground;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 3, color: foreground),
                    const SizedBox(width: 9),
                  ],
                  // Long labels shrink rather than overflow — button widths are
                  // set by the layout around them, not by the text inside.
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TpmText.body(
                        fontSize,
                        color: foreground,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action, themed for either surface.
class TpmOutlineButton extends StatelessWidget {
  const TpmOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.foreground = TpmColors.navy,
    this.background = TpmColors.surface,
    this.borderColor = TpmColors.hairline,
    this.height = 50,
    this.radius = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 17, color: foreground),
                    const SizedBox(width: 9),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TpmText.body(13.8, color: foreground, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Photograph with the brand's navy scrim and gold highlight over it, so real
/// photography sits inside the palette instead of fighting it.
class BrandedPhoto extends StatelessWidget {
  const BrandedPhoto({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.scrimOpacity = 0.45,
    this.goldOpacity = 0.35,
    this.alignment = Alignment.center,
  });

  final String asset;
  final BoxFit fit;
  final double scrimOpacity;
  final double goldOpacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: fit, alignment: alignment),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TpmColors.deepNavy.withValues(alpha: scrimOpacity * 0.7),
                TpmColors.navy.withValues(alpha: scrimOpacity),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: TpmColors.goldGlow(opacity: goldOpacity)),
        ),
      ],
    );
  }
}

/// Labelled text field. `dark` switches it into the portal's palette.
class TpmField extends StatelessWidget {
  const TpmField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.dark = false,
    this.obscure = false,
    this.trailing,
    this.maxLines = 1,
    this.controller,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final bool dark;
  final bool obscure;
  final Widget? trailing;
  final int maxLines;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final labelColor = dark ? Colors.white.withValues(alpha: 0.5) : TpmColors.goldDeep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TpmText.eyebrow(color: labelColor, size: 10, tracking: 1.2),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: dark ? TpmColors.nightSurface : TpmColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.1) : TpmColors.hairline,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
                  child: Icon(
                    icon,
                    size: 17,
                    color: dark ? TpmColors.portalGold : TpmColors.faint,
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  maxLines: maxLines,
                  style: TpmText.body(
                    14.5,
                    color: dark ? TpmColors.portalInk : TpmColors.ink,
                  ),
                  cursorColor: dark ? TpmColors.portalGold : TpmColors.navy,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TpmText.body(
                      14.5,
                      color: dark ? Colors.white.withValues(alpha: 0.3) : TpmColors.faint,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: icon == null ? 0 : 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

/// Selectable chip row item, used for media filters, statuses and compose tags.
class ChoiceChipPill extends StatelessWidget {
  const ChoiceChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dark = false,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dark;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;

    if (dark) {
      bg = selected ? TpmColors.portalGold.withValues(alpha: 0.12) : TpmColors.nightSurface;
      fg = selected ? TpmColors.portalGold : Colors.white.withValues(alpha: 0.55);
      border = selected ? TpmColors.portalGold : Colors.white.withValues(alpha: 0.12);
    } else {
      bg = selected ? TpmColors.navy : TpmColors.surface;
      fg = selected ? Colors.white : TpmColors.subtle;
      border = selected ? TpmColors.navy : TpmColors.hairline;
    }

    final chip = Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TpmText.body(12.2, color: fg, weight: FontWeight.w600),
          ),
        ),
      ),
    );

    return expand ? Expanded(child: chip) : chip;
  }
}

/// Circular initials avatar.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 40,
    this.fontSize,
  });

  final String initials;
  final Color color;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(
          initials,
          style: TpmText.body(
            fontSize ?? size * 0.32,
            color: Colors.white,
            weight: FontWeight.w700,
          ),
        ),
      );
}
