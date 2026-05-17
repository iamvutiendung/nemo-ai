import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/resource_item.dart';
import 'services/resource_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();
  ResourceService.addItem(
    ResourceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ResourceType.video,
      title: 'AI Dance Video',
      path: 'assets/images/dance_video.jpg',
      createdAt: DateTime.now(),
      duration: '8s',
    ),
  );

  ResourceService.addItem(
    ResourceItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_2',
      type: ResourceType.image,
      title: 'Ảnh người mẫu sản phẩm',
      path: 'assets/images/model_product.jpg',
      createdAt: DateTime.now(),
    ),
  );

  runApp(const NemoApp());
}

class NemoApp extends StatelessWidget {
  const NemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nemo AI',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFF071427),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}