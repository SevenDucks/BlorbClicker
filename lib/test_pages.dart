import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  List<Widget> widgets = const [TestHomePage(), TestProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicker'),
      ),
      body: widgets[currentPage],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Hallo');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedIndex: currentPage,
        onDestinationSelected: (index) => setState(() {
          currentPage = index;
        }),
      ),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const TestLearnFlutterPage();
              },
            ),
          );
        },
        child: const Text('Learn Flutter'),
      ),
    );
  }
}

class TestProfilePage extends StatelessWidget {
  const TestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      itemBuilder: ((context, index) {
        return ListTile(
          title: Text('Item ${index + 1}'),
          leading: const Icon(Icons.person),
          trailing: const Icon(Icons.select_all),
        );
      }),
    );
  }
}

class TestLearnFlutterPage extends StatefulWidget {
  const TestLearnFlutterPage({super.key});

  @override
  State<TestLearnFlutterPage> createState() => _TestLearnFlutterPageState();
}

class _TestLearnFlutterPageState extends State<TestLearnFlutterPage> {
  bool switchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.info)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              color: Colors.deepPurple,
              width: double.infinity,
              child: const Center(
                child: Text(
                  'Hello World!',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: switchEnabled ? Colors.blue : Colors.purple),
              onPressed: () {
                debugPrint('Elevated Button');
              },
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {
                debugPrint('Outlined Button');
              },
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {
                debugPrint('Text Button');
              },
              child: const Text('Text Button'),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                debugPrint('Row');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.local_fire_department),
                  Text('Fire'),
                  Icon(Icons.local_fire_department),
                ],
              ),
            ),
            Switch(
              value: switchEnabled,
              onChanged: (value) {
                setState(() {
                  switchEnabled = value;
                });
              },
            ),
            Checkbox(
              value: switchEnabled,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  switchEnabled = value!;
                });
              },
            ),
            Image.asset('res/images/Heisenblorb.png'),
          ],
        ),
      ),
    );
  }
}
