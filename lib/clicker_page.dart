import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

NumberFormat intFormat = NumberFormat('#,##0');
NumberFormat floatFormat = NumberFormat('#,##0.0');

double resourceAmount = 0;
double resourcesPerSecond = 0;
double resourcesPerTick = 0;

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  late final Timer timer;
  late final List<Producer> producers;

  @override
  void initState() {
    super.initState();

    producers = [
      Producer('Blorber', 0.1, 15),
      Producer('Mega Blorber', 0.5, 180),
      Producer('Giga Blorber', 2.5, 2500),
      Producer('Ultra Blorber', 15, 50000),
    ];

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        resourceAmount += resourcesPerTick;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blorb Clicker'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Blorb Coins:',
                ),
                Text(
                  intFormat.format(resourceAmount.floor()),
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  'Per Second: ${floatFormat.format(resourcesPerSecond)}',
                ),
                ClickerButton(context, increment),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromARGB(4, 0, 64, 48),
              child: ListView.builder(
                itemCount: producers.length,
                itemBuilder: ((context, index) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producers[index].name),
                        Text(
                          'Cost: ${intFormat.format(producers[index].currentCost)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: producers[index].currentCost > resourceAmount
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    leading: const Icon(Icons.person),
                    trailing: Text(
                      '${producers[index].amount}',
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    onTap: () => buy(producers[index]),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void increment() {
    setState(() {
      resourceAmount++;
    });
  }

  void buy(Producer producer) {
    setState(() {
      producer.buy();
      recalc();
    });
  }

  void recalc() {
    resourcesPerSecond = 0;
    for (Producer producer in producers) {
      resourcesPerSecond += producer.currentProduction;
    }
    resourcesPerTick = resourcesPerSecond / 10;
  }
}

class Producer {
  String name;
  int amount = 0;
  double baseProduction;
  late double currentProduction;
  int baseCost;
  late int currentCost;

  Producer(this.name, this.baseProduction, this.baseCost) {
    calc();
  }

  void buy() {
    if (resourceAmount < currentCost) {
      return;
    }
    resourceAmount -= currentCost;
    amount++;
    calc();
  }

  void calc() {
    currentProduction = baseProduction * amount;
    currentCost = (baseCost * pow(1.15, amount)).ceil();
  }
}

class ClickerButton extends Container {
  final BuildContext context;
  final VoidCallback onPressed;

  ClickerButton(this.context, this.onPressed, {super.key})
      : super(
            margin: const EdgeInsets.all(25),
            child: Ink(
              decoration: ShapeDecoration(
                color: Theme.of(context).primaryColorDark,
                shape: const CircleBorder(),
              ),
              child: IconButton(
                onPressed: onPressed,
                icon: const Icon(Icons.add),
                iconSize: 75,
                color: Colors.white,
              ),
            ));
}
