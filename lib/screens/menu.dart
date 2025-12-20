import 'package:flutter/material.dart';
import 'package:flutter_hoppin/booking_venue/book_screens/venue_entry_list.dart';
import 'package:flutter_hoppin/colors.dart';
import 'package:flutter_hoppin/matches/services/match_service.dart';
import 'package:flutter_hoppin/screens/match_page.dart';
import 'package:flutter_hoppin/screens/profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;

  final pages = const [Placeholder(), VenueEntryListPage(), MatchPage(), Placeholder(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: MainColors.primaryColor,
        currentIndex: _counter,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.blueAccent[800],
        onTap: (index) {
          setState(() {
            _counter = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Threads'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Venue'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Match'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: pages[_counter],
    );
  }
}