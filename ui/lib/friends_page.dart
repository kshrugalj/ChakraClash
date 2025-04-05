import 'package:flutter/material.dart';
import 'package:flutter_application_1/history_screen.dart'; // Add this import
import 'package:flutter_application_1/home_screen.dart'; // Add this import if needed


class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> originalFriends = [
    {
      'name': 'Alex',
      'status': 'Online',
      'action': 'Add Back',
      'time': 'Added you 23 min ago!',
      'profile': 'https://randomuser.me/api/portraits/men/31.jpg'
    },
    {
      'name': 'Charlie',
      'status': 'Online',
      'action': 'Invite!',
      'profile': 'https://randomuser.me/api/portraits/men/34.jpg'
    },
    {
      'name': 'Sam',
      'status': 'Online 2h ago',
      'action': 'Offline',
      'profile': 'https://randomuser.me/api/portraits/men/41.jpg'
    },
    {
      'name': 'Sophie',
      'status': 'Online 4h ago',
      'action': 'Offline',
      'profile': 'https://randomuser.me/api/portraits/women/42.jpg'
    },
    {
      'name': 'Emily',
      'status': 'Online',
      'action': 'Invite!',
      'profile': 'https://randomuser.me/api/portraits/women/44.jpg'
    },
    {
      'name': 'Isabella',
      'status': 'Online 30m ago',
      'action': 'Offline',
      'profile': 'https://randomuser.me/api/portraits/women/45.jpg'
    },
  ];

  List<Map<String, String>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    filteredFriends = List.from(originalFriends);
    _sortFriends();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredFriends = originalFriends
            .where((friend) =>
                friend['name']!.toLowerCase().contains(query))
            .toList();
        _sortFriends(); // Re-sort after filtering
      });
    });
  }

  // Function to sort friends by name alphabetically
  void _sortFriends() {
    filteredFriends.sort((a, b) => a['name']!.compareTo(b['name']!));
    originalFriends.sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  void showBanner(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    // Auto-dismiss the banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  void handleAddBack(int index) {
    final status = filteredFriends[index]['status']!;
    setState(() {
      if (status.toLowerCase().contains('online')) {
        filteredFriends[index]['action'] = 'Invite!';
      } else {
        filteredFriends[index]['action'] = 'Offline';
      }

      // Update master list
      final originalIndex = originalFriends.indexWhere(
          (f) => f['name'] == filteredFriends[index]['name']);
      if (originalIndex != -1) {
        originalFriends[originalIndex]['action'] =
            filteredFriends[index]['action']!;
      }
    });

    showBanner(context, '${filteredFriends[index]['name']} is now your friend!');
  }

  void handleInvite(int index) {
    showBanner(context, '${filteredFriends[index]['name']} was invited!');
  }

  void handleCancelRequest(int index) {
    setState(() {
      // Remove from both lists
      final removedFriend = filteredFriends.removeAt(index);

      // Also remove from the original list
      originalFriends.removeWhere((friend) => friend['name'] == removedFriend['name']);
    });

    showBanner(context, 'Friend request to ${filteredFriends[index]['name']} has been canceled.');
  }

  void _showContactsDialog() {
    List<Map<String, String>> mockContacts = [
      {'name': 'Jordan', 'profile': 'https://randomuser.me/api/portraits/men/55.jpg'},
      {'name': 'Mia', 'profile': 'https://randomuser.me/api/portraits/women/56.jpg'},
      {'name': 'Liam', 'profile': 'https://randomuser.me/api/portraits/men/57.jpg'},
      {'name': 'Emma', 'profile': 'https://randomuser.me/api/portraits/women/58.jpg'},
      {'name': 'Noah', 'profile': 'https://randomuser.me/api/portraits/men/59.jpg'},
      {'name': 'Olivia', 'profile': 'https://randomuser.me/api/portraits/women/60.jpg'},
      // You can add as many contacts as you want here
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Contact to Add'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Adjust the height as needed
            child: SingleChildScrollView(
              child: Column(
                children: mockContacts.map((contact) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(contact['profile']!),
                    ),
                    title: Text(contact['name']!),
                    onTap: () {
                      _addContactAsFriend(contact);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addContactAsFriend(Map<String, String> contact) {
    final newFriend = {
      'name': contact['name']!,
      'status': 'Pending Friend Request',
      'action': 'Cancel Request',
      'profile': contact['profile']!,
      'time': 'Sent just now',
    };

    setState(() {
      originalFriends.insert(0, newFriend);
      filteredFriends = List.from(originalFriends);
      _sortFriends(); // Re-sort after adding new friend
    });

    showBanner(context, 'Friend request sent to ${contact['name']}!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Find Friends',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showContactsDialog(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.contacts),
                    hintText: 'Add from Contacts',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                final action = friend['action']!;
                Color buttonColor;
                bool isEnabled = true;

                switch (action) {
                  case 'Offline':
                    buttonColor = Colors.grey;
                    isEnabled = false;
                    break;
                  case 'Add Back':
                    buttonColor = Colors.blue;
                    break;
                  case 'Invite!':
                    buttonColor = Colors.green;
                    break;
                  case 'Cancel Request':
                    buttonColor = Colors.red;
                    break;
                  default:
                    buttonColor = Colors.grey;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['profile']!),
                  ),
                  title: Text(friend['name']!),
                  subtitle: Text(friend['status']!),
                  trailing: ElevatedButton(
                    onPressed: isEnabled
                        ? () {
                            if (action == 'Add Back') {
                              handleAddBack(index);
                            } else if (action == 'Invite!') {
                              handleInvite(index);
                            } else if (action == 'Cancel Request') {
                              handleCancelRequest(index);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(action),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Update as per your current index selection
        selectedItemColor: const Color(0xFF344055),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            // Navigate to Home Screen with right-to-left transition
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Start from the right
                  const end = Offset.zero; // End at the original position
                  const curve = Curves.easeInOut; // Smooth curve transition

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 0) {
            // Stay on the friends page, if needed
            Navigator.pushReplacementNamed(context, '/friends');
          } else if (index == 2) {
            // Navigate to History Screen with right-to-left transition
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Start from the right
                  const end = Offset.zero; // End at the original position
                  const curve = Curves.easeInOut; // Smooth curve transition

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}