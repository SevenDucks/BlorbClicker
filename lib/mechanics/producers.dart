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
