import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const bento = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowInk,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),
      blurRadius: 12,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  /// Shadow stack used by the Nature Distilled login motif overlay.
  /// Kept here to avoid ad-hoc constants inside shared primitives.
  static const motifOverlay = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowInk,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF),
      blurRadius: 12,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  static const pressed = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowInk,
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -6,
    ),
  ];

  /// Alias used by contract samples.
  static const soft = bento;

  static const capsuleNav = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowInk,
      blurRadius: 22,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];
}
