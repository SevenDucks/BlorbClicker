import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

double amount = 0;

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

    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        for (Producer producer in producers) {
          amount += producer.getProduction();
        }
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
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Blorb Coins:',
                  ),
                  Text(
                    '${amount.floor()}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  ClickerButton(context, increment),
                ],
              ),
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
                          'Cost: ${producers[index].getCost()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: producers[index].getCost() > amount
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
      amount++;
    });
  }

  void buy(Producer producer) {
    int cost = producer.getCost();
    if (amount < cost) {
      return;
    }
    setState(() {
      amount -= cost;
      producer.amount++;
    });
  }
}

class Producer {
  String name;
  int amount = 0;
  double baseProduction;
  int baseCost;

  Producer(this.name, this.baseProduction, this.baseCost);

  double getProduction() {
    return baseProduction * amount;
  }

  int getCost() {
    return (baseCost * pow(1.15, amount)).ceil();
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
