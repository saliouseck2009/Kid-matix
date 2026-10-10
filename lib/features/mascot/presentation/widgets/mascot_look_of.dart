import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';

/// How [mascot] looks: its stage and the accessories it wears.
MascotLook lookOf(MascotEntity mascot) {
  return MascotLook(
    stage: mascot.stage,
    accessories: mascot.worn.values.toSet(),
  );
}
