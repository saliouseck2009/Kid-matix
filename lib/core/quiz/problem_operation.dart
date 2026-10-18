/// The four operations a child can pick to solve a short statement, such
/// as "Quelle opération ?" (lot F28), without computing anything.
enum ProblemOperation {
  /// Addition, shown as "+": things are put together.
  add,

  /// Subtraction, shown as "−": things leave or are compared.
  subtract,

  /// Multiplication, shown as "×": equal groups.
  multiply,

  /// Division, shown as "÷": things are shared.
  divide,
}
