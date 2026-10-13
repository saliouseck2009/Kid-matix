/// Where a player stands with an item of the shop.
enum ShopOfferStatus {
  /// The avatar worn or the theme applied: « Porté », « Actif ».
  inUse,

  /// Owned and not in use: « Choisir ».
  owned,

  /// Not owned, and the player has the coins to buy it.
  affordable,

  /// Not owned, and the player lacks coins to buy it.
  tooExpensive,
}
