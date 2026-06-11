import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController inputController = TextEditingController();

  String category = 'Length';
  String fromUnit = 'km';
  String toUnit = 'm';
  double result = 0;

  final Map<String, List<String>> units = {
    'Length': ['km', 'm', 'cm', 'mm'],
    'Weight': ['kg', 'g', 'lb'],
    'Temperature': ['C', 'F', 'K'],
  };

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void changeCategory(String newCategory) {
    setState(() {
      category = newCategory;
      fromUnit = units[category]![0];
      toUnit = units[category]![1];
      result = 0;
      inputController.clear();
    });
  }

  void convert() {
    final input = double.tryParse(inputController.text);
    if (input == null) {
      setState(() => result = 0);
      return;
    }

    double converted = 0;

    if (category == 'Length') {
      converted = convertLength(input, fromUnit, toUnit);
    } else if (category == 'Weight') {
      converted = convertWeight(input, fromUnit, toUnit);
    } else if (category == 'Temperature') {
      converted = convertTemperature(input, fromUnit, toUnit);
    }

    setState(() {
      result = converted;
    });
  }

  double convertLength(double value, String from, String to) {
    final Map<String, double> toMeter = {
      'km': 1000,
      'm': 1,
      'cm': 0.01,
      'mm': 0.001,
    };

    final meter = value * toMeter[from]!;
    return meter / toMeter[to]!;
  }

  double convertWeight(double value, String from, String to) {
    final Map<String, double> toKg = {
      'kg': 1,
      'g': 0.001,
      'lb': 0.45359237,
    };

    final kg = value * toKg[from]!;
    return kg / toKg[to]!;
  }

  double convertTemperature(double value, String from, String to) {
    double celsius;

    if (from == 'C') {
      celsius = value;
    } else if (from == 'F') {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }

    if (to == 'C') {
      return celsius;
    } else if (to == 'F') {
      return celsius * 9 / 5 + 32;
    } else {
      return celsius + 273.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUnits = units[category]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: units.keys.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (value) {
              if (value != null) changeCategory(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: inputController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => convert(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: fromUnit,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                  ),
                  items: currentUnits.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => fromUnit = value);
                      convert();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: toUnit,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                  ),
                  items: currentUnits.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => toUnit = value);
                      convert();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Result'),
                  const SizedBox(height: 8),
                  Text(
                    result.toStringAsFixed(4),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}