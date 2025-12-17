enum Currency {
  inr,
  usd,
  eur,
  jpy,
}

class CurrencyConfig {
  final String symbol;
  final double rate; // conversion rate FROM INR

  const CurrencyConfig(this.symbol, this.rate);
}

const currencyMap = {
  Currency.inr: CurrencyConfig('₹', 1.0),
  Currency.usd: CurrencyConfig('\$', 0.012),
  Currency.eur: CurrencyConfig('€', 0.011),
  Currency.jpy: CurrencyConfig('¥', 1.80),
};
