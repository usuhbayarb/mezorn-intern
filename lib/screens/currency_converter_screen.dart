import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController amountController = TextEditingController();

  String fromCurrency = 'USD';
  String toCurrency = 'EUR';

  double exchangeRate = 0;
  double result = 0;

  bool isLoading = false;
  String errorMessage = '';
  String rateDate = '';

  final List<String> currencies = [
    'USD',
    'EUR',
    'CNY',
    'KRW',
    'JPY',
    'GBP',
    'AUD',
    'CAD',
    'CHF',
  ];

  @override
  void initState() {
    super.initState();
    fetchRate();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> fetchRate() async {
    if (fromCurrency == toCurrency) {
      setState(() {
        exchangeRate = 1;
        rateDate = '';
        errorMessage = '';
      });
      convertCurrency();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final uri = Uri.parse(
        'https://api.frankfurter.dev/v1/latest?base=$fromCurrency&symbols=$toCurrency',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;

      if (!rates.containsKey(toCurrency)) {
        throw Exception('$toCurrency ханш олдсонгүй');
      }

      final rate = (rates[toCurrency] as num).toDouble();

      setState(() {
        exchangeRate = rate;
        rateDate = data['date'].toString();
        isLoading = false;
        errorMessage = '';
      });

      convertCurrency();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Ханш татахад алдаа гарлаа: $e';
      });
    }
  }

  void convertCurrency() {
    final amount = double.tryParse(amountController.text);

    if (amount == null || exchangeRate == 0) {
      setState(() {
        result = 0;
      });
      return;
    }

    setState(() {
      result = amount * exchangeRate;
    });
  }

  void swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      exchangeRate = 0;
      result = 0;
    });

    fetchRate();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),

          const SizedBox(height: 8),

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => convertCurrency(),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: fromCurrency,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                  ),
                  items: currencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        fromCurrency = value;
                      });
                      fetchRate();
                    }
                  },
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: swapCurrencies,
                icon: const Icon(Icons.swap_horiz),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: toCurrency,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                  ),
                  items: currencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        toCurrency = value;
                      });
                      fetchRate();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : fetchRate,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Exchange Rate'),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Converted Amount'),
                  const SizedBox(height: 8),
                  Text(
                    '${result.toStringAsFixed(2)} $toCurrency',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1 $fromCurrency = ${exchangeRate.toStringAsFixed(4)} $toCurrency',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (rateDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Rate date: $rateDate',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}