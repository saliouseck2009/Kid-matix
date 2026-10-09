/// Progress of the profile creation form.
enum ProfileCreationStatus {
  /// The player is filling in the form.
  editing,

  /// The profile is being saved and opened.
  submitting,

  /// Saving failed; the form shows why.
  failed,
}
