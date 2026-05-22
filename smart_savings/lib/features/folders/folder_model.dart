class Folder {
  final String id;
  final String name;
  final String icon;
  final double budget;
  final double spent;
  final int color;

  const Folder({
    required this.id,
    required this.name,
    required this.icon,
    required this.budget,
    required this.spent,
    required this.color,
  });

  double get remaining => (budget - spent).clamp(0, double.infinity);
  double get progress => budget == 0 ? 0 : (spent / budget).clamp(0, 1);

  Folder copyWith({String? name, String? icon, double? budget, double? spent, int? color}) =>
      Folder(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        budget: budget ?? this.budget,
        spent: spent ?? this.spent,
        color: color ?? this.color,
      );
}
