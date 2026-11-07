import 'package:flutter/material.dart';

import 'app_chip.dart';
import 'dish_image.dart';
import 'tokens.dart';

/// Thẻ một món trong mâm: ảnh, vai trò (Món chính/Canh/Rau/Cơm/Tráng miệng), tên, protein + kcal. Chạm mở công thức.
class DishCard extends StatelessWidget {
  const DishCard({
    required this.roleLabel,
    required this.name,
    required this.proteinText,
    required this.kcalText,
    required this.proteinLabel,
    required this.kcalLabel,
    this.group,
    this.image,
    this.onTap,
    super.key,
  });

  final String roleLabel;
  final String name;
  final String proteinText;
  final String kcalText;
  final String proteinLabel;
  final String kcalLabel;
  final ImageGroup? group;
  final String? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      label:
          '$roleLabel: $name. $proteinLabel $proteinText, $kcalLabel $kcalText',
      excludeSemantics: true,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  DishImage(image: image, group: group, size: 64),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          roleLabel.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: .6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            MacroChip(
                              kind: MacroKind.protein,
                              value: proteinText,
                              label: proteinLabel,
                            ),
                            MacroChip(
                              kind: MacroKind.kcal,
                              value: kcalText,
                              label: kcalLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
