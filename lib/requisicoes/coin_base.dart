import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Pacote Dio para requisições HTTP

class RequestCoin extends StatefulWidget {
  const RequestCoin({super.key});

  @override
  State<RequestCoin> createState() => _RequestCoinState();
}

class _RequestCoinState extends State<RequestCoin> {
  late Future<List<Coin>> _futureCoins;

  @override
  void initState() {
    super.initState();
    _futureCoins = fetchCoins();
  }

  Future<List<Coin>> fetchCoins() async {
    const url = 'https://api.coinbase.com/v2/assets/search?base=BRL';
    final dio = Dio();

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        final List<dynamic> data = jsonResponse['data'];

        // Parseia a lista de moedas
        return data.map((coinJson) => Coin.fromJson(coinJson)).toList();
      } else {
        throw Exception('Falha ao carregar as moedas');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Coin>>(
      future: _futureCoins,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma moeda encontrada'));
        } else {
          final coins = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureCoins = fetchCoins();
              });
            },
            child: ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(coin.imageUrl),
                  ),
                  title: Text(coin.name),
                  subtitle: Text(coin.symbol),
                  trailing: Text('R\$ ${coin.latestPrice}'),
                );
              },
            ),
          );
        }
      },
    );
  }
}

// Classe Coin para mapear os dados da API
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
      name: json['name'] ?? 'Unknown',
      symbol: json['symbol'] ?? '',
      imageUrl: json['image_url'] ?? '',
      latestPrice: json['latest_price']?['amount']?['amount'] ?? '0',
    );
  }
}
