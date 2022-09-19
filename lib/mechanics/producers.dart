import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';

class Producer {
  String name;
  Icon icon;
  int amount = 0;
  double baseProduction;
  late double currentProduction;
  int baseCost;
  late int currentCost;
  late String strBP;
  late String strCP;

  Producer(this.name, this.icon, this.baseProduction, this.baseCost) {
    calc();
  }

  void buy() {
    if (Data.resourceAmount < currentCost) {
      return;
    }
    Data.resourceAmount -= currentCost;
    amount++;
    calc();
  }

  void calc() {
    currentProduction = baseProduction * amount;
    currentCost = (baseCost * pow(1.15, amount)).ceil();

    strBP = App.floatFormat.format(baseProduction);
    strCP = App.floatFormat.format(currentProduction);
  }
}

List<Producer> createProducers() {
  return [
      Producer(
          'Particle',
          Icon(
            Icons.grain,
            color: Colors.purple.shade400,
          ),
          0.1,
          15),
      Producer(
          'Atom',
          Icon(
            Icons.mode_standby,
            color: Colors.deepPurple.shade400,
          ),
          0.7,
          180),
      Producer(
          'Molecule',
          Icon(
            Icons.hub,
            color: Colors.indigo.shade400,
          ),
          4,
          2500),
      Producer(
          'Cell',
          const Icon(
            Icons.egg_alt,
            color: Colors.cyan,
          ),
          30,
          40000),
      Producer(
          'Flora',
          const Icon(
            Icons.local_florist,
            color: Colors.teal,
          ),
          200,
          600000),
      Producer(
          'Fauna',
          Icon(
            Icons.pets,
            color: Colors.lime.shade700,
          ),
          1800,
          8000000),
      Producer(
          'Citizen',
          Icon(
            Icons.person,
            color: Colors.orange.shade600,
          ),
          12000,
          100000000),
    ];
}

class ProducerArea extends Container {
  final Producer producer;
  final Function(Producer) onBuy;

  ProducerArea(this.producer, this.onBuy, {super.key})
      : super(
          child: Tooltip(
            message: """
Each ${producer.name} produces ${producer.strBP} Entropy per second,
resulting in a total of ${producer.strCP} per seond.""",
            showDuration: const Duration(milliseconds: 0),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producer.name),
                  Text(
                    'Cost: ${App.intFormat.format(producer.currentCost)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: producer.currentCost > Data.resourceAmount
                          ? (Data.useDarkTheme
                              ? Colors.red.shade200
                              : Colors.red)
                          : (Data.useDarkTheme
                              ? Colors.green.shade200
                              : Colors.green),
                    ),
                  ),
                ],
              ),
              leading: producer.icon,
              trailing: Text(
                '${producer.amount}',
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              onTap: () => onBuy(producer),
            ),
          ),
        );
}
