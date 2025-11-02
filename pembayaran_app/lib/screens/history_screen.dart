import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildTransactionItem(
            date: '${index + 1} November 2023',
            title: _getTransactionTitle(index),
            amount: _getTransactionAmount(index),
            isIncome: index % 3 == 0,
          );
        },
      ),
    );
  }

  String _getTransactionTitle(int index) {
    final titles = [
      'Pembayaran Listrik',
      'Top Up Saldo',
      'Pembayaran Internet',
      'Transfer ke Bank',
      'Pembayaran PDAM',
    ];
    return titles[index % titles.length];
  }

  String _getTransactionAmount(int index) {
    final amounts = [
      '150.000',
      '200.000',
      '350.000',
      '500.000',
      '125.000',
    ];
    return amounts[index % amounts.length];
  }

  Widget _buildTransactionItem({
    required String date,
    required String title,
    required String amount,
    required bool isIncome,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'} Rp $amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}