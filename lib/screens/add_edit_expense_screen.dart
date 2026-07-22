import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../utils/app_theme.dart';

const TextStyle _sectionLabelStyle = TextStyle(
  color: AppColors.mutedLavender,
  fontSize: 11,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.1,
);

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final Map<String, dynamic>? expenseToEdit;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
    this.expenseToEdit,
  });

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagInputController = TextEditingController();

  late String _selectedCategory;
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isIncome = false;
  bool _isFavorite = false;
  bool _isBusinessExpense = false;
  bool _isTaxDeductible = false;
  bool _isConfidential = false;
  bool _isRecurring = false;
  bool _enableReminder = false;

  String _selectedCurrency = '\$';
  String _selectedPaymentMethod = 'Credit Card';
  String _selectedAccount = 'Main Bank Account';
  String _recurringFrequency = 'Monthly';
  String _selectedProject = 'Personal';

  List<String> _tags = [];
  String? _receiptImagePath;
  String? _voiceNotePath;

  int _splitPeopleCount = 1;
  double _splitTipPercentage = 0.0;

  final double _categoryBudgetLimit = 500.0;

  final List<String> _currencies = ['\$', '€', '£', '¥', 'PKR', '₹'];
  final List<String> _paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Crypto'];
  final List<String> _accounts = ['Main Bank Account', 'Savings Account', 'Cash Wallet', 'Business Card'];
  final List<String> _recurringFrequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> _projects = ['Personal', 'Summer Vacation', 'Office Work', 'House Repair'];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded, 'color': Colors.orangeAccent},
    {'name': 'Transport', 'icon': Icons.directions_bus_rounded, 'color': Colors.blueAccent},
    {'name': 'Entertainment', 'icon': Icons.movie_creation_rounded, 'color': Colors.purpleAccent},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded, 'color': Colors.redAccent},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded, 'color': Colors.pinkAccent},
    {'name': 'Health', 'icon': Icons.medical_services_rounded, 'color': Colors.greenAccent},
    {'name': 'Education', 'icon': Icons.school_rounded, 'color': Colors.amberAccent},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Colors.tealAccent},
  ];

  @override
  void initState() {
    super.initState();

    Expense? targetExpense = widget.expense;
    if (targetExpense == null && widget.expenseToEdit != null) {
      targetExpense = Expense.fromMap(widget.expenseToEdit!);
    }

    _titleController.text = targetExpense?.title ?? '';
    _merchantController.text = targetExpense?.merchant ?? '';
    _amountController.text = targetExpense?.amount != null && targetExpense!.amount > 0 
        ? targetExpense.amount.toString() 
        : '';

    _selectedCategory = targetExpense?.category ?? 'Food';
    _selectedDate = targetExpense?.date ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);

    _noteController.text = targetExpense?.note ?? '';
    _selectedAccount = targetExpense?.account ?? 'Main Bank Account';
    _selectedPaymentMethod = targetExpense?.paymentMethod ?? 'Credit Card';
    _selectedCurrency = targetExpense?.currency ?? '\$';
    _selectedProject = targetExpense?.project ?? 'Personal';

    _isIncome = targetExpense?.isIncome ?? false;
    _isFavorite = targetExpense?.isFavorite ?? false;
    _isBusinessExpense = targetExpense?.isBusinessExpense ?? false;
    _isTaxDeductible = targetExpense?.isTaxDeductible ?? false;
    _isConfidential = targetExpense?.isConfidential ?? false;
    _isRecurring = targetExpense?.isRecurring ?? false;
    _recurringFrequency = targetExpense?.recurringFrequency ?? 'Monthly';
    _enableReminder = targetExpense?.enableReminder ?? false;

    if (targetExpense?.tags != null && targetExpense!.tags!.isNotEmpty) {
      _tags = targetExpense.tags!.split(',').where((t) => t.isNotEmpty).toList();
    }

    _receiptImagePath = targetExpense?.receiptImagePath;
    _voiceNotePath = targetExpense?.voiceNotePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double value) {
    double current = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _amountController.text = (current + value).toStringAsFixed(2);
    });
  }

  void _addTag(String tag) {
    final trimmed = tag.trim().replaceAll('#', '');
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _tagInputController.clear();
      });
    }
  }

  void _showSplitBillSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.geometricCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
            double totalWithTip = totalAmount + (totalAmount * (_splitTipPercentage / 100));
            double perPerson = _splitPeopleCount > 0 ? totalWithTip / _splitPeopleCount : 0.0;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Split Bill Calculator',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Number of People:', style: TextStyle(color: AppColors.pastelLavender)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.softLilac),
                            onPressed: _splitPeopleCount > 1
                                ? () {
                                    setSheetState(() => _splitPeopleCount--);
                                    setState(() {});
                                  }
                                : null,
                          ),
                          Text('$_splitPeopleCount',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.softLilac),
                            onPressed: () {
                              setSheetState(() => _splitPeopleCount++);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tip Percentage:', style: TextStyle(color: AppColors.pastelLavender)),
                      DropdownButton<double>(
                        value: _splitTipPercentage,
                        dropdownColor: AppColors.geometricCard,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: [0.0, 5.0, 10.0, 15.0, 20.0].map((tip) {
                          return DropdownMenuItem(value: tip, child: Text('${tip.toInt()}%'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => _splitTipPercentage = val);
                            setState(() {});
                          }
                        },
                      )
                    ],
                  ),
                  const Divider(color: AppColors.subtleBorder, height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.deepRoyalViolet,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount Per Person:', style: TextStyle(color: Colors.white70)),
                        Text(
                          '$_selectedCurrency${perPerson.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.incomeGreen, fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final sanitizedAmount = _amountController.text.trim().replaceAll(',', '.');
      final parsedAmount = double.tryParse(sanitizedAmount) ?? 0.0;

      final expense = Expense(
        id: widget.expense?.id ?? widget.expenseToEdit?['id'],
        title: _titleController.text.trim(),
        merchant: _merchantController.text.trim().isEmpty ? null : _merchantController.text.trim(),
        amount: parsedAmount,
        category: _selectedCategory,
        date: finalDateTime,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        account: _selectedAccount,
        paymentMethod: _selectedPaymentMethod,
        currency: _selectedCurrency,
        project: _selectedProject,
        isIncome: _isIncome,
        isFavorite: _isFavorite,
        isBusinessExpense: _isBusinessExpense,
        isTaxDeductible: _isTaxDeductible,
        isConfidential: _isConfidential,
        isRecurring: _isRecurring,
        recurringFrequency: _recurringFrequency,
        enableReminder: _enableReminder,
        tags: _tags.isEmpty ? null : _tags.join(','),
        receiptImagePath: _receiptImagePath,
        voiceNotePath: _voiceNotePath,
      );

      if (widget.expense == null && widget.expenseToEdit == null) {
        await DatabaseHelper.instance.insertExpense(expense);
      } else {
        await DatabaseHelper.instance.updateExpense(expense);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.expense == null && widget.expenseToEdit == null
                ? 'Expense added successfully'
                : 'Expense updated successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null || widget.expenseToEdit != null;
    final accentColor = _isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    bool isOverBudget = enteredAmount > _categoryBudgetLimit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaction' : 'New Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? Colors.amber : Colors.white,
            ),
            tooltip: 'Bookmark Transaction',
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export Transaction',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting receipt as PDF...')),
              );
            },
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              tooltip: 'Delete Transaction',
              onPressed: () async {
                final id = widget.expense?.id ?? widget.expenseToEdit?['id'];
                if (id != null) {
                  await DatabaseHelper.instance.deleteExpense(id);
                  if (mounted) Navigator.pop(context, {'deleted': true, 'id': id});
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.incomeGreen),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.geometricCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isIncome ? AppColors.expenseRed.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: !_isIncome ? Border.all(color: AppColors.expenseRed) : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.arrow_downward_rounded, color: AppColors.expenseRed, size: 18),
                            SizedBox(width: 6),
                            Text('Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isIncome ? AppColors.incomeGreen.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: _isIncome ? Border.all(color: AppColors.incomeGreen) : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.arrow_upward_rounded, color: AppColors.incomeGreen, size: 18),
                            SizedBox(width: 6),
                            Text('Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppColors.getGradientCardDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isIncome ? 'TOTAL INCOME' : 'TOTAL EXPENSE',
                        style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.deepRoyalViolet, borderRadius: BorderRadius.circular(12)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            dropdownColor: AppColors.geometricCard,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCurrency = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_selectedCurrency, style: TextStyle(color: accentColor, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      IntrinsicWidth(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          obscureText: _isConfidential,
                          style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: AppColors.roseQuartz),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) return 'Enter valid amount';
                            if (double.parse(val) <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!_isIncome && isOverBudget) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
                          SizedBox(width: 4),
                          Text('Exceeds Category Monthly Budget!',
                              style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [10, 50, 100, 500].map((val) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ActionChip(
                            label: Text('+$val'),
                            backgroundColor: AppColors.deepRoyalViolet,
                            labelStyle: const TextStyle(color: AppColors.pastelLavender, fontSize: 12),
                            onPressed: () => _addQuickAmount(val.toDouble()),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('DETAILS & CONTEXT', style: _sectionLabelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title (e.g., Weekly Groceries)',
                prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.softLilac),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      hintText: 'Merchant / Store',
                      prefixIcon: Icon(Icons.storefront_rounded, color: AppColors.softLilac),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProject,
                    dropdownColor: AppColors.geometricCard,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.folder_special_outlined, color: AppColors.softLilac),
                    ),
                    items: _projects.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProject = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('CATEGORY', style: _sectionLabelStyle),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat['name'] == _selectedCategory;
                  final Color catColor = cat['color'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? catColor.withValues(alpha: 0.25) : AppColors.geometricCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? catColor : AppColors.subtleBorder,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat['icon'], size: 18, color: isSelected ? catColor : AppColors.mutedLavender),
                          const SizedBox(width: 8),
                          Text(
                            cat['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.pastelLavender,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PAY FROM ACCOUNT', style: _sectionLabelStyle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAccount,
                        dropdownColor: AppColors.geometricCard,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.softLilac),
                        ),
                        items: _accounts.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAccount = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PAYMENT METHOD', style: _sectionLabelStyle),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        dropdownColor: AppColors.geometricCard,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.payment_rounded, color: AppColors.softLilac),
                        ),
                        items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPaymentMethod = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('DATE & TIME', style: _sectionLabelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppColors.getGlassCardDecoration(),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppColors.softLilac, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppColors.getGlassCardDecoration(),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.softLilac, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _showSplitBillSheet,
              icon: const Icon(Icons.call_split_rounded, color: AppColors.softLilac),
              label: Text(
                _splitPeopleCount > 1 ? 'Split with $_splitPeopleCount people' : 'SPLIT BILL WITH FRIENDS',
                style: const TextStyle(color: AppColors.pastelLavender),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.subtleBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            const Text('ADVANCED OPTIONS', style: _sectionLabelStyle),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.geometricCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _isBusinessExpense,
                    onChanged: (val) => setState(() => _isBusinessExpense = val),
                    title: const Text('Business Expense', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Mark as reimbursable company expense', style: TextStyle(color: AppColors.roseQuartz, fontSize: 11)),
                    secondary: const Icon(Icons.business_center_outlined, color: AppColors.softLilac),
                  ),
                  const Divider(color: AppColors.subtleBorder, height: 1),
                  SwitchListTile(
                    value: _isTaxDeductible,
                    onChanged: (val) => setState(() => _isTaxDeductible = val),
                    title: const Text('Tax Deductible', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Flag for end-of-year tax reports', style: TextStyle(color: AppColors.roseQuartz, fontSize: 11)),
                    secondary: const Icon(Icons.request_quote_outlined, color: AppColors.softLilac),
                  ),
                  const Divider(color: AppColors.subtleBorder, height: 1),
                  SwitchListTile(
                    value: _isConfidential,
                    onChanged: (val) => setState(() => _isConfidential = val),
                    title: const Text('Hide Amount (Confidential)', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Mask value in dashboard previews', style: TextStyle(color: AppColors.roseQuartz, fontSize: 11)),
                    secondary: const Icon(Icons.visibility_off_outlined, color: AppColors.softLilac),
                  ),
                  const Divider(color: AppColors.subtleBorder, height: 1),
                  SwitchListTile(
                    value: _isRecurring,
                    onChanged: (val) => setState(() => _isRecurring = val),
                    title: const Text('Recurring Transaction', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Set repeat schedule', style: TextStyle(color: AppColors.roseQuartz, fontSize: 11)),
                    secondary: const Icon(Icons.repeat_rounded, color: AppColors.softLilac),
                  ),
                  if (_isRecurring) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Frequency:', style: TextStyle(color: AppColors.pastelLavender, fontSize: 12)),
                          DropdownButton<String>(
                            value: _recurringFrequency,
                            dropdownColor: AppColors.geometricCard,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            items: _recurringFrequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _recurringFrequency = val);
                            },
                          )
                        ],
                      ),
                    )
                  ],
                  const Divider(color: AppColors.subtleBorder, height: 1),
                  SwitchListTile(
                    value: _enableReminder,
                    onChanged: (val) => setState(() => _enableReminder = val),
                    title: const Text('Set Payment Reminder', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Get push alert before due date', style: TextStyle(color: AppColors.roseQuartz, fontSize: 11)),
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.softLilac),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('TAGS', style: _sectionLabelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagInputController,
              decoration: InputDecoration(
                hintText: 'Type tag and press +',
                prefixIcon: const Icon(Icons.label_outline_rounded, color: AppColors.softLilac),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.softLilac),
                  onPressed: () => _addTag(_tagInputController.text),
                ),
              ),
              onFieldSubmitted: _addTag,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text('#$tag', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: AppColors.deepRoyalViolet,
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text('ATTACHMENTS', style: _sectionLabelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _receiptImagePath = 'mock_receipt.jpg');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt image attached.')));
                    },
                    icon: Icon(_receiptImagePath == null ? Icons.camera_alt_outlined : Icons.check_circle, 
                               color: _receiptImagePath == null ? AppColors.softLilac : AppColors.incomeGreen),
                    label: Text(_receiptImagePath == null ? 'Photo Receipt' : 'Attached', style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _voiceNotePath = 'mock_audio.mp3');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice note recorded.')));
                    },
                    icon: Icon(_voiceNotePath == null ? Icons.mic_none_rounded : Icons.check_circle, 
                               color: _voiceNotePath == null ? AppColors.softLilac : AppColors.incomeGreen),
                    label: Text(_voiceNotePath == null ? 'Voice Note' : 'Recorded', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Additional notes or transaction context...',
                prefixIcon: Icon(Icons.description_outlined, color: AppColors.softLilac),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppColors.primaryButtonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.activeGlow.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  isEditing ? 'UPDATE TRANSACTION' : 'SAVE TRANSACTION',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}