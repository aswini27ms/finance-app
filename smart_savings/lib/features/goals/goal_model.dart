class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final String category;
  final String icon;
  final int color;
  final List<GoalMilestone> milestones;
  final List<GoalSavingEntry> savingsHistory;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
    this.category = 'Savings',
    this.icon = 'flag',
    this.color = 0xFF6366F1,
    this.milestones = const [],
    this.savingsHistory = const [],
  });

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1).toDouble();
  double get remaining =>
      (targetAmount - savedAmount).clamp(0, double.infinity).toDouble();
  bool get completed => progress >= 1;
  int get daysLeft =>
      deadline == null
          ? 0
          : deadline!.difference(DateTime.now()).inDays.clamp(0, 9999).toInt();

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    return SavingsGoal(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      deadline: parseDate(json['deadline']),
      category: json['category']?.toString() ?? 'Savings',
      icon: json['icon']?.toString() ?? 'flag',
      color: (json['color'] as num?)?.toInt() ?? 0xFF6366F1,
      milestones: (json['milestones'] as List? ?? [])
          .whereType<Map>()
          .map((e) => GoalMilestone.fromJson(e.cast<String, dynamic>()))
          .toList(),
      savingsHistory: (json['savingsHistory'] as List? ?? [])
          .whereType<Map>()
          .map((e) => GoalSavingEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? category,
    String? icon,
    int? color,
    List<GoalMilestone>? milestones,
    List<GoalSavingEntry>? savingsHistory,
  }) =>
      SavingsGoal(
        id: id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        deadline: deadline ?? this.deadline,
        category: category ?? this.category,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        milestones: milestones ?? this.milestones,
        savingsHistory: savingsHistory ?? this.savingsHistory,
      );
}

class GoalMilestone {
  final String label;
  final double amount;
  final bool completed;

  const GoalMilestone({
    required this.label,
    required this.amount,
    required this.completed,
  });

  factory GoalMilestone.fromJson(Map<String, dynamic> json) => GoalMilestone(
        label: json['label']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        completed: json['completed'] == true,
      );
}

class GoalSavingEntry {
  final double amount;
  final String note;
  final DateTime date;

  const GoalSavingEntry({
    required this.amount,
    this.note = '',
    required this.date,
  });

  factory GoalSavingEntry.fromJson(Map<String, dynamic> json) => GoalSavingEntry(
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        note: json['note']?.toString() ?? '',
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      );
}
