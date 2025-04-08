import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_card.dart';

class MyTimeLineTile extends StatefulWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String image;
  final String text;
  final Color color;
  final Color subColor;
  final int chapterIndex;
  final int topicIndex;
  final bool isNextTopic;

  const MyTimeLineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.image,
    required this.text,
    required this.color,
    required this.subColor,
    required this.chapterIndex,
    required this.topicIndex,
    required this.isNextTopic,
  });

  @override
  _MyTimeLineTileState createState() => _MyTimeLineTileState();
}

class _MyTimeLineTileState extends State<MyTimeLineTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool isCompleted = false;
  bool isNextTopic = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for sliding effect
    _controller = AnimationController(
      duration: Duration(seconds: 4), // Slow sliding effect
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    checkIfCompleted();
  }

  Future<void> checkIfCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('user_progress').doc(user.uid).get();
      final completedTopics = List<Map<String, dynamic>>.from(doc.data()?['completed_topics'] ?? []);

      setState(() {
        isCompleted = completedTopics.any((topic) =>
            topic['chapter_number'] == widget.chapterIndex &&
            topic['topic_number'] == widget.topicIndex);

        isNextTopic = completedTopics.any((topic) =>
                topic['chapter_number'] == widget.chapterIndex &&
                topic['topic_number'] == widget.topicIndex - 1) &&
            !isCompleted;
      if (isNextTopic && !_hasAnimated) {
        _hasAnimated = true;
        _controller.forward();
      }

        if (isNextTopic) {
          _controller.forward();
        }
      });

    } catch (e) {
      print("Error fetching progress: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: TimelineTile(
        isFirst: widget.isFirst,
        isLast: widget.isLast,
        
         
       
        
        indicatorStyle: IndicatorStyle(
         width: 30,
                  height: 30,
          indicator: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0.0, isNextTopic ? _slideAnimation.value : 0.0), // ✅ Slides down smoothly
                child: Container(
                  
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        isNextTopic
                            ? "assets/introductions/zhuaHug.gif" // ✅ Animated GIF for next topic
                            : "assets/profile/cat.png", // ✅ Static for completed topics
                      ),
                      
                      fit: BoxFit.cover,
                      
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        endChild: EventCard(
          isPast: widget.isPast,
          imagePath: widget.image,
          text: widget.text,
          color: widget.color,
          subColor: widget.subColor,
        ),
      ),
    );
  }
}
