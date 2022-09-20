import 'dart:async';

import 'package:flutter/material.dart';

import '../main.dart';
import '../mechanics/producers.dart';

int lastResourceUpdate = 0;
double resourcesPerSecond = 0;

int currentPage = 0;

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> {
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    recalc();

    App.theme.addListener(() {
      recalc();
    });

    lastResourceUpdate = DateTime.now().millisecondsSinceEpoch;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        Data.resourceAmount +=
            resourcesPerSecond * (currentTime - lastResourceUpdate) / 1000;
        lastResourceUpdate = currentTime;
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
            child: Column(
              children: [
                Expanded(child: ClickerArea(context, increment)),
                SaveButtons(context),
              ],
            ),
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
    for (Producer producer in Data.producers) {
      resourcesPerSecond += producer.currentProduction;
    }
  }

  ListView buildShop() {
    return ListView.builder(
      itemCount: currentPage > 0 ? 2 : Data.producers.length + 1,
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
          return ProducerArea(Data.producers[index - 1], buy);
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
            margin: const EdgeInsets.all(30),
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

class SaveButtons extends Container {
  final BuildContext context;

  SaveButtons(this.context, {super.key})
      : super(
          margin: const EdgeInsets.all(15),
          child: Row(
            children: [
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () async {
                  await Data.persist();
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Progress Saved'),
                      content: const Text('''Your save has been stored
as a browser cookie.

Use the export and import functions
to backup your save to a file.'''),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                  child: const Text('Export'),
                  onPressed: () => Data.serailize()),
              const SizedBox(width: 15),
              ElevatedButton(
                  child: const Text('Import'),
                  onPressed: () => Data.deserialize()),
              const Spacer(),
              ElevatedButton(
                child: const Text('Reset Progress'),
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Reset Progress'),
                      content: const Text(
                          'Are you sure that you want\nto reset all your progress?'),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: const Text('Yes, Reset'),
                          onPressed: () {
                            Data.reset();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
}
