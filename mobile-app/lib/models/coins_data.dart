const List<Map<String, dynamic>> coins = [
  {
    "address": "So11111111111111111111111111111111111111112",
    "symbol": "SOL",
    "name": "Solana",
    "decimals": 9,
    "logoURI":
        "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
  },
  {
    "address": "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263",
    "symbol": "BONK",
    "name": "Bonk",
    "decimals": 5,
    "logoURI":
        "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263/logo.png",
  },
  {
    "address": "JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN",
    "symbol": "JUP",
    "name": "Jupiter",
    "decimals": 6,
    "logoURI": "https://static.jup.ag/jup/icon.png",
  },
  {
    "address": "orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE",
    "symbol": "ORCA",
    "name": "Orca",
    "decimals": 6,
    "logoURI":
        "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE/logo.png",
  },
  {
    "address": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
    "symbol": "USDC",
    "name": "USD Coin",
    "decimals": 6,
    "logoURI":
        "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2q9F8P4w7x6kT4eQ3wA1kYy3xk/logo.png",
  },
];

class Token {
  final String name;
  final String symbol;
  final String address;
  final int decimals;
  final String logoURI;

  Token({
    required this.name,
    required this.symbol,
    required this.address,
    required this.decimals,
    required this.logoURI,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      name: json['name'],
      symbol: json['symbol'],
      address: json['address'],
      decimals: json['decimals'],
      logoURI: json['logoURI'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'address': address,
      'decimals': decimals,
      'logoURI': logoURI,
    };
  }
}

final List<Token> getLocalTokens = coins.map((e) => Token.fromJson(e)).toList();
