class WishlistItem {
  final String id;
  final String name;
  final double price;
  final double saved;
  final double dailySaving;
  final double monthlySaving;
  final String imageEmoji;
  final String imageUrl;
  final String merchantUrl;
  final String merchantName;
  final String category;
  final String priority;
  final DateTime? expectedPurchaseDate;
  final List<SavingEntry> savingsHistory;

  const WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.saved,
    required this.dailySaving,
    this.monthlySaving = 0,
    required this.imageEmoji,
    this.imageUrl = '',
    this.merchantUrl = '',
    this.merchantName = '',
    this.category = 'General',
    this.priority = 'Medium',
    this.expectedPurchaseDate,
    this.savingsHistory = const [],
  });

  double get progress => price == 0 ? 0 : (saved / price).clamp(0, 1).toDouble();
  double get remaining => (price - saved).clamp(0, double.infinity).toDouble();
  bool get isFullyFunded => saved >= price;
  int get daysRemaining {
    if (remaining <= 0) return 0;
    if (dailySaving <= 0) return 9999;
    return (remaining / dailySaving).ceil();
  }

  DateTime get estimatedPurchaseDate =>
      DateTime.now().add(Duration(days: daysRemaining >= 9999 ? 0 : daysRemaining));

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    return WishlistItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
      dailySaving: (json['dailySaving'] as num?)?.toDouble() ?? 0,
      monthlySaving: (json['monthlySaving'] as num?)?.toDouble() ?? 0,
      imageEmoji: json['imageEmoji']?.toString() ?? '🎁',
      imageUrl: json['imageUrl']?.toString() ?? '',
      merchantUrl: json['merchantUrl']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      priority: json['priority']?.toString() ?? 'Medium',
      expectedPurchaseDate: parseDate(json['expectedPurchaseDate']),
      savingsHistory: (json['savingsHistory'] as List? ?? [])
          .whereType<Map>()
          .map((e) => SavingEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  WishlistItem copyWith({
    double? saved,
    double? dailySaving,
    double? monthlySaving,
    double? price,
    String? name,
    String? imageEmoji,
    String? imageUrl,
    String? merchantUrl,
    String? merchantName,
    String? category,
    String? priority,
    DateTime? expectedPurchaseDate,
    List<SavingEntry>? savingsHistory,
  }) =>
      WishlistItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        saved: saved ?? this.saved,
        dailySaving: dailySaving ?? this.dailySaving,
        monthlySaving: monthlySaving ?? this.monthlySaving,
        imageEmoji: imageEmoji ?? this.imageEmoji,
        imageUrl: imageUrl ?? this.imageUrl,
        merchantUrl: merchantUrl ?? this.merchantUrl,
        merchantName: merchantName ?? this.merchantName,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        expectedPurchaseDate: expectedPurchaseDate ?? this.expectedPurchaseDate,
        savingsHistory: savingsHistory ?? this.savingsHistory,
      );
}

class SavingEntry {
  final double amount;
  final String note;
  final DateTime date;

  const SavingEntry({
    required this.amount,
    this.note = '',
    required this.date,
  });

  factory SavingEntry.fromJson(Map<String, dynamic> json) => SavingEntry(
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        note: json['note']?.toString() ?? '',
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      );
}
