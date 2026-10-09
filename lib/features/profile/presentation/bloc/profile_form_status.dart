/// Progress of the profile form, used to create or edit a player.
enum ProfileFormStatus {
  /// The player to edit is loading; the form is not shown yet.
  loading,

  /// The player is filling in the form.
  editing,

  /// The profile is being saved.
  submitting,

  /// The profile is saved; the form can close.
  saved,

  /// Saving failed; the form shows why.
  failed,
}
