import 'package:flutter/material.dart';
import 'package:flutter_application_1/friends_page.dart'; 
import 'package:flutter_application_1/home_screen.dart'; 
import 'package:flutter/widgets.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> matchups = [
    {
      'date': '2024-03-15',
      'name1': 'John Doe',
      'score1': 9.8,
      'avatar1': 'https://randomuser.me/api/portraits/men/10.jpg',
      'name2': 'Maya Patel',
      'score2': 9.6,
      'avatar2': 'https://randomuser.me/api/portraits/women/43.jpg',
      'style': 'Advanced Flow',
      'duration': '45 min',
    },
    {
      'date': '2024-03-14',
      'name1': 'John Doe',
      'score1': 9.4,
      'avatar1': 'https://randomuser.me/api/portraits/men/10.jpg',
      'name2': 'David Kim',
      'score2': 9.6,
      'avatar2': 'https://randomuser.me/api/portraits/men/33.jpg',
      'style': 'Power Yoga',
      'duration': '60 min',
    },
    {
      'date': '2024-03-13',
      'name1': 'John Doe',
      'score1': 9.9,
      'avatar1': 'https://randomuser.me/api/portraits/men/10.jpg',
      'name2': 'Lisa Johnson',
      'score2': 9.7,
      'avatar2': 'https://randomuser.me/api/portraits/women/13.jpg',
      'style': 'Ashtanga',
      'duration': '90 min',
    },
  ];

  Color getScoreColor(double score1, double score2, bool isFirst) {
    if (score1 == score2) return Colors.black;
    return (isFirst ? score1 > score2 : score2 > score1) ? Colors.green : Colors.black;
  }

  bool hasTrophy(double score1, double score2, bool isFirst) {
    return (score1 != score2) && (isFirst ? score1 > score2 : score2 > score1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Recent Matchups', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: matchups.length,
        itemBuilder: (context, index) {
          final item = matchups[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['date'], style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(item['avatar1']), radius: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name1'], style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                if (hasTrophy(item['score1'], item['score2'], true))
                                  Icon(Icons.emoji_events, size: 16, color: Colors.green),
                                if (hasTrophy(item['score1'], item['score2'], true))
                                  SizedBox(width: 4),
                                Text(
                                  item['score1'].toString(),
                                  style: TextStyle(
                                    color: getScoreColor(item['score1'], item['score2'], true),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Text('vs', style: TextStyle(color: Colors.grey[500])),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item['name2'], style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item['score2'].toString(),
                                  style: TextStyle(
                                    color: getScoreColor(item['score1'], item['score2'], false),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasTrophy(item['score1'], item['score2'], false))
                                  SizedBox(width: 4),
                                if (hasTrophy(item['score1'], item['score2'], false))
                                  Icon(Icons.emoji_events, size: 16, color: Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(backgroundImage: NetworkImage(item['avatar2']), radius: 24),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(item['duration'], style: TextStyle(color: Colors.grey[600])),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text('Details', style: TextStyle(color: Colors.deepPurple)),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, size: 16, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(item['style'], style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: 2, // Set the index to 2 to indicate the 'History' menu is active
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home Screen with left-to-right transition
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => FriendsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // Start from the left
                  const end = Offset.zero; // End at the original position
                  const curve = Curves.easeInOut; // Use a smooth curve

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 1) {
            // Navigate to Friends Page with left-to-right transition
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // Start from the left
                  const end = Offset.zero; // End at the original position
                  const curve = Curves.easeInOut; // Use a smooth curve

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 2) {
            // Stay on the current screen (History)
          }
        },
      ),
    );
  }
}