import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';

/// `.category-tile` from the mockup. The visual tile can stay compact, but
/// the tap target is padded out to the 48x48dp accessibility minimum
/// regardless of how small the icon/label look — see
/// docs-mobile/04-design-system.md "Touch targets".
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isPriority = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool isPriority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ObsRadius.tile),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Stack(
            children: [
              // Positioned.fill so the visible card stretches to the full
              // grid cell — without this, the Column's mainAxisSize.min
              // let the card shrink to its content and sit pinned at the
              // Stack's default top-left, leaving a dead gap below every
              // tile that read as a broken/too-small grid.
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: ObsSpace.sm,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? ObsColors.brandTint
                        : ObsColors.surface,
                    border: Border.all(
                      color: selected ? ObsColors.brand : ObsColors.line,
                      width: selected ? 1.6 : 1,
                    ),
                    borderRadius: BorderRadius.circular(ObsRadius.tile),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? ObsColors.brand
                              : ObsColors.brandTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 17,
                          color: selected ? Colors.white : ObsColors.brandInk,
                        ),
                      ),
                      const SizedBox(height: ObsSpace.xs + 2),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: ObsFontSize.xs,
                          fontWeight: FontWeight.w700,
                          color: ObsColors.ink,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isPriority)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: ObsColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
