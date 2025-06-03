import 'package:flutter/material.dart';
import 'package:busca_crypto/requisicoes/coin_base.dart'; // Certifique-se que o Coin está aqui.

class CryptoList extends StatelessWidget {
  final List<Coin> cryptos;
  final Future<void> Function()? onRefresh;

  const CryptoList({super.key, required this.cryptos, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        itemCount: cryptos.length,
        itemBuilder: (context, index) {
          final crypto = cryptos[index];
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
