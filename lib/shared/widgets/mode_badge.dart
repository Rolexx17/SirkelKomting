import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../data/models/sirkel.dart';
import '../../features/sirkel/sirkel_strings.dart';

/// Label kecil mode belajar (ikon + "Online"/"Offline") di atas sampul atau di Detail.
class ModeBadge extends StatelessWidget {
  const ModeBadge({super.key, required this.mode});

  final ModeBelajar mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final online = mode == ModeBelajar.online;

    // P5: Container berhias dengan latar surface transparan 92%.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            online ? Icons.videocam : Icons.place,
            size: AppSizes.iconS,
            color: scheme.onSurface,
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            online ? SirkelStrings.online : SirkelStrings.offline,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
