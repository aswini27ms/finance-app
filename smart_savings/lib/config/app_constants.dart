class AppConstants {
  static const String appName = 'Smart Savings';
  static const String currencySymbol = '₹';

  // Default folder allocation percentages of total balance.
  static const Map<String, double> defaultFolderAllocation = {
    'Emergency': 0.20,
    'Food': 0.10,
    'Travel': 0.04,
    'Rent': 0.30,
    'Investments': 0.15,
    'Fun': 0.06,
  };
}
