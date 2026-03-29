import 'package:financialreport/providers/trxProvider.dart';
import 'package:financialreport/widgets/addTransactionSheet.dart';
import 'package:financialreport/widgets/summaryCard.dart';
import 'package:financialreport/widgets/transactionItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                _buildSummarySection(provider),
                _buildTransactionHeader(context, provider),
                _buildTransactionList(context, provider),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      backgroundColor: theme.colorScheme.background,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Report',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      titleSpacing: 20,
    );
  }

  SliverToBoxAdapter _buildSummarySection(TransactionProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: SummaryCard(summary: provider.summary),
      ),
    );
  }

  SliverToBoxAdapter _buildTransactionHeader(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Row(
          children: [
            Text(
              'Riwayat Transaksi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${provider.transactions.length} transaksi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionProvider provider,
  ) {
    if (provider.transactions.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _EmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: provider.transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          return TransactionItem(
            transaction: transaction,
            onDelete: () => provider.deleteTransaction(transaction.id),
          );
        },
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => AddTransactionSheet.show(context),
      icon: const Icon(Icons.add),
      label: const Text('Tambah'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: theme.colorScheme.onBackground.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Text(
          'Belum ada transaksi',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap tombol + untuk menambahkan',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
