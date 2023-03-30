import 'package:flutter/material.dart';
import 'package:life_counter/life_event.dart';
import 'package:life_counter/objectbox.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LifeCounterPage(),
    );
  }
}

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];

  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    fetchLifeEvents();
  }

  void fetchLifeEvents() {
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("人生カウンター"),
      ),
      body: ListView.builder(
        itemCount: lifeEvents.length,
        itemBuilder: (context, index) {
          final lifeEvent = lifeEvents[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 240, child: Text(lifeEvent.title)),
                Text(lifeEvent.count.toString()),
                IconButton(
                  onPressed: () {
                    lifeEvent.count++;
                    lifeEventBox?.put(lifeEvent);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.plus_one),
                ),
                IconButton(
                  onPressed: () {
                    lifeEventBox?.remove(lifeEvent.id);
                    fetchLifeEvents();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newLifeEvent = await Navigator.of(context).push<LifeEvent>(
            MaterialPageRoute(
              builder: (context) {
                return const AddLifeEventPage();
              },
            ),
          );
          if (newLifeEvent != null) {
            lifeEventBox?.put(newLifeEvent);
            fetchLifeEvents();
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}

class AddLifeEventPage extends StatefulWidget {
  const AddLifeEventPage({super.key});

  @override
  State<AddLifeEventPage> createState() => _AddLifeEventPageState();
}

class _AddLifeEventPageState extends State<AddLifeEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ライフイベント追加"),
      ),
      body: TextFormField(
        onFieldSubmitted: (text) {
          final lifeEvent = LifeEvent(
            count: 0,
            title: text,
          );
          Navigator.of(context).pop(lifeEvent);
        },
      ),
    );
  }
}
