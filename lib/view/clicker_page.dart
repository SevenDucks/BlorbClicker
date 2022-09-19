import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../mechanics/producers.dart';

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

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        Data.resourceAmount += resourcesPerTick;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blorb Clicker'),
        actions: [
          const Icon(Icons.dark_mode),
          Switch(
              value: Data.useDarkTheme,
              onChanged: ((value) {
                App.theme.switchTheme();
              })),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: ClickerArea(context, increment),
          ),
          Material(
            elevation: 20,
            child: SizedBox(
              width: 350,
              child: buildShop(),
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
      Data.resourceAmount++;
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

  ListView buildShop() {
    return ListView.builder(
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
    );
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
                App.intFormat.format(Data.resourceAmount.floor()),
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                'Per Second: ${App.floatFormat.format(resourcesPerSecond)}',
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
