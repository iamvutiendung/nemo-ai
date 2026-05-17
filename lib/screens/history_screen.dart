import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        'title': 'AI Dance Video',
        'prompt': 'Girl dancing in neon city',
        'status': 'Completed',
        'date': 'Today • 14:22',
        'image':
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      },
      {
        'title': 'Product Review Video',
        'prompt': 'Luxury cosmetic ad cinematic',
        'status': 'Rendering',
        'date': 'Today • 11:05',
        'image':
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
      },
      {
        'title': 'Fashion Selfie',
        'prompt': 'Streetwear model 4K',
        'status': 'Completed',
        'date': 'Yesterday',
        'image':
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                _showPreview(context, item);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        item['image']!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item['prompt']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  item['status'] == 'Completed'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item['status']!,
                                  style: TextStyle(
                                    color:
                                    item['status'] == 'Completed'
                                        ? Colors.greenAccent
                                        : Colors.orangeAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              Text(
                                item['date']!,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPreview(
      BuildContext context,
      Map<String, String> item,
      ) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    item['image']!,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  item['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  item['prompt']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Xem lại'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}