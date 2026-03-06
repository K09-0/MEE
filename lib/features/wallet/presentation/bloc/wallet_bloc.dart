import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/repositories/transaction_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

/// Wallet BLoC
/// 
/// Управляет состоянием кошелька и финансовых операций
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final TransactionRepository _transactionRepository;

  WalletBloc({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository,
        super(const WalletState()) {
    on<LoadWalletBalanceRequested>(_onLoadBalance);
    on<LoadTransactionHistoryRequested>(_onLoadTransactions);
    on<AddFundsRequested>(_onAddFunds);
    on<WithdrawFundsRequested>(_onWithdraw);
    on<PurchaseExperienceRequested>(_onPurchase);
    on<ConvertCurrencyRequested>(_onConvert);
    on<LoadReferralStatsRequested>(_onLoadReferralStats);
  }

  /// Load wallet balance
  Future<void> _onLoadBalance(
    LoadWalletBalanceRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    final result = await _transactionRepository.getWalletBalance(event.userId);

    result.fold(
      (failure) {
        AppLogger.w('Load balance failed: ${failure.message}');
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (balance) {
        AppLogger.i('Balance loaded: ${balance.fiatBalance}');
        emit(state.copyWith(
          status: WalletStatus.loaded,
          balance: balance,
        ));
      },
    );
  }

  /// Load transaction history
  Future<void> _onLoadTransactions(
    LoadTransactionHistoryRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    final result = await _transactionRepository.getUserTransactions(
      event.userId,
      filter: event.filter,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (transactions) {
        emit(state.copyWith(
          status: WalletStatus.loaded,
          transactions: event.page > 1
              ? [...state.transactions, ...transactions]
              : transactions,
        ));
      },
    );
  }

  /// Add funds to wallet
  Future<void> _onAddFunds(
    AddFundsRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.processing));

    final result = await _transactionRepository.addFunds(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) {
        AppLogger.w('Add funds failed: ${failure.message}');
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (transaction) {
        AppLogger.i('Funds added: ${transaction.id}');
        emit(state.copyWith(
          status: WalletStatus.success,
          lastTransaction: transaction,
        ));
        // Reload balance
        add(LoadWalletBalanceRequested(event.userId));
      },
    );
  }

  /// Withdraw funds
  Future<void> _onWithdraw(
    WithdrawFundsRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.processing));

    final result = await _transactionRepository.createWithdrawal(
      amount: event.amount,
      currency: event.currency,
      paymentMethod: event.paymentMethod,
      withdrawalDetails: event.withdrawalDetails,
    );

    result.fold(
      (failure) {
        AppLogger.w('Withdrawal failed: ${failure.message}');
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (transaction) {
        AppLogger.i('Withdrawal created: ${transaction.id}');
        emit(state.copyWith(
          status: WalletStatus.success,
          lastTransaction: transaction,
        ));
        // Reload balance
        add(LoadWalletBalanceRequested(event.userId));
      },
    );
  }

  /// Purchase experience
  Future<void> _onPurchase(
    PurchaseExperienceRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.processing));

    final result = await _transactionRepository.createPurchase(
      experienceId: event.experienceId,
      amount: event.amount,
      currency: event.currency,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) {
        AppLogger.w('Purchase failed: ${failure.message}');
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (transaction) {
        AppLogger.i('Purchase created: ${transaction.id}');
        emit(state.copyWith(
          status: WalletStatus.purchaseSuccess,
          lastTransaction: transaction,
        ));
        // Reload balance
        add(LoadWalletBalanceRequested(event.userId));
      },
    );
  }

  /// Convert currency
  Future<void> _onConvert(
    ConvertCurrencyRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.processing));

    final result = await _transactionRepository.convertCurrency(
      amount: event.amount,
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (convertedAmount) {
        emit(state.copyWith(
          status: WalletStatus.success,
          convertedAmount: convertedAmount,
        ));
      },
    );
  }

  /// Load referral stats
  Future<void> _onLoadReferralStats(
    LoadReferralStatsRequested event,
    Emitter<WalletState> emit,
  ) async {
    final result = await _transactionRepository.getReferralStats(event.userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (stats) {
        emit(state.copyWith(
          referralStats: stats,
        ));
      },
    );
  }
}
