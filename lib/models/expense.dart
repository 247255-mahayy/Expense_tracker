class Expense {
  final int? id;
  final String title;
  final String? merchant;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? account;
  final String? paymentMethod;
  final String? currency;
  final String? project;
  final bool isIncome;
  final bool isFavorite;
  final bool isBusinessExpense;
  final bool isTaxDeductible;
  final bool isConfidential;
  final bool isRecurring;
  final String? recurringFrequency;
  final bool enableReminder;
  final String? tags;
  final String? receiptImagePath;
  final String? voiceNotePath;

  Expense({
    this.id,
    required this.title,
    this.merchant,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.account,
    this.paymentMethod,
    this.currency,
    this.project,
    this.isIncome = false,
    this.isFavorite = false,
    this.isBusinessExpense = false,
    this.isTaxDeductible = false,
    this.isConfidential = false,
    this.isRecurring = false,
    this.recurringFrequency,
    this.enableReminder = false,
    this.tags,
    this.receiptImagePath,
    this.voiceNotePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'merchant': merchant,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'account': account,
      'paymentMethod': paymentMethod,
      'currency': currency,
      'project': project,
      'isIncome': isIncome ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'isBusinessExpense': isBusinessExpense ? 1 : 0,
      'isTaxDeductible': isTaxDeductible ? 1 : 0,
      'isConfidential': isConfidential ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringFrequency': recurringFrequency,
      'enableReminder': enableReminder ? 1 : 0,
      'tags': tags,
      'receiptImagePath': receiptImagePath,
      'voiceNotePath': voiceNotePath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    bool parseB(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Expense(
      id: map['id'] as int?,
      title: map['title'] ?? '',
      merchant: map['merchant'],
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: parsedDate,
      note: map['note'],
      account: map['account'],
      paymentMethod: map['paymentMethod'] ?? map['payment_method'],
      currency: map['currency'],
      project: map['project'],
      isIncome: parseB(map['isIncome'] ?? map['is_income']),
      isFavorite: parseB(map['isFavorite'] ?? map['is_favorite']),
      isBusinessExpense: parseB(map['isBusinessExpense'] ?? map['is_business_expense']),
      isTaxDeductible: parseB(map['isTaxDeductible'] ?? map['is_tax_deductible']),
      isConfidential: parseB(map['isConfidential'] ?? map['is_confidential']),
      isRecurring: parseB(map['isRecurring'] ?? map['is_recurring']),
      recurringFrequency: map['recurringFrequency'] ?? map['recurring_frequency'],
      enableReminder: parseB(map['enableReminder'] ?? map['enable_reminder']),
      tags: map['tags'],
      receiptImagePath: map['receiptImagePath'] ?? map['receipt_image_path'],
      voiceNotePath: map['voiceNotePath'] ?? map['voice_note_path'],
    );
  }
}