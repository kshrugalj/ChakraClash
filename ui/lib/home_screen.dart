import 'package:flutter/material.dart';
import 'package:flutter_application_1/match_page.dart';
import 'package:flutter_application_1/friends_page.dart';
import 'package:flutter_application_1/history_screen.dart'; // <-- Add this import
import 'package:palette_generator/palette_generator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Color> _getDominantColor(String imagePath) async {
    final imageProvider = AssetImage(imagePath);
    final palette = await PaletteGenerator.fromImageProvider(imageProvider);
    return palette.dominantColor?.color ?? Colors.grey.shade300;
  }

  final Map<String, String> youtubeUrls = {
    'Anantasana': 'lNxfdoQp27Y',
    'Ardha Kati Chakrasana': 'Pw14wbDWrCU',
  };

  final Map<String, Map<String, dynamic>> asanaDetails = {
    'Anantasana': {
      'description': 'A side-reclining leg lift that enhances balance and stretches the legs.',
      'benefits': [
        'Improves flexibility of hamstrings',
        'Strengthens abdominal muscles',
        'Enhances balance and coordination',
      ],
    },
    'Ardha Kati Chakrasana': {
      'description': 'A standing side bend that stretches the waist and improves posture.',
      'benefits': [
        'Stretches side body and spine',
        'Helps reduce fat in waist area',
        'Improves flexibility',
      ],
    },
    'Bhujangasana': {
      'description': 'The cobra pose strengthens the spine and opens the chest.',
      'benefits': [
        'Improves posture',
        'Strengthens spine and buttocks',
        'Opens chest and lungs',
      ],
    },
    'Kati Chakrasana': {
      'description': 'A spinal twist pose that rejuvenates the back and shoulders.',
      'benefits': [
        'Improves spinal flexibility',
        'Stimulates digestive system',
        'Relieves back and neck tension',
      ],
    },
    'Marjariasana': {
      'description': 'Also known as Cat Pose, it promotes spinal flexibility.',
      'benefits': [
        'Massages spine and belly organs',
        'Relieves tension in neck and back',
        'Improves coordination',
      ],
    },
    'Parvatasana': {
      'description': 'Mountain pose builds strength in arms and legs while lengthening the spine.',
      'benefits': [
        'Strengthens arms and legs',
        'Stretches shoulders and calves',
        'Improves posture',
      ],
    },
    'Sarvangasana': {
      'description': 'Shoulder stand pose stimulates the thyroid and calms the mind.',
      'benefits': [
        'Improves circulation',
        'Stimulates thyroid and parathyroid glands',
        'Calms nervous system',
      ],
    },
    'Tadasana': {
      'description': 'A basic standing pose that improves posture and balance.',
      'benefits': [
        'Improves posture',
        'Increases awareness',
        'Strengthens thighs, knees, and ankles',
      ],
    },
    'Vajrasana': {
      'description': 'Thunderbolt pose is ideal for digestion and meditation.',
      'benefits': [
        'Improves digestion',
        'Calms the mind',
        'Strengthens pelvic muscles',
      ],
    },
    'Viparita Karani': {
      'description': 'A restorative pose with legs up the wall, easing stress and fatigue.',
      'benefits': [
        'Relieves tired legs and feet',
        'Calms the nervous system',
        'Improves blood circulation',
      ],
    },
  };

  List<Map<String, String>> invites = [
    {'name': 'Alice', 'id': '1'},
    {'name': 'Bob', 'id': '2'},
    {'name': 'Charlie', 'id': '3'},
  ];

  void _showInvitesDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invitations'),
        content: SingleChildScrollView(
          child: Column(
            children: invites.map((invite) {
              return ListTile(
                title: Text('${invite['name']} challenged you to a 1v1 match'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () {
                          // Handle accept logic
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Accepted ${invite['name']}\'s challenge')));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      color: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          // Remove the invite and close the dialog
                          setState(() {
                            invites.remove(invite);
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Declined ${invite['name']}\'s challenge')));
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/chakra_logo.png', height: 80),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Welcome Back", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("John Doe", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.mail_outline, size: 28),
                    onPressed: _showInvitesDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MidMatchScreen()));
              },
              child: FutureBuilder<Color>(
                future: _getDominantColor('assets/images/battle_meditation.jpg'),
                builder: (context, snapshot) {
                  final bgColor = snapshot.hasData ? snapshot.data! : Colors.grey.shade300;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: bgColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/battle_meditation.jpg',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 150,
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.bottomLeft,
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                            child: const Text(
                              'Quick Match',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Tutorials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            buildPoseCard(imagePath: 'assets/images/anantasana.jpg', label: 'Anantasana', fit: BoxFit.contain),
            buildPoseCard(imagePath: 'assets/images/ardha_kati_chakrasana.jpg', label: 'Ardha Kati Chakrasana'),
            buildPoseCard(imagePath: 'assets/images/bhujangasana.jpg', label: 'Bhujangasana'),
            buildPoseCard(imagePath: 'assets/images/kati_chakrasana.jpg', label: 'Kati Chakrasana', fit: BoxFit.fitHeight),
            buildPoseCard(imagePath: 'assets/images/marjariasana.jpg', label: 'Marjariasana'),
            buildPoseCard(imagePath: 'assets/images/parvatasana.jpg', label: 'Parvatasana', fit: BoxFit.contain),
            buildPoseCard(imagePath: 'assets/images/sarvangasana.jpg', label: 'Sarvangasana', fit: BoxFit.fitHeight),
            buildPoseCard(imagePath: 'assets/images/tadasana.jpg', label: 'Tadasana', fit: BoxFit.fitHeight),
            buildPoseCard(imagePath: 'assets/images/vajrasana.jpg', label: 'Vajrasana', fit: BoxFit.fitHeight),
            buildPoseCard(imagePath: 'assets/images/viparita_karani.jpg', label: 'Viparita Karani', fit: BoxFit.fitHeight),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF344055),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, PageRouteBuilder(
              pageBuilder: (_, __, ___) => FriendsPage(),
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            ));
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HistoryScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget buildPoseCard({
    required String imagePath,
    required String label,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
  }) {
    return GestureDetector(
      onTap: () {
        final videoId = youtubeUrls[label];
        final details = asanaDetails[label];

        if (videoId != null && details != null) {
          final controller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
          );

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(controller: controller, showVideoProgressIndicator: true),
                  builder: (context, player) => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        player,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            label,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(details['description']),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Benefits:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...details['benefits']
                                  .map((benefit) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text('- $benefit'),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Image.asset(
                imagePath,
                fit: fit,
                width: double.infinity,
                height: 200,
                alignment: alignment,
              ),
              Container(
                width: double.infinity,
                height: 200,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
