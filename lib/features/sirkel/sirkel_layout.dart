import 'package:flutter/widgets.dart';

import '../../core/constants/app_sizes.dart';

/// true bila layar adalah HP dalam posisi landscape (dipakai Detail & dialog Gabung).
///
/// P7: orientasi saja tidak cukup, karena desktop dan tablet landscape juga
/// "landscape" walaupun tingginya lega. Karena itu tinggi layar ikut diperiksa:
/// HP landscape tingginya < [AppSizes.tinggiMaksHpLandscape] (misalnya 932×430),
/// sedangkan desktop 1280×800 tidak.
bool landscapeHp(BuildContext context) =>
    MediaQuery.orientationOf(context) == Orientation.landscape &&
    MediaQuery.sizeOf(context).height < AppSizes.tinggiMaksHpLandscape;
