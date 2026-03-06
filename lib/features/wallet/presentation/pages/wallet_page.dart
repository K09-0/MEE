import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/transaction.dart';

/// Wallet Page
/// 
/// Экран кошелька пользователя
/// Показывает баланс, историю транзакций, вывод средств
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _balance = 125.50;
  double _totalEarned = 450.00;
  double _totalSpent = 324.50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showWithdrawDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawSheet(balance: _balance),
    );
  }

  void _showAddFundsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddFundsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.backgroundDark,
                elevation: 0,
                title: Text(
                  'Wallet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ];
          },
          body: Column(
            children: [
              // Balance Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppTheme.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'USD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '\$${_balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _BalanceStat(
                              label: 'Earned',
                              value: '+\$${_totalEarned.toStringAsFixed(2)}',
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _BalanceStat(
                              label: 'Spent',
                              value: '-\$${_totalSpent.toStringAsFixed(2)}',
                              color: AppTheme.accentPink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add,
                        label: 'Add Funds',
                        color: AppTheme.success,
                        onTap: _showAddFundsDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.arrow_downward,
                        label: 'Withdraw',
                        color: AppTheme.accentBlue,
                        onTap: _showWithdrawDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.swap_horiz,
                        label: 'Convert',
                        color: AppTheme.accentOrange,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                indicatorWeight: 3,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondaryDark,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Transactions'),
                  Tab(text: 'Crypto'),
                ],
              ),

              const SizedBox(height: 8),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TransactionsList(),
                    _CryptoSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balance Stat Widget
class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transactions List
class _TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock transactions
    final transactions = [
      {
        'type': 'sale',
        'title': 'Sale: Cyberpunk City',
        'amount': 2.39,
        'date': '2 min ago',
        'positive': true,
      },
      {
        'type': 'purchase',
        'title': 'Purchase: Lo-Fi Beats',
        'amount': 3.99,
        'date': '1 hour ago',
        'positive': false,
      },
      {
        'type': 'referral',
        'title': 'Referral Bonus',
        'amount': 0.50,
        'date': '3 hours ago',
        'positive': true,
      },
      {
        'type': 'withdrawal',
        'title': 'Withdrawal to Bank',
        'amount': 50.00,
        'date': '2 days ago',
        'positive': false,
      },
      {
        'type': 'sale',
        'title': 'Sale: AI Story',
        'amount': 1.59,
        'date': '3 days ago',
        'positive': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionItem(
          type: tx['type'] as String,
          title: tx['title'] as String,
          amount: tx['amount'] as double,
          date: tx['date'] as String,
          isPositive: tx['positive'] as bool,
        );
      },
    );
  }
}

/// Transaction Item
class _TransactionItem extends StatelessWidget {
  final String type;
  final String title;
  final double amount;
  final String date;
  final bool isPositive;

  const _TransactionItem({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.isPositive,
  });

  IconData get _icon {
    switch (type) {
      case 'sale':
        return Icons.shopping_bag;
      case 'purchase':
        return Icons.shopping_cart;
      case 'referral':
        return Icons.card_giftcard;
      case 'withdrawal':
        return Icons.arrow_upward;
      default:
        return Icons.swap_horiz;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'sale':
        return AppTheme.success;
      case 'purchase':
        return AppTheme.accentPink;
      case 'referral':
        return AppTheme.accentOrange;
      case 'withdrawal':
        return AppTheme.accentBlue;
      default:
        return AppTheme.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isPositive ? AppTheme.success : AppTheme.error,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Crypto Section
class _CryptoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _CryptoCard(
            name: 'Solana',
            symbol: 'SOL',
            balance: 2.5,
            usdValue: 125.00,
            iconColor: const Color(0xFF9945FF),
          ),
          const SizedBox(height: 12),
          _CryptoCard(
            name: 'Toncoin',
            symbol: 'TON',
            balance: 10.0,
            usdValue: 45.00,
            iconColor: const Color(0xFF0088CC),
          ),
        ],
      ),
    );
  }
}

/// Crypto Card
class _CryptoCard extends StatelessWidget {
  final String name;
  final String symbol;
  final double balance;
  final double usdValue;
  final Color iconColor;

  const _CryptoCard({
    required this.name,
    required this.symbol,
    required this.balance,
    required this.usdValue,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                symbol[0],
                style: TextStyle(
                  color: iconColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance $symbol',
                  style: TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${usdValue.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Withdraw Sheet
class _WithdrawSheet extends StatefulWidget {
  final double balance;

  const _WithdrawSheet({required this.balance});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Withdraw Funds',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available: \$${widget.balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0;
              });
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('25%'),
                onPressed: () {},
              ),
              ActionChip(
                label: const Text('50%'),
                onPressed: () {},
              ),
              ActionChip(
                label: const Text('75%'),
                onPressed: () {},
              ),
              ActionChip(
                label: const Text('Max'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _amount > 0 && _amount <= widget.balance
                  ? () {
                      Navigator.pop(context);
                      showSuccessSnackbar(context, 'Withdrawal initiated!');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Withdraw'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Add Funds Sheet
class _AddFundsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textTertiaryDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Funds',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.credit_card, color: AppTheme.primaryColor),
            title: Text(
              'Credit Card',
              style: TextStyle(color: AppTheme.textPrimaryDark),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet, color: AppTheme.secondaryColor),
            title: Text(
              'Solana Pay',
              style: TextStyle(color: AppTheme.textPrimaryDark),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.diamond, color: AppTheme.accentBlue),
            title: Text(
              'TON Connect',
              style: TextStyle(color: AppTheme.textPrimaryDark),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
