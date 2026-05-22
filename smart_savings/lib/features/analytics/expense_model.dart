class Expense {
  final String id;
  final String folderId;
  final String folderName;
  final double amount;
  final String label;
  final String description;
  final String category;
  final DateTime date;
  final int daysAgo;

  const Expense({
    required this.id,
    required this.folderId,
    this.folderName = '',
    required this.amount,
    required this.label,
    this.description = '',
    this.category = 'general',
    required this.date,
    required this.daysAgo,
  });

  static Expense fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();
    final daysAgo = DateTime.now().difference(date).inDays;

    // folderId may be a populated object or a plain string
    String folderId = '';
    String folderName = '';
    final fi = json['folderId'];
    if (fi is Map) {
      folderId = fi['_id']?.toString() ?? '';
      folderName = fi['name']?.toString() ?? '';
    } else {
      folderId = fi?.toString() ?? '';
    }

    return Expense(
      id: json['_id']?.toString() ?? '',
      folderId: folderId,
      folderName: folderName,
      amount: (json['amount'] as num).toDouble(),
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      date: date,
      daysAgo: daysAgo,
    );
  }
}
