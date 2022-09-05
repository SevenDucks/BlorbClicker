import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

NumberFormat intFormat = NumberFormat('#,##0');
NumberFormat floatFormat = NumberFormat('#,##0.0');

double resourceAmount = 0;
double resourcesPerSecond = 0;
double resourcesPerTick = 0;

int currentPage = 0;

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
      Producer(
          'Particle',
          const Icon(
            Icons.grain,
            color: Colors.purple,
          ),
          0.1,
          15),
      Producer(
          'Atom',
          const Icon(
            Icons.mode_standby,
            color: Colors.deepPurple,
          ),
          0.7,
          180),
      Producer(
          'Molecule',
          const Icon(
            Icons.hub,
            color: Colors.indigo,
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
            child: ClickerArea(context, increment),
          ),
          Container(
            width: 350,
            color: const Color.fromARGB(8, 64, 64, 64),
            child: ListView.builder(
              itemCount: currentPage > 0 ? 2 : producers.length + 1,
              itemBuilder: ((context, index) {
                if (index == 0) {
                  return NavigationBar(
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.apps),
                        label: 'Objects',
                        tooltip: '',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.arrow_circle_up),
                        label: 'Upgrades',
                        tooltip: '',
                      ),
                    ],
                    selectedIndex: currentPage,
                    onDestinationSelected: (index) => setState(() {
                      currentPage = index;
                    }),
                  );
                }

                if (currentPage == 0) {
                  return ProducerArea(producers[index - 1], buy);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Coming Soon!'),
                  );
                }
              }),
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

    strBP = floatFormat.format(baseProduction);
    strCP = floatFormat.format(currentProduction);
  }
}

class ClickerArea extends Container {
  final BuildContext context;
  final VoidCallback onPressed;

  ClickerArea(this.context, this.onPressed, {super.key})
      : super(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Entropy:',
              ),
              Text(
                intFormat.format(resourceAmount.floor()),
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                'Per Second: ${floatFormat.format(resourcesPerSecond)}',
              ),
              ClickerButton(context, onPressed),
            ],
          ),
        );
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
                    'Cost: ${intFormat.format(producer.currentCost)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: producer.currentCost > resourceAmount
                          ? Colors.red
                          : Colors.green,
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
