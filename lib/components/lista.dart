import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CryptoList extends StatefulWidget {
  const CryptoList({super.key});

  @override
  State<CryptoList> createState() => _CryptoListState();
}

class _CryptoListState extends State<CryptoList> {
  List<Coin> _cryptos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCryptos();
  }

  Future<void> _fetchCryptos() async {
    const url = 'https://api.coinbase.com/v2/assets/search?base=BRL';
    final dio = Dio();

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        setState(() {
          _cryptos = data.map((coinJson) => Coin.fromJson(coinJson)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar moedas');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Erro ao buscar moedas: $e');
    }
  }

  Future<void> _refreshList() async {
    await _fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshList,
      child: ListView.builder(
        itemCount: _cryptos.length,
        itemBuilder: (context, index) {
          final crypto = _cryptos[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(crypto.imageUrl),
            ),
            title: Text(crypto.name),
            subtitle: Text('Símbolo: ${crypto.symbol}'),
            trailing: Text('R\$ ${crypto.latestPrice}'),
          );
        },
      ),
    );
  }
}

// Modelo Coin
class Coin {
  final String name;
  final String symbol;
  final String imageUrl;
  final String latestPrice;

  Coin({
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.latestPrice,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      name: json['name'] ?? 'Desconhecido',
      symbol: json['symbol'] ?? '',
      imageUrl: json['image_url'] ?? '',
      latestPrice: json['latest_price']?['amount']?['amount'] ?? '0',
    );
  }
}
