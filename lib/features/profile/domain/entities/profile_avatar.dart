/// One of the characters a player can wear as an avatar.
///
/// The first 12 are free and drawn in the player's color; the others are
/// unlocked in the shop (lot F21) and have their own colors. The drawings
/// are provisional: final illustrations replace them without changing
/// these values, which are stored in the database by [name].
enum ProfileAvatar {
  /// First character of the picker grid.
  avatar1,

  /// Second character of the picker grid.
  avatar2,

  /// Third character of the picker grid.
  avatar3,

  /// Fourth character of the picker grid.
  avatar4,

  /// Fifth character of the picker grid.
  avatar5,

  /// Sixth character of the picker grid.
  avatar6,

  /// Seventh character of the picker grid.
  avatar7,

  /// Eighth character of the picker grid.
  avatar8,

  /// Ninth character of the picker grid.
  avatar9,

  /// Tenth character of the picker grid.
  avatar10,

  /// Eleventh character of the picker grid.
  avatar11,

  /// Twelfth character of the picker grid.
  avatar12,

  /// An orange fox, from the shop.
  fox,

  /// A panda, from the shop.
  panda,

  /// A robot, from the shop.
  robot,

  /// A green alien, from the shop.
  alien,

  /// A unicorn, from the shop.
  unicorn,

  /// A dragon, from the shop.
  dragon,

  /// A ninja, from the shop.
  ninja,

  /// A king with his crown, from the shop.
  king;

  /// Number of free avatars, offered by the picker.
  static const int freeCount = 12;

  /// The free avatars, in the order of the picker.
  static List<ProfileAvatar> get free => values.sublist(0, freeCount);

  /// Whether the avatar is free rather than bought in the shop.
  bool get isFree => index < freeCount;
}
