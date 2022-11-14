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
  late int multiplier;
  late List<ProducerUpgrade> upgrades;

  Producer(this.name, this.icon, this.baseProduction, this.baseCost) {
    upgrades = [
      ProducerUpgrade(this, 1),
      ProducerUpgrade(this, 2),
    ];
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
    multiplier = 1;
    for (ProducerUpgrade upgrade in upgrades) {
      if (upgrade.bought) {
        multiplier *= 2;
      }
    }

    currentProduction = baseProduction * amount * multiplier;
    currentCost = (baseCost * pow(1.15, amount)).ceil();

    strBP = App.floatFormat.format(baseProduction);
    strCP = App.floatFormat.format(currentProduction);
  }
}

class ProducerUpgrade {
  Producer parent;
  int tier;
  bool bought = false;
  late String name;
  late int cost;
  static late List<ProducerUpgrade> all;
  static late List<ProducerUpgrade> forSale;

  ProducerUpgrade(this.parent, this.tier) {
    name = "${parent.name} Up +$tier";
    cost = (parent.baseCost * pow(1.20, tier * 10)).ceil();
  }

  void buy() {
    if (Data.resourceAmount < cost) {
      return;
    }
    Data.resourceAmount -= cost;
    bought = true;
    forSale.remove(this);
    parent.calc();
  }
}

List<Producer> initProducers() {
  List<Producer> producers = [
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
        0.5,
        150),
    Producer(
        'Molecule',
        Icon(
          Icons.hub,
          color: Colors.indigo.shade400,
        ),
        4,
        3000),
    Producer(
        'Cell',
        const Icon(
          Icons.egg_alt,
          color: Colors.cyan,
        ),
        32,
        60000),
    Producer(
        'Flora',
        const Icon(
          Icons.local_florist,
          color: Colors.teal,
        ),
        256,
        1200000),
    Producer(
        'Fauna',
        Icon(
          Icons.pets,
          color: Colors.lime.shade700,
        ),
        2048,
        24000000),
    Producer(
        'Citizen',
        Icon(
          Icons.person,
          color: Colors.yellow.shade700,
        ),
        16384,
        480000000),
    Producer(
        'Temple',
        Icon(
          Icons.account_balance,
          color: Colors.orange.shade600,
        ),
        131072,
        9600000000),
  ];
  initProducerUpgrades(producers);
  return producers;
}

void initProducerUpgrades(List<Producer> producers) {
  ProducerUpgrade.all = [];
  for (Producer producer in producers) {
    for (ProducerUpgrade upgrade in producer.upgrades) {
      ProducerUpgrade.all.add(upgrade);
    }
  }
  ProducerUpgrade.all.sort((a, b) => a.cost.compareTo(b.cost));
  updateProducerUpgrades();
}

void updateProducerUpgrades() {
  ProducerUpgrade.forSale = [];
  for (ProducerUpgrade upgrade in ProducerUpgrade.all) {
    if (!upgrade.bought) {
      ProducerUpgrade.forSale.add(upgrade);
    }
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
multiplied by ${producer.multiplier} through upgrades,
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

class ProducerUpgradeArea extends Container {
  final ProducerUpgrade producerUpgrade;
  final Function(ProducerUpgrade) onBuy;

  ProducerUpgradeArea(this.producerUpgrade, this.onBuy, {super.key})
      : super(
          child: Tooltip(
            message:
                "Doubles the production of ${producerUpgrade.parent.name} objects.",
            showDuration: const Duration(milliseconds: 0),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producerUpgrade.name),
                  Text(
                    'Cost: ${App.intFormat.format(producerUpgrade.cost)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: producerUpgrade.cost > Data.resourceAmount
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
              leading: producerUpgrade.parent.icon,
              trailing: Icon(
                Icons.arrow_upward,
                color: Data.useDarkTheme ? Colors.white : Colors.black,
              ),
              onTap: () => onBuy(producerUpgrade),
            ),
          ),
        );
}
