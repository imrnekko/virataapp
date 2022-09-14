class Wallet {
  String? walletid;
  double? amount;
  double? minAmount;
  double? maxAmount;
  bool? isAvailable;
  String? currency;

  Wallet(
      {this.walletid,
      this.amount,
      this.minAmount,
      this.maxAmount,
      this.isAvailable,
      this.currency});
}
